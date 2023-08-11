//
//  EpisodeView.swift
//  MovieDB
//
//  Created by allie on 17/11/2022.
//

import SwiftUI
import ComposableArchitecture
import MovieDependencies

struct EpisodeView: View {
    let store: StoreOf<EpisodeReducer>

    var body: some View {
        WithViewStore(store) {
            $0
        } content: { viewStore in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text(viewStore.episode.episodeNumber ?? 0, format: .number)
                        Text(viewStore.episode.name ?? "")
                            .font(.title3)
                        .fontWeight(.medium)
                        ScoreView(score: viewStore.episode.voteAverage ?? 0)
                    }
                    .padding()
                    Text(viewStore.episode.overview ?? "")
                        .padding(.horizontal)

                    if let crew = viewStore.episode.crew?.unique(\.id), !crew.isEmpty {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(crew) { item in
                                    NavigationLink {
                                        DetailView(store: .init(
                                            initialState: .init(media: .from(item)),
                                            reducer: { DetailReducer() }
                                        ))
                                    } label: {
                                        ProfileView(
                                            axis: .horizontal,
                                            profilePath: item.profilePath ?? "",
                                            name: item.name ?? "",
                                            job: item.job?.localized ?? ""
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .header("CREW".localized)
                    }

                    if let guestStars = viewStore.episode.guestStars, !guestStars.isEmpty {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(guestStars) { item in
                                    NavigationLink {
                                        DetailView(store: .init(
                                            initialState: .init(media: .from(item)),
                                            reducer: { DetailReducer() }
                                        ))
                                    } label: {
                                        ProfileView(
                                            profilePath: item.profilePath ?? "",
                                            name: item.name ?? "",
                                            job: item.character ?? ""
                                        )
                                    }
                                    .buttonStyle(.plain)

                                }
                            }
                            .padding(.horizontal)
                        }
                        .header("GUEST STARS".localized)
                    }

                    if let images = viewStore.episode.images?.stills,
                       !images.isEmpty {
                        GridLayout(estimatedItemWidth: 375) {
                            ForEach(images) { item in
                                NavigationLink {
                                    ImageBrowser(image: item)
                                } label: {
                                    URLImage(item.filePath?.imagePath(.best(width: 454, height: 254)))
                                        .aspectRatio(item.aspectRatio ?? 1, contentMode: .fill)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                        .header("EPISODE IMAGES".localized)
                    }
                }
                .padding(.bottom)
            }
            .navigationTitle(viewStore.episode.name ?? "")
            .task {
                viewStore.send(.fetchEpisode)
            }
        }
    }
}

#if DEBUG
struct EpisodeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            EpisodeView(store: .init(
                initialState: .init(tvID: 1, episode: mockTVShows[0].seasons![0].episodes![0]),
                reducer: { EpisodeReducer() }
            ))
        }
    }
}
#endif
