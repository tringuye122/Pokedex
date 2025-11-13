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
    
    private var currentOffset: Int = 0
    private var limit: Int = 20
    
    private let apiService = APIService()

    func resetAndLoadFirstPage() async {
        isLoading = true
        isLoadingNextPage = false
        errorMessage = nil
        hasMore = true
        currentOffset = 0
        pokemonList = []
        spriteURLByID = [:]
        defer { isLoading = false }
        
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
        defer { isLoadingNextPage = false }
        
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
        // Split by "/" and take the last non-empty component
        let components = pokemon.url.split(separator: "/").compactMap { Int($0) }
        return components.last
    }
    
    // Public accessor to get (and fetch if needed) the sprite URL for a Pokemon
    func spriteURL(for pokemon: Pokemon) async -> URL? {
        guard let id = id(for: pokemon) else { return nil }
        if let cached = spriteURLByID[id] {
            return cached
        }
        do {
            let details = try await apiService.fetchPokemonDetails(pokemonID: id)
            if let url = URL(string: details.sprites.front_default) {
                spriteURLByID[id] = url
                return url
            }
        } catch {
            // You can optionally set errorMessage here, but avoid spamming on per-card fetches
        }
        return nil
    }
}

