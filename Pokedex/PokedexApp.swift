import SwiftUI

@main
struct PokedexApp: App {

    init() {
        // ~50 MB memory, ~500 MB disk
        let memoryCapacity = 50 * 1_024 * 1_024
        let diskCapacity = 500 * 1_024 * 1_024
        URLCache.shared = URLCache(memoryCapacity: memoryCapacity,
                                   diskCapacity: diskCapacity,
                                   directory: nil)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
