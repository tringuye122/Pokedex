import Foundation
import Combine

@MainActor
final class PokemonDetailViewModel: ObservableObject {
    @Published var details: PokemonDetails?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let apiService = APIService()

    func loadPokemonDetails(pokemonID: Int) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let fetched = try await apiService.fetchPokemonDetails(pokemonID: pokemonID)
            self.details = fetched
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
