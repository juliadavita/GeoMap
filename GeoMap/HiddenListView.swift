//
//  HiddenListView.swift
//  GeoMap
//
//  Created by Frank Solleveld on 02/04/2022.
//

import SwiftUI

struct HiddenListView: View {
  @EnvironmentObject var listViewModel: ListViewModel
    var body: some View {
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
    }
}

struct HiddenListView_Previews: PreviewProvider {
    static var previews: some View {
        HiddenListView()
    }
}
