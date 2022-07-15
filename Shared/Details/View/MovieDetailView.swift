//
//  MovieDetailView.swift
//  MovieDB
//
//  Created by allie on 14/7/2022.
//

import SwiftUI
import ComposableArchitecture
import Kingfisher

struct MovieDetailView: View {
    let store: Store<DetailState, DetailAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                DetailView.Header(
                    backdropPath: viewStore.media.backdropPath,
                    posterPath: viewStore.media.posterPath
                )

                HStack(alignment: .lastTextBaseline) {
                    Text(viewStore.media.displayName)
                        .font(.largeTitle)
                    Text("(\(viewStore.movie?.releaseDate ?? ""))")
                        .font(.title3)
                }
                
                HStack {
                    ScoreView(score: viewStore.movie?.voteAverage ?? 0)
                    Text("用户评分")
                        .font(.title3.weight(.medium))
                }
                
                VStack {
                    Text("\(viewStore.movie?.releaseDate ?? "") · \(viewStore.movie?.runtime ?? 0)")
                    HStack {
                        ForEach(viewStore.movie?.genres ?? []) {
                            Button($0.name ?? "") {
                                
                            }
                        }
                    }
                }
                
                VStack(alignment: .leading) {
                    Text(viewStore.movie?.tagline ?? "")
                    Text("剧情简介")
                        .font(.title2.weight(.medium))
                        .padding(.vertical, 5)
                    Text(viewStore.movie?.overview ?? "")
                }
                
            }
            .navigationTitle(viewStore.media.displayName)
            .onAppear {
                viewStore.send(.fetchDetails(mediaType: .movie))
            }
        }
    }
}

struct MovieDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MovieDetailView(
            store: .init(
                initialState: .init(media: mockMedias[0]),
                reducer: detailReducer,
                environment: .init(mainQueue: .main, dbClient: .previews)
            )
        )
        .frame(minHeight: 700)
    }
}
