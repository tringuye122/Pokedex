import SwiftUI

struct PokemonDetailView: View {
    let pokemonID: Int
    
    @StateObject private var vm = PokemonDetailViewModel()
    
    private var primaryTypeColor: Color {
        guard
            let types = vm.details?.types,
            let primary = types.sorted(by: { $0.slot < $1.slot }).first?.type.name
        else {
            return Color.gray.opacity(0.3)
        }
        return PokemonTypeColor.color(for: primary)
    }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    primaryTypeColor.opacity(0.95),
                    primaryTypeColor.opacity(0.55)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Foreground content 
            ScrollView {
                VStack(spacing: 20) {
                    if vm.isLoading {
                        ProgressView("Loading...")
                            .tint(.white)
                            .padding(.top, 40)
                    } else if let details = vm.details {
                        // Header
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .firstTextBaseline) {
                                Text(details.name.capitalized)
                                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                                    .foregroundStyle(.white)
                                    .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 1)
                                
                                Spacer()
                                
                                Text("#\(details.id)")
                                    .font(.title3.weight(.bold))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule(style: .continuous)
                                            .fill(.ultraThinMaterial)
                                            .opacity(0.7)
                                    )
                                    .foregroundStyle(.white.opacity(0.95))
                            }
                            
                            if !details.types.isEmpty {
                                HStack(spacing: 8) {
                                    ForEach(details.types.sorted(by: { $0.slot < $1.slot }), id: \.slot) { entry in
                                        Text(entry.type.name.capitalized)
                                            .font(.caption.weight(.semibold))
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(
                                                Capsule(style: .continuous)
                                                    .fill(PokemonTypeColor.color(for: entry.type.name).opacity(0.9))
                                            )
                                            .overlay(
                                                Capsule(style: .continuous)
                                                    .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
                                            )
                                            .foregroundStyle(.white)
                                            .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                                    }
                                }
                            }
                            
                            // Sprite
                            if let url = URL(string: details.sprites.front_default) {
                                HStack {
                                    Spacer(minLength: 0)
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .tint(.white)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .frame(maxWidth: 220, maxHeight: 220)
                                                .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 3)
                                        case .failure:
                                            Text("Image unavailable")
                                                .foregroundStyle(.white.opacity(0.9))
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                    Spacer(minLength: 0)
                                }
                                .padding(.top, 6)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        // Description 
                        if let desc = vm.descriptionText, !desc.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Description")
                                    .font(.headline.weight(.bold))
                                    .foregroundStyle(.white)
                                Text(desc)
                                    .font(.body)
                                    .foregroundStyle(.white)
                                    .multilineTextAlignment(.leading)
                                    .lineSpacing(3)
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.black.opacity(0.25))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal)
                            .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 3)
                        }
                        
                        // Stats
                        if !details.stats.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Base Stats")
                                    .font(.headline.weight(.bold))
                                    .foregroundStyle(.white)
                                
                                VStack(spacing: 10) {
                                    ForEach(details.stats, id: \.stat.name) { stat in
                                        VStack(alignment: .leading, spacing: 6) {
                                            HStack {
                                                Text(stat.stat.name.replacingOccurrences(of: "-", with: " ").capitalized)
                                                    .font(.subheadline.weight(.semibold))
                                                    .foregroundStyle(.white.opacity(0.95))
                                                Spacer()
                                                Text("\(stat.base_stat)")
                                                    .font(.subheadline.monospacedDigit())
                                                    .foregroundStyle(.white.opacity(0.95))
                                            }
                                            
                                            GeometryReader { geo in
                                                let maxWidth = geo.size.width
                                                let normalized = min(CGFloat(stat.base_stat) / 200.0, 1.0)
                                                ZStack(alignment: .leading) {
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .fill(Color.white.opacity(0.15))
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .fill(Color.white.opacity(0.9))
                                                        .frame(width: maxWidth * normalized)
                                                }
                                            }
                                            .frame(height: 10)
                                        }
                                    }
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.black.opacity(0.25))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal)
                            .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 3)
                        }
                    } else if let errorMessage = vm.errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .padding(.horizontal)
                    } else {
                        Text("No details")
                            .foregroundStyle(.white.opacity(0.9))
                            .padding(.horizontal)
                    }
                }
                .padding(.bottom, 24)
            }
            .task {
                await vm.loadPokemonDetails(pokemonID: pokemonID)
            }
        }
    }
}

#Preview {
    PokemonDetailView(pokemonID: 25)
}
