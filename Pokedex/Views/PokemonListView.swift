import SwiftUI

struct PokemonListView: View {
    @StateObject var vm = PokemonListViewModel()
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.red.opacity(0.35), Color.red.opacity(0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Foreground content
            Group {
                if vm.isLoading && vm.pokemonList.isEmpty {
                    VStack {
                        Spacer()
                        ProgressView("Loading...")
                            .padding()
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(Array(vm.pokemonList.enumerated()), id: \.element.name) { index, pokemon in
                                let card = PokemonCardView(pokemon: pokemon)
                                    .environmentObject(vm)
                                Group {
                                    if let id = vm.id(for: pokemon) {
                                        NavigationLink(value: id) {
                                            card
                                        }
                                    } else {
                                        card
                                    }
                                }
                                // Infinite scroll & prefetch
                                .onAppear {
                                    let thresholdIndex = max(0, vm.pokemonList.count - 5)
                                    if index >= thresholdIndex {
                                        Task { await vm.loadNextPage() }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.top, 12)
                        
                        // Bottom spinner & end of list
                        if vm.isLoadingNextPage {
                            ProgressView()
                                .padding(.vertical, 16)
                        } else if !vm.hasMore && !vm.pokemonList.isEmpty {
                            Text("No more Pokémon")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .padding(.vertical, 8)
                        }
                    }
                }
            }

            // Error when no request is in progress
            if let errorMessage = vm.errorMessage, !vm.isLoadingNextPage {
                VStack {
                    Spacer()
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .padding(.top, 8)
                    Spacer().frame(height: 0)
                }
            }
        }
        .navigationTitle(Text("Pokedex"))
        .task {
            await vm.resetAndLoadFirstPage()
        }
    }
}

#Preview {
    PokemonListView()
}
