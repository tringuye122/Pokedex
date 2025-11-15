import Foundation
import Combine

@MainActor
final class PokemonDetailViewModel: ObservableObject {
    @Published var details: PokemonDetails?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var descriptionText: String?

    private let apiService = APIService()

    func loadPokemonDetails(pokemonID: Int) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            async let detailsTask = apiService.fetchPokemonDetails(pokemonID: pokemonID)
            async let speciesTask = apiService.fetchPokemonSpecies(pokemonID: pokemonID)

            let (fetchedDetails, species) = try await (detailsTask, speciesTask)
            self.details = fetchedDetails
            self.descriptionText = Self.extractEnglishFlavorText(from: species)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    private static func extractEnglishFlavorText(from species: PokemonSpecies) -> String? {
        // Prefer the most recent English entry
        let englishEntries = species.flavor_text_entries.filter { $0.language.name.lowercased() == "en" }
        guard let entry = englishEntries.last ?? englishEntries.first else { return nil }
        // Clean up newlines and weird whitespace characters found in API
        return entry.flavor_text
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\u{000C}", with: " ")
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
