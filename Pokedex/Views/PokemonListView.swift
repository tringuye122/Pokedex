import SwiftUI

struct PokemonListView: View {
    @StateObject var vm = PokemonListViewModel()
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            VStack {
                if vm.isLoading && vm.pokemonList.isEmpty {
                    ProgressView("Loading...")
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(Array(vm.pokemonList.enumerated()), id: \.element.name) { index, pokemon in
                                Group {
                                    if let id = vm.id(for: pokemon) {
                                        NavigationLink(value: id) {
                                            PokemonCardView(pokemon: pokemon)
                                                .environmentObject(vm)
                                        }
                                    } else {
                                        PokemonCardView(pokemon: pokemon)
                                            .environmentObject(vm)
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
                        .padding(.horizontal)
                        
                        // Bottom spinner or end-of-list hint
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

                if let errorMessage = vm.errorMessage, !vm.isLoadingNextPage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle(Text("Pokemon List"))
            .task {
                await vm.resetAndLoadFirstPage()
            }
            .navigationDestination(for: Int.self) { pokemonID in
                PokemonDetailView(pokemonID: pokemonID)
            }
        }
    }
}

#Preview {
    PokemonListView()
}
