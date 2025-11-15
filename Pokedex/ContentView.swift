import SwiftUI

enum Route: Hashable {
    case list
}

struct ContentView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color.red.opacity(0.9), Color.red.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 32) {
                    Text("Pokedex")
                        .font(.system(size: 56, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
                        .padding(.top, 40)

                    Spacer()

                    Image("pokeball")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 220)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 6)

                    Spacer()

                    Button {
                        path.append(Route.list)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title2.weight(.bold))
                            Text("Continue")
                                .font(.title3.weight(.bold))
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(
                            Capsule(style: .continuous)
                                .fill(.ultraThinMaterial)
                                .opacity(0.9)
                        )
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(Color.white.opacity(0.25), lineWidth: 1)
                        )
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 3)
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .list:
                    PokemonListView()
                        .navigationBarBackButtonHidden(true)
                        .navigationTitle("Pokedex")
                        .navigationBarTitleDisplayMode(.large)
                }
            }
            .navigationDestination(for: Int.self) { pokemonID in
                PokemonDetailView(pokemonID: pokemonID)
            }
        }
    }
}

#Preview {
    ContentView()
}
