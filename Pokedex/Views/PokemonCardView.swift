//
//  PokemonCardView.swift
//  Pokedex
//
//  Created by Tri Nguyen on 11/13/25.
//

import SwiftUI

struct PokemonCardView: View {
    
    let pokemon: Pokemon
    @EnvironmentObject var vm: PokemonListViewModel
    
    @State private var spriteURL: URL?
    
    var body: some View {
        VStack {
                if let url = spriteURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 90)
                        case .failure:
                            Text("No Image Found")
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    ProgressView()
                }
            
            Text(pokemon.name.capitalized)
                .font(.body)
                .foregroundColor(.black)
        }
        .padding(.bottom, 8)
        .background(RoundedRectangle(cornerRadius: 15).fill(Color.white))
        .shadow(radius: 5)
        .task {
            // Fetch or retrieve cached sprite URL
            if spriteURL == nil {
                spriteURL = await vm.spriteURL(for: pokemon)
            }
        }
    }
}

#Preview {
    let vm = PokemonListViewModel()
    return PokemonCardView(
        pokemon: Pokemon(
            name: "pikachu",
            url: "https://pokeapi.co/api/v2/pokemon/25/"
        )
    )
    .environmentObject(vm)
}

