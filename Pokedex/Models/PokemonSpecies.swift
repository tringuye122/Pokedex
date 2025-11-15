import Foundation

struct PokemonSpecies: Codable {
    let flavor_text_entries: [FlavorTextEntry]

    struct FlavorTextEntry: Codable {
        let flavor_text: String
        let language: Language

        struct Language: Codable {
            let name: String
            let url: String
        }
    }
}
