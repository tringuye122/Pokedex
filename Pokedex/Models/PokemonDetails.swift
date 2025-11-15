import Foundation

struct PokemonDetails: Codable {
    let id: Int
    let name: String
    let sprites: Sprites
    let types: [PokemonTypeEntry]
    let stats: [StatEntry]

    struct Sprites: Codable {
        let front_default: String
    }

    struct PokemonTypeEntry: Codable {
        let slot: Int
        let type: PokemonTypeInfo
    }

    struct PokemonTypeInfo: Codable {
        let name: String
        let url: String
    }

    struct StatEntry: Codable {
        let base_stat: Int
        let effort: Int
        let stat: StatInfo

        struct StatInfo: Codable {
            let name: String
            let url: String
        }
    }
}
