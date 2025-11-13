import Foundation

struct Pokemon: Codable, Hashable {
    let name: String
    let url: String
}

struct PokemonResponse: Codable {
    let results: [Pokemon]
}
