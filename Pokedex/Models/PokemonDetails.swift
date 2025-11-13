import Foundation

struct PokemonDetails: Codable {
    let id: Int
    let name: String
    let sprites: Sprites
    
    struct Sprites: Codable {
        let front_default: String // URL to the Pokemon Image
    }
}
