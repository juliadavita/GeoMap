import SwiftUI
import MapKit

// ContentView contains everything 'design' related

struct ContentView: View {
    @StateObject private var viewModel = MapViewModel()
    
    @EnvironmentObject var listViewModel: ListViewModel

    var body: some View {
        NavigationView {
            VStack {
                if listViewModel.items.isEmpty {
                    Text("You don't want to find anything? Let's add something new to your list to find!")
                        .offset(x: -17)
                        
                } else {
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
                }
                NavigationLink("Add an item 😏✨", destination: AddView())
                    .foregroundColor(.white)
                    .font(.headline)
                    .frame(height: 55)
                    .frame(maxWidth: . infinity)
                    .background(Color.accentColor)
                    .cornerRadius(10)
                    .padding(10)
                Spacer()
                Map(coordinateRegion: $viewModel.region, showsUserLocation: true,
                    annotationItems: [MapDefaults.location]
                ) { location in
                    MapMarker(coordinate: location.coordinate)
                }
                .padding()

                if viewModel.isUserInRegion() {
                    Text("You can see the hidden objects now.")
                        .padding(10)
                } else {
                    Text("You are not in the correct region to find something 😢")
                        .frame(width: 330, height: 50, alignment: .center)
                        .multilineTextAlignment(.center)
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
            .navigationTitle("Hide 'n Seek")
            .navigationBarItems(
                leading: EditButton(),
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
        Group {
            ContentView()
                .environmentObject(ListViewModel())
        }
    }
        
}


