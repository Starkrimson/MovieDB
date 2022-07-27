//
//  DetailView.swift
//  MovieDB
//
//  Created by allie on 14/7/2022.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct DetailView: View {
    let store: Store<DetailState, DetailAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                Header(state: viewStore.state)
                
                switch viewStore.status {
                case .loading: ProgressView()
                case .error(let error):
                    HStack {
                        Text(error.localizedDescription)
                    }
                case .normal:
                    switch viewStore.media.mediaType {
                    case .movie:
                        IfLetStore(
                            store.scope(state: \.movieState),
                            then: MovieDetailView.init
                        )
                        
                    case .tv:
                        IfLetStore(
                            store.scope(state: \.tvState),
                            then: TVDetailView.init
                        )
                        
                    case .person:
                        IfLetStore(
                            store.scope(state: \.personState),
                            then: PersonDetailView.init
                        )

                    default:
                        EmptyView()
                    }
                }
            }
            .navigationTitle(viewStore.media.displayName)
            .onAppear {
                viewStore.send(.fetchDetails(mediaType: viewStore.media.mediaType ?? .all))
            }
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(
            store: .init(
                initialState: .init(media: mockMedias[2]),
                reducer: detailReducer,
                environment: .init(mainQueue: .main, dbClient: .previews)
            )
        )
        .frame(height: 850)
    }
}