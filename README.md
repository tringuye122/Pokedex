# Pokedex

A SwiftUI Pokedex that fetches Pokémon from the public PokeAPI, displays them in a responsive grid with pagination, and caches per-Pokémon details (sprite URL and types).

- Platforms: iOS (SwiftUI, Swift Concurrency)
- Networking: URLSession + Codable
- Caching: In-memory + JSON file in Library/Caches

## Table of Contents
- Features
- Architecture
- Caching Strategy
- Technical Decisions
- File Guide
- Demo

## Features
- Grid of Pokémon with infinite scroll pagination (20 at a time)
- Tap a Pokémon to navigate to its detail page
- Per-Pokémon details fetched on demand (sprite URL, types)
- Lightweight persistent cache so sprites and types appear instantly on relaunch
- Basic error handling and loading indicators

## Architecture

The app follows a simple MVVM structure with lightweight services:

- Views (SwiftUI):
  - ContentView: Entry navigation stack
  - PokemonListView: Grid UI; triggers initial load and pagination
  - PokemonDetailView: Shows details for a selected Pokémon

- ViewModels:
  - PokemonListViewModel:
    - Holds list state, pagination flags, and error messages
    - Exposes helper APIs for fetching sprite URL and types for list items
    - Manages a persistent cache (in-memory + JSON file)
  - PokemonDetailViewModel:
    - Loads full details and species flavor text for a selected Pokémon

- Services:
  - APIService:
    - Fetches the Pokémon list (paged)
    - Fetches per-Pokémon details
    - Fetches species info for flavor text

- Models:
  - Pokemon, PokemonDetails, PokemonSpecies

## Caching Strategy

What is cached?
- spriteURLByID: [Int: URL] — the sprite URL for each Pokémon ID
- typesByID: [Int: [String]] — the ordered list of type names for each Pokémon ID

Where is it persisted?
- Library/Caches/PokemonListCaches.json (JSON file)
- Chosen because this data is derived from the network and safe to regenerate if purged by the system

How is it encoded?
- A private Codable wrapper (PersistedCaches) stores URLs as Strings:
  - [Int: String] for sprite URLs
  - [Int: [String]] for types

When is it read/written?
- Read once before the initial page load (so cached sprites/types show immediately)
- Written:
  - After initial load attempt (defer)
  - After next-page loads (defer)
  - Immediately after a details fetch populates caches

## Technical Decisions

- Swift Concurrency (async/await):
  - Clear, linear code for network calls and pagination
  - View models are @MainActor to keep @Published updates on the main thread

- Persistence via Codable JSON:
  - Lightweight and transparent for a small cache
  - No schema/migration overhead
  - Appropriate for Library/Caches; the system can purge and the app will recover

- Why not SwiftData (for now)?
  - The cache is small and simple (two dictionaries of derived data)
  - JSON is simpler and supports broader OS ranges

- ID extraction:
  - Pokémon ID is parsed from the PokeAPI URL (…/pokemon/{id}/)
  - This avoids introducing a separate model just for ID mapping

## File Guide

- PokedexApp.swift
  - Configures URLCache
  - Hosts ContentView

- ContentView.swift
  - NavigationStack entry
  - Routes to PokemonListView and Pokémon detail via NavigationLink

- PokemonListView.swift
  - Grid UI and infinite scroll trigger
  - Uses @StateObject PokemonListViewModel

- PokemonListViewModel.swift
  - Pagination state: pokemonList, isLoading, isLoadingNextPage, hasMore, errorMessage
  - Caches: spriteURLByID, typesByID
  - Persistence helpers: loadCachesFromDisk(), saveCachesToDisk()
  - Public APIs: resetAndLoadFirstPage(), loadNextPage(), spriteURL(for:), types(for:)

- PokemonDetailViewModel.swift
  - Loads PokemonDetails and PokemonSpecies flavor text concurrently

- APIService.swift
  - fetchPokemonList(limit:offset:)
  - fetchPokemonDetails(pokemonID:)
  - fetchPokemonSpecies(pokemonID:)

- Models:
  - Pokemon.swift (Pokemon, PokemonResponse)
  - PokemonDetails.swift (details, sprites, types, stats)
  - PokemonSpecies.swift (flavor text entries)

## Demo
![Pokedex_Demo (1)](https://github.com/user-attachments/assets/7fe423f4-a551-432c-9eff-70ab0456aeb5)

Notes:
- The app uses the public PokeAPI; no API key required
- The persistent cache lives at Library/Caches/PokemonListCaches.json inside the app sandbox. You can clear it by deleting the file.
