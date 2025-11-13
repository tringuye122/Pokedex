import Foundation

class APIService {
    private let baseURL = "https://pokeapi.co/api/v2/pokemon/"
    
    // Fetch Pokemon list with pagination
    func fetchPokemonList(limit: Int = 20, offset: Int = 0) async throws -> [Pokemon] {
        let urlString = "\(baseURL)?limit=\(limit)&offset=\(offset)"
        
        // Error handling for invalid URL
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL")
        }
        
        // Make network request using URLSession
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Decode the data into the model
        let decodedResponse = try JSONDecoder().decode(PokemonResponse.self, from: data)
        return decodedResponse.results
    }
    
    // Fetch detailed Pokemon list
    func fetchPokemonDetails(pokemonID: Int) async throws -> PokemonDetails {
        let urlString = "\(baseURL)\(pokemonID)"
        
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL")
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let decodedResponse = try JSONDecoder().decode(PokemonDetails.self, from: data)
        return decodedResponse
    }
}

