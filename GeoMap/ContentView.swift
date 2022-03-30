import SwiftUI
import MapKit

// ContentView contains everything 'design' related

struct ContentView: View {
    @StateObject private var viewModel = MapViewModel()
    
    @EnvironmentObject var listViewModel: ListViewModel

    var body: some View {
        NavigationView {
            VStack {
                List{
                    ForEach(listViewModel.items) { item in
                        ListRowView(item: item)
                            .onTapGesture {
                                withAnimation(.linear) {
                                    listViewModel.updateItem(item: item)
                                }
                            }
                    }
                    .onDelete(perform: listViewModel.deleteItem)
                    .onMove(perform: listViewModel.moveItem)
                }
                .listStyle(PlainListStyle())
                EditButton()
                Spacer()
                Map(coordinateRegion: $viewModel.region, showsUserLocation: true,
                    annotationItems: [MapDefaults.location]
                ) { location in
                    MapMarker(coordinate: location.coordinate)
                }
                .padding()

                if viewModel.isUserInRegion() {
                    Text("You can see your secret pics now.")
                } else {
                    Text("You are not in the geofence region.")
                }

                Button(
                    action: {
                        viewModel.saveRegion()
                    },
                    label: {
                        Text("Set Current Location as Monitoring Region")
                    }
                )
                Spacer()
            }
            .navigationTitle("Where are the pics?")
            .navigationBarItems(
                leading: NavigationLink("Add", destination: AddView()),
                trailing:
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
            )
        }
        .onAppear(perform: viewModel.checkForLocationPermissions)
        .onAppear(perform: viewModel.saveRegion)
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ListViewModel())
    }
        
}


