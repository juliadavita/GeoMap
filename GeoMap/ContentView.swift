import SwiftUI
import MapKit

// ContentView contains everything 'design' related

struct ContentView: View {
    @StateObject private var viewModel = MapViewModel()
    
    @EnvironmentObject var listViewModel: ListViewModel
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationView {
            VStack {
                HiddenListView()
                  .opacity(viewModel.isUserInRegion() ? 1 : 0)
//              Text(viewModel.getCoordinatesForGeofence())
                Map(coordinateRegion: $viewModel.region, showsUserLocation: true,
                    annotationItems: [MapDefaults.location]
                ) { location in
                    MapMarker(coordinate: location.coordinate)
                }
                .padding()

                if viewModel.isUserInRegion() {
                    Text("You can see your list now! 🥳")
                        .padding(10)
                } else {
                    Text("You are not in the correct region to see the list 😢")
                        .frame(width: 330, height: 50, alignment: .center)
                        .multilineTextAlignment(.center)
                }
                    

                Button(
                    action: {
                        viewModel.saveRegion()
                    },
                    label: {
                        Text("Set new location for secret list")
                    }
                )
                Spacer()
            }
            .navigationTitle("Secret list")
            .toolbar(content: {
              ToolbarItem(
                placement: .navigationBarLeading,
                content: {
                  EditButton()
                }
              )
              ToolbarItem(
                placement: .navigationBarTrailing,
                content: {
                  Button(
                      action: {
                          viewModel.checkLocationAuthorization()
                      },
                      label: {
                          if viewModel.locationServicesEnabled {
                              Image(systemName: "location.fill")
                          } else {
                              Image(systemName: "location")
                          }
                      }
                  )
                }
              )
            })
        }
        .onChange(of: scenePhase) { phase in
          switch phase {
          case .background:
            break
          case .inactive:
            break
          case .active:
            viewModel.clearNotifications()
          @unknown default:
            break
          }
        }
        .onAppear(perform: viewModel.clearNotifications)
        .onAppear(perform: viewModel.notificationRequest)
        .onAppear(perform: viewModel.checkForLocationPermissions)
        .onAppear(perform: viewModel.saveRegion)
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .environmentObject(ListViewModel())
        }
    }
        
}


