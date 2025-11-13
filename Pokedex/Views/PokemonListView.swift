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
                if vm.isLoading {
                    ProgressView("Loading...")
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(vm.pokemonList, id: \.name) { pokemon in
                                // Use the ID for navigation
                                if let id = vm.id(for: pokemon) {
                                    NavigationLink(value: id) {
                                        PokemonCardView(pokemon: pokemon)
                                            .environmentObject(vm)
                                    }
                                } else {
                                    // Fallback: show card without navigation if ID can't be parsed
                                    PokemonCardView(pokemon: pokemon)
                                        .environmentObject(vm)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                if let errorMessage = vm.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle(Text("Pokemon List"))
            .task {
                await vm.loadPokemonlist()
            }
            // Map Int IDs to the detail view
            .navigationDestination(for: Int.self) { pokemonID in
                PokemonDetailView(pokemonID: pokemonID)
            }
        }
    }
}

#Preview {
    PokemonListView()
}
