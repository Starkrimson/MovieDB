//
//  ContentView.swift
//  Shared
//
//  Created by allie on 30/6/2022.
//

import SwiftUI
import CoreData
import ComposableArchitecture

struct ContentView: View {
    let store: StoreOf<MovieDBReducer> = .init(
        initialState: .init(),
        reducer: MovieDBReducer()
    )
    
    var body: some View {
        WithViewStore(store, observe: \.selectedTab) { viewStore in
            NavigationSplitView {
                List(
                    MovieDBReducer.Tab.allCases,
                    selection: viewStore.binding(send: MovieDBReducer.Action.tabSelected)
                ) { item in
                    Label(item.rawValue.localized, systemImage: item.systemImage)
                }
            } detail: {
                switch viewStore.state {
                case .discover:
                    DiscoverView(
                        store: .init(
                            initialState: .init(),
                            reducer: discoverReducer,
                            environment: .init(mainQueue: .main, dbClient: .live)
                        )
                    )
                    
                default:
                    Label(viewStore.state?.rawValue.localized ?? "", systemImage: viewStore.state?.systemImage ?? "")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
