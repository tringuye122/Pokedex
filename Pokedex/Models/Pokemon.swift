import Foundation

struct Pokemon: Codable {
    let name: String
    let url: String
}

struct PokemonResponse: Codable {
    let results: [Pokemon]
}

struct PokemonDetails: Codable {
    let id: Int
    let name: String
    let sprites: Sprites
    
    struct Sprites: Codable {
        let front_default: String // URL to the Pokemon Image
    }
}
