//
//  MediaFilterMenu.swift
//  MovieDB
//
//  Created by allie on 11/11/2022.
//

import SwiftUI
import ComposableArchitecture

struct MediaFilterMenu: View {
    let store: StoreOf<MediaFilterReducer>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Menu("FILTERS".localized) {
                
                Menu("\("User Score".localized) \(viewStore.minimumUserScore) ~ \(viewStore.maximumUserScore)") {
                    SecondaryMenu(
                        title: "minimum".localized,
                        data: Array(0...10),
                        value: viewStore.binding(\.$minimumUserScore)
                    )
                    
                    SecondaryMenu(
                        title: "maximum".localized,
                        data: Array(1...10),
                        value: viewStore.binding(\.$maximumUserScore)
                    )
                }
                                
                SecondaryMenu(
                    title: "Minimum User Votes".localized,
                    data: (0...5).map { $0 * 100 },
                    value: viewStore.binding(\.$minimumUserVotes)
                )
                
                Button("Reset".localized) {
                    viewStore.send(.reset)
                }
            }
        }
    }
    
    struct SecondaryMenu: View {
        let title: String
        var data: [Int]
        @Binding var value: Int
        
        var picker: some View {
            Picker(
                "\(title) \(value)",
                selection: $value
            ) {
                ForEach(data, id: \.self) { i in
                    Text(i, format: .number)
                }
            }
        }
        
        var body: some View {
            #if os(macOS)
            picker
            #else
            Menu("\(title) \(value)") {
                picker
            }
            #endif
        }
    }
}

struct MediaFilterMenu_Previews: PreviewProvider {
    static var previews: some View {
        MediaFilterMenu(store: .init(
            initialState: .init(),
            reducer: MediaFilterReducer()
        ))
    }
}
