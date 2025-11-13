import Foundation
import Combine

@MainActor
class PokemonListViewModel: ObservableObject {
    @Published var pokemonList: [Pokemon] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // Cache sprite URLs keyed by Pokemon ID
    @Published private(set) var spriteURLByID: [Int: URL] = [:]
    
    private var currentOffset: Int = 0
    private var limit: Int = 20
    
    private let apiService = APIService()
    
    func loadPokemonlist() async {
        self.isLoading = true
        do {
            let pokemon = try await apiService.fetchPokemonList(limit: limit, offset: currentOffset)
            self.pokemonList.append(contentsOf: pokemon)
            self.currentOffset += self.limit // Move offset for the next call
            self.isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
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

