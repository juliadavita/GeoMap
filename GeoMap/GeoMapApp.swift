import SwiftUI

/* MARK: TODO
 1. How to save current user location coordinates
 2. Optimise start monitoring geofence when app launces instead of resetting the region
 3.
 */

@main
struct GeoMapApp: App {
    
    @StateObject var listViewModel: ListViewModel = ListViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(listViewModel)
        }
    }
}

