import Foundation

class APIService {
    private let baseURL = "https://pokeapi.co/api/v2/pokemon/"
    private let speciesBaseURL = "https://pokeapi.co/api/v2/pokemon-species/"
    
    // Fetch Pokemon list with pagination
    func fetchPokemonList(limit: Int = 20, offset: Int = 0) async throws -> [Pokemon] {
        let urlString = "\(baseURL)?limit=\(limit)&offset=\(offset)"
        
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL")
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decodedResponse = try JSONDecoder().decode(PokemonResponse.self, from: data)
        return decodedResponse.results
    }
    
    // Fetch detailed Pokemon
    func fetchPokemonDetails(pokemonID: Int) async throws -> PokemonDetails {
        let urlString = "\(baseURL)\(pokemonID)"
        
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL")
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decodedResponse = try JSONDecoder().decode(PokemonDetails.self, from: data)
        return decodedResponse
    }

    // Fetch species info for flavor text
    func fetchPokemonSpecies(pokemonID: Int) async throws -> PokemonSpecies {
        let urlString = "\(speciesBaseURL)\(pokemonID)"
        
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL")
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(PokemonSpecies.self, from: data)
        return decoded
    }
}
