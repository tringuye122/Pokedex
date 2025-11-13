import SwiftUI

struct PokemonCardView: View {
    
    let pokemon: Pokemon
    @EnvironmentObject var vm: PokemonListViewModel
    
    @State private var spriteURL: URL?
    
    // constants for consistent layout
    private let imageSize = CGSize(width: 120, height: 120)
    private let cardCornerRadius: CGFloat = 15
    private let cardPadding: CGFloat = 12
    
    var body: some View {
        VStack(spacing: 8) {
            Text(pokemon.name.capitalized)
                .font(.headline)
                .foregroundColor(.black)
                .lineLimit(1)
                .truncationMode(.tail)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            
                if let url = spriteURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: imageSize.width, height: imageSize.height)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: imageSize.width, height: imageSize.height)
                        case .failure:
                            Text("No Image")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(width: imageSize.width, height: imageSize.height)
                        @unknown default:
                            EmptyView()
                                .frame(width: imageSize.width, height: imageSize.height)
                        }
                    }
                } else {
                    ProgressView()
                        .frame(width: imageSize.width, height: imageSize.height)
                }
            }
        .padding(cardPadding)
        .frame(maxWidth: .infinity) // Fill the grid column width
        .background(
            RoundedRectangle(cornerRadius: cardCornerRadius)
                .fill(Color.white)
        )
        .shadow(radius: 5)
        .task {
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
