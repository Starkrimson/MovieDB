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
                    List {
                        Section("\(viewStore.season?.name ?? "") \(viewStore.episodes.count) \("EPISODES".localized)") {
                            ForEach(viewStore.episodes) { episode in
                                EpisodeRow(episode: episode)
                            }
                        }
                    }
                }
            }
            .navigationTitle(viewStore.showName)
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
                    Text("\(episode.episodeNumber ?? 0) \(episode.name ?? "")")
                        .font(.headline)
                    
                    Group {
                        Text(episode.airDate ?? "")
                        Text("\(episode.runtime ?? 0)m")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(episode.overview ?? "")
                }
                .padding(.leading)
                .padding(.vertical, 6)
                
                Spacer(minLength: 0)
            }
            
            Divider()
        }
    }
}

struct EpisodeView_Previews: PreviewProvider {
    static var previews: some View {
        EpisodeList(store: .init(
            initialState: .init(tvID: 1, seasonNumber: 2, showName: "Show", status: .normal),
            reducer: SeasonReducer()
        ))
        .frame(minWidth: 730, minHeight: 300)
        
        EpisodeRow(episode: mockTVShows[0].seasons![0].episodes![0])
    }
}
