//
//  SortMenu.swift
//  MovieDB
//
//  Created by allie on 24/5/2023.
//

import SwiftUI
import ComposableArchitecture

struct SortMenu: View {
    let store: StoreOf<SortReducer>

    var body: some View {
        WithViewStore(store) {
            $0
        } content: { viewStore in
            Menu {
                Picker(
                    "FILTER BY".localized,
                    selection: viewStore.binding(\.$sortByKey)
                ) {
                    ForEach(viewStore.keys, id: \.self) { key in
                        Text(viewStore.state.localizedKey(key))
                    }
                }
                .pickerStyle(.inline)

                Picker(
                    "ORDER".localized,
                    selection: viewStore.binding(\.$ascending)
                ) {
                    ForEach([true, false], id: \.self) {
                        Text($0 ? "ASCENDING".localized : "DESCENDING".localized)
                    }
                }
                .pickerStyle(.inline)
            } label: {
                Text(viewStore.state.localizedKey(viewStore.sortByKey.localized)
                    + " "
                    + (viewStore.ascending ? "ASCENDING".localized : "DESCENDING".localized))
            }
        }
    }
}

struct SortMenu_Previews: PreviewProvider {
    static var previews: some View {
        SortMenu(store: .init(
            initialState: .init(),
            reducer: SortReducer()
        ))
    }
}

struct SortReducer: ReducerProtocol {

    struct State: Equatable {
        @BindingState var sortByKey = "dateAdded"
        @BindingState var ascending: Bool = false

        var keys = [
            "dateAdded",
            "title",
            "releaseDate"
        ]

        func localizedKey(_ key: String) -> String {
            switch key {
            case "dateAdded":
                return "DATE ADDED".localized
            case "title":
                return "NAME".localized
            case "releaseDate":
                return "RELEASE DATE".localized
            default:
                return "Unexpected"
            }
        }
    }

    enum Action: Equatable, BindableAction {
        case binding(_ action: BindingAction<State>)
    }

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { _, action in
            switch action {
            case .binding:
                return .none
            }
        }
    }
}
