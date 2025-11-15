import Foundation
import Combine

@MainActor
class PokemonListViewModel: ObservableObject {
    @Published var pokemonList: [Pokemon] = []
    @Published var isLoading: Bool = false
    @Published var isLoadingNextPage: Bool = false
    @Published var hasMore: Bool = true
    @Published var errorMessage: String? = nil

    // Cache sprite URLs keyed by Pokemon ID
    @Published private(set) var spriteURLByID: [Int: URL] = [:]
    // Cache types keyed by Pokemon ID (array of type names, ordered by slot)
    @Published private(set) var typesByID: [Int: [String]] = [:]

    private var currentOffset: Int = 0
    private var limit: Int = 20
    private let apiService = APIService()

    // Persistence payload
    private struct PersistedCaches: Codable {
        let spriteURLByID: [Int: String]  // Store as String for Codable, convert to URL on load
        let typesByID: [Int: [String]]
    }

    // Cache file location
    private var cachesURL: URL {
        let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let base = urls.first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        return base.appendingPathComponent("PokemonListCaches.json")
    }

    // MARK: - Public API (called by views)

    // Loads only the initial page
    func resetAndLoadFirstPage() async {
        isLoading = true
        isLoadingNextPage = false
        errorMessage = nil
        hasMore = true
        currentOffset = 0
        pokemonList = []
        // Load persisted caches before fetching so list uses cached sprites/types immediately
        loadCachesFromDisk()
        defer {
            isLoading = false
            // Persist current caches after initial load attempt (in case details were fetched)
            saveCachesToDisk()
        }

        do {
            let pokemon = try await apiService.fetchPokemonList(limit: limit, offset: currentOffset)
            pokemonList = pokemon
            currentOffset += limit
            hasMore = pokemon.count == limit
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // Load the next page if available; guards prevent overlapping calls
    func loadNextPage() async {
        guard hasMore, !isLoading, !isLoadingNextPage else { return }
        isLoadingNextPage = true
        errorMessage = nil
        defer {
            isLoadingNextPage = false
            // Persist caches in case details were fetched while scrolling
            saveCachesToDisk()
        }

        do {
            let pokemon = try await apiService.fetchPokemonList(limit: limit, offset: currentOffset)
            pokemonList.append(contentsOf: pokemon)
            currentOffset += limit
            hasMore = pokemon.count == limit
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // Parse the ID from the Pokemon.url (e.g., .../pokemon/25/ -> 25)
    func id(for pokemon: Pokemon) -> Int? {
        let components = pokemon.url.split(separator: "/").compactMap { Int($0) }
        return components.last
    }

    // Public accessor to get (and fetch if needed) the sprite URL for a Pokemon
    func spriteURL(for pokemon: Pokemon) async -> URL? {
        guard let id = id(for: pokemon) else { return nil }
        if let cached = spriteURLByID[id] {
            return cached
        }
        let ok = await ensureDetailsCached(for: id)
        return ok ? spriteURLByID[id] : nil
    }

    // Public accessor to get cached types for a list item
    func types(for pokemon: Pokemon) async -> [String] {
        guard let id = id(for: pokemon) else { return [] }
        if let cached = typesByID[id] {
            return cached
        }
        let ok = await ensureDetailsCached(for: id)
        return ok ? (typesByID[id] ?? []) : []
    }

    // MARK: - Private helpers (persistence and caching)

    private func loadCachesFromDisk() {
        do {
            let data = try Data(contentsOf: cachesURL)
            let decoded = try JSONDecoder().decode(PersistedCaches.self, from: data)
            // Convert String -> URL
            var urlDict: [Int: URL] = [:]
            for (id, string) in decoded.spriteURLByID {
                if let url = URL(string: string) {
                    urlDict[id] = url
                }
            }
            self.spriteURLByID = urlDict
            self.typesByID = decoded.typesByID
        } catch {
            #if DEBUG
            // Ignore file-not-found on first launch; log others
            let nsError = error as NSError
            if !(nsError.domain == NSCocoaErrorDomain && nsError.code == NSFileReadNoSuchFileError) {
                print("Cache load failed at \(cachesURL.lastPathComponent): \(error)")
            }
            #endif
        }
    }

    private func saveCachesToDisk() {
        do {
            // Convert URL -> String
            var stringDict: [Int: String] = [:]
            for (id, url) in spriteURLByID {
                stringDict[id] = url.absoluteString
            }
            let persisted = PersistedCaches(spriteURLByID: stringDict, typesByID: typesByID)
            let data = try JSONEncoder().encode(persisted)
            try data.write(to: cachesURL, options: [.atomic])
        } catch {
            #if DEBUG
            print("Cache save failed at \(cachesURL.lastPathComponent): \(error)")
            #endif
        }
    }

    // Fetch details once and populate both caches
    private func ensureDetailsCached(for id: Int) async -> Bool {
        // If both sprite and types are already cached
        if spriteURLByID[id] != nil, typesByID[id] != nil {
            return true
        }
        do {
            let details = try await apiService.fetchPokemonDetails(pokemonID: id)
            // Cache sprite URL
            if let url = URL(string: details.sprites.front_default) {
                spriteURLByID[id] = url
            }
            // Cache types (ordered by slot)
            let sortedTypes = details.types.sorted(by: { $0.slot < $1.slot }).map { $0.type.name }
            typesByID[id] = sortedTypes

            // Persist caches after updating
            saveCachesToDisk()
            return true
        } catch {
            return false
        }
    }
}
