import SwiftUI

enum PokemonTypeColor {
    static func color(for typeName: String) -> Color {
        switch typeName.lowercased() {
        case "normal": return Color(.sRGB, red: 0.66, green: 0.66, blue: 0.5, opacity: 1)
        case "fire": return Color(red: 0.95, green: 0.45, blue: 0.3)
        case "water": return Color(red: 0.4, green: 0.6, blue: 0.95)
        case "electric": return Color(red: 0.98, green: 0.85, blue: 0.35)
        case "grass": return Color(red: 0.45, green: 0.8, blue: 0.45)
        case "ice": return Color(red: 0.6, green: 0.85, blue: 0.95)
        case "fighting": return Color(red: 0.8, green: 0.3, blue: 0.3)
        case "poison": return Color(red: 0.65, green: 0.3, blue: 0.65)
        case "ground": return Color(red: 0.9, green: 0.8, blue: 0.5)
        case "flying": return Color(red: 0.6, green: 0.7, blue: 0.95)
        case "psychic": return Color(red: 0.98, green: 0.5, blue: 0.7)
        case "bug": return Color(red: 0.65, green: 0.8, blue: 0.35)
        case "rock": return Color(red: 0.75, green: 0.7, blue: 0.45)
        case "ghost": return Color(red: 0.5, green: 0.45, blue: 0.7)
        case "dragon": return Color(red: 0.5, green: 0.45, blue: 0.9)
        case "dark": return Color(red: 0.45, green: 0.35, blue: 0.3)
        case "steel": return Color(red: 0.7, green: 0.7, blue: 0.8)
        case "fairy": return Color(red: 0.95, green: 0.7, blue: 0.9)
        default: return Color.gray.opacity(0.6)
        }
    }
}

