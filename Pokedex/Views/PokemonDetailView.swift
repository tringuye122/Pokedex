//
//  PokemonDetailView.swift
//  Pokedex
//
//  Created by Tri Nguyen on 11/13/25.
//

import SwiftUI

struct PokemonDetailView: View {
    let pokemonID: Int

    @StateObject private var vm = PokemonDetailViewModel()

    var body: some View {
        VStack(spacing: 16) {
            if vm.isLoading {
                ProgressView("Loading...")
            } else if let details = vm.details {
                VStack(spacing: 12) {
                    Text(details.name.capitalized)
                        .font(.largeTitle)
                        .bold()

                    if let url = URL(string: details.sprites.front_default) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: 200, maxHeight: 200)
                            case .failure:
                                Text("Image unavailable")
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                }
                .padding()
            } else if let errorMessage = vm.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            } else {
                Text("No details")
            }
        }
        .navigationTitle(vm.details?.name.capitalized ?? "Details")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await vm.loadPokemonDetails(pokemonID: pokemonID)
        }
    }
}

#Preview {
    PokemonDetailView(pokemonID: 25)
}
