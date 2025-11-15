import SwiftUI

struct PokemonCardView: View {
    let pokemon: Pokemon

    @EnvironmentObject private var vm: PokemonListViewModel
    @State private var spriteURL: URL?
    @State private var types: [String] = []

    var primaryTypeColor: Color {
        if let first = types.first {
            return PokemonTypeColor.color(for: first)
        } else {
            return Color.gray.opacity(0.3)
        }
    }

    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(primaryTypeColor.gradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)

            // Foreground
            VStack(spacing: 8) {
                // Sprite
                Group {
                    if let spriteURL {
                        AsyncImage(url: spriteURL) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(.secondary)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        ProgressView()
                    }
                }
                .frame(height: 80)
                
                Text(pokemon.name.capitalized)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.25), radius: 1, x: 0, y: 1)

                if !types.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(types, id: \.self) { type in
                            Text(type.capitalized)
                                .font(.caption2.weight(.semibold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(PokemonTypeColor.color(for: type).opacity(0.85))
                                )
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.15), radius: 1, x: 0, y: 1)
                        }
                    }
                    .padding(.top, 2)
                } else {
                    // Placeholder to keep layout consistent
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 16)
                }
            }
            .padding(12)
        }
        .frame(height: 170)
        .task {
            if spriteURL == nil {
                spriteURL = await vm.spriteURL(for: pokemon)
            }
            if types.isEmpty {
                types = await vm.types(for: pokemon)
            }
        }
    }
}

#Preview {
    let vm = PokemonListViewModel()
    return PokemonCardView(pokemon: Pokemon(name: "pikachu", url: "https://pokeapi.co/api/v2/pokemon/25/"))
        .environmentObject(vm)
        .frame(width: 180)
        .padding()
        .background(Color.black.opacity(0.1))
}
