//
//  MovieCollectionView.swift
//  MovieDB
//
//  Created by allie on 27/7/2022.
//

import SwiftUI
import ComposableArchitecture

struct MovieCollectionView: View {
    let store: Store<MovieCollectionState, MovieCollectionAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                MediaHeader(
                    backdropPath: viewStore.belongsTo.backdropPath,
                    posterPath: viewStore.belongsTo.posterPath,
                    name: viewStore.belongsTo.name ?? ""
                )
                
                switch viewStore.status {
                case .loading:
                    ProgressView()
                case .error(let error):
                    ErrorTips(error: error)
                case .normal:
                    PartsView(parts: viewStore.collection?.parts ?? [])
                }
            }
            .navigationTitle(viewStore.belongsTo.name ?? "")
            .onAppear {
                viewStore.send(.fetchCollection)
            }
        }
    }
}

private struct PartsView: View {
    let parts: [Media]
    
    var body: some View {
        ForEach(parts) { media in
            HStack(spacing: 0) {
                URLImage(media.posterPath?.imagePath(.best(w: 260, h: 390)) ?? "")
                    .frame(width: 94, height: 141)
                    .cornerRadius(6)
                
                VStack(alignment: .leading) {
                    Text(media.displayName)
                        .font(.title)
                    
                    Text(media.releaseDate ?? "")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(media.overview ?? "")
                        .lineLimit(3)
                }
                .padding()
                
                Spacer(minLength: 0)
            }
            .padding(.leading)
        }
    }
}

struct MovieCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        MovieCollectionView(store: .init(
            initialState: .init(belongsTo: mockMovies[0].belongsToCollection ?? .init()),
            reducer: movieCollectionReducer,
            environment: .init(mainQueue: .main, dbClient: .previews)
        ))
        .frame(width: 720, height: 720)
        
        PartsView(parts: mockMedias)
    }
}
