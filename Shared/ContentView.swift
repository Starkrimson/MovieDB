//
//  ContentView.swift
//  Shared
//
//  Created by allie on 30/6/2022.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        NavigationStack {
            DiscoverView(
                store: .init(
                    initialState: .init(),
                    reducer: discoverReducer,
                    environment: .init(mainQueue: .main, dbClient: .live)
                )
            )
            .toolbar {
                ToolbarItem {
                    Color.clear
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
