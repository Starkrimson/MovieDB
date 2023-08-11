//
//  MovieCollectionView.swift
//  MovieDB
//
//  Created by allie on 27/7/2022.
//

import SwiftUI
import ComposableArchitecture

struct MovieCollectionView: View {
    let store: StoreOf<MovieCollectionReducer>

    var body: some View {
        WithViewStore(store) { $0 } content: { viewStore in
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
                    ForEachStore(store.scope(
                        state: \.movies,
                        action: MovieCollectionReducer.Action.movie)
                    ) { detailStore in
                        WithViewStore(detailStore) {
                            $0
                        } content: { detailViewStore in
                            NavigationLink {
                                DetailView(store: detailStore)
                            } label: {
                                Part(media: detailViewStore.media)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .navigationTitle(viewStore.belongsTo.name ?? "")
            .task {
                viewStore.send(.fetchCollection)
            }
        }
    }
}

private struct Part: View {
    let media: Media

    var body: some View {
        HStack(spacing: 0) {
            URLImage(media.posterPath?.imagePath(.best(width: 260, height: 390)) ?? "")
                .frame(width: 94, height: 141)
                .cornerRadius(6)

            VStack(alignment: .leading) {
                HStack {
                    Text(media.displayName)
                        .font(.title)

                    Spacer()
                    ScoreView(score: media.voteAverage ?? 0)
                    Image(systemName: "chevron.right")
                }

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

#if DEBUG
struct MovieCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        MovieCollectionView(store: .init(
            initialState: .init(belongsTo: mockMovies[0].belongsToCollection ?? .init()),
            reducer: { MovieCollectionReducer() }
        ))
        .frame(width: 720, height: 720)
    }
}
#endif
