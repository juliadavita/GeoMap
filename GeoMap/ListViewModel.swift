//
//  ListViewModel.swift
//  GeoMap
//
//  Created by Julia Lanu on 30/03/2022.
//
// All the logic for the list part (All Crud functions)

import Foundation

class ListViewModel: ObservableObject {
    @Published var items: [ItemModel] = []
    
    init() {
        getItems()
    }
    
    func getItems() {
        let newItems = [
            ItemModel(title: "Found the first picture", isCompleted: false),
            ItemModel(title: "Found the second picture", isCompleted: true),
            ItemModel(title: "Fount the third picture", isCompleted: false),
            ]
        items.append(contentsOf: newItems)
        
    }
    
    func deleteItem(indexSet: IndexSet) {
        items.remove(atOffsets: indexSet)
    }
    
    func moveItem(from: IndexSet, to: Int){
        items.move(fromOffsets: from, toOffset: to)
    }
    
    func addItem(title:String){
        let newItem = ItemModel(title: title, isCompleted: false)
        items.append(newItem)
    }
    
    func updateItem(item: ItemModel) {
        if let index = items.firstIndex(where: { $0.id == item.id}) {
            items[index] = item.updateCompletion()
        }
    }
}
