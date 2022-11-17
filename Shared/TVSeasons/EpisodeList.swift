//
//  EpisodeList.swift
//  MovieDB
//
//  Created by allie on 28/7/2022.
//

import SwiftUI
import ComposableArchitecture

struct EpisodeList: View {
    let store: StoreOf<SeasonReducer>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            Group {
                switch viewStore.status {
                case .loading:
                    ProgressView()
                    
                case .error(let error):
                    ErrorTips(error: error)
                    
                case .normal:
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            if let overview = viewStore.season?.overview, !overview.isEmpty {
                                Text(overview)
                                    .padding([.horizontal, .top])
                            }
                            
                            if let cast = viewStore.season?.credits?.cast, !cast.isEmpty {
                                ScrollView(.horizontal) {
                                    HStack {
                                        ForEach(cast) { item in
                                            ProfileView(
                                                profilePath: item.profilePath ?? "",
                                                name: item.name ?? "",
                                                job: item.character ?? ""
                                            )
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                                .header("SEASON REGULARS".localized)
                            }
                            
                            VStack {
                                ForEach(viewStore.episodes) { episode in
                                    NavigationLink {
                                        EpisodeView(store: .init(
                                            initialState: .init(tvID: viewStore.tvID, episode: episode),
                                            reducer: EpisodeReducer()
                                        ))
                                    } label: {
                                        EpisodeRow(episode: episode)
                                            .padding(.horizontal)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .header("\(viewStore.episodes.count) \("EPISODES".localized)")
                        }
                    }
                }
            }
            .navigationTitle(viewStore.showName + " \(viewStore.season?.name ?? "")")
            .task {
                viewStore.send(.fetchSeason)
            }
        }
    }
}

struct EpisodeRow: View {
    let episode: Episode

    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 0) {
                URLImage(episode.stillPath?.imagePath(.best(w: 454, h: 254)) ?? "")
                    .frame(width: 227, height: 127)
                    .cornerRadius(6)
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("\(episode.episodeNumber ?? 0) \(episode.name ?? "")")
                            .font(.headline)
                        
                        Spacer()
                        ScoreView(score: episode.voteAverage ?? 0)
                        Image(systemName: "chevron.right")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Group {
                        Text(episode.airDate ?? "")
                        Text("\(episode.runtime ?? 0)m")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(episode.overview ?? "")
                        .lineLimit(4)
                }
                .padding(.leading)
                .padding(.vertical, 6)
                
                Spacer(minLength: 0)
            }
            
            Divider()
        }
    }
}

struct EpisodeList_Previews: PreviewProvider {
    static var previews: some View {
        EpisodeList(store: .init(
            initialState: .init(tvID: 1, seasonNumber: 2, showName: "Show", status: .normal),
            reducer: SeasonReducer()
        ))
        .frame(minWidth: 730, minHeight: 300)
        
        EpisodeRow(episode: mockTVShows[0].seasons![0].episodes![0])
    }
}
