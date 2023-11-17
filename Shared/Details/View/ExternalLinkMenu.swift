//
//  ExternalLinkMenu.swift
//  MovieDB
//
//  Created by allie on 26/4/2023.
//

import SwiftUI
import ComposableArchitecture

struct ExternalLinkMenu: View {
    let displayName: String
    let store: Store<DetailReducer.DetailState, DetailReducer.Action>

    let externalLinkStore: StoreOf<ExternalLinkReducer> = .init(
        initialState: .init(), reducer: { ExternalLinkReducer() }
    )

    var body: some View {
        WithViewStore(store) {
            $0
        } content: { viewStore in
            WithViewStore(externalLinkStore) {
                $0
            } content: { externalLinkViewStore in
                Menu("VISIT".localized) {
                    switch viewStore.state {
                    case .movie(let movie):
                        buttons(externalLinks: movie.movie.externalLinks)
                    case .tvShow(let tvShow):
                        buttons(externalLinks: tvShow.tvShow.externalLinks)
                    case .person(let person):
                        buttons(externalLinks: person.person.externalLinks)
                    }
                    if !externalLinkViewStore.list.isEmpty {
                        Divider()
                    }
                    ForEach(externalLinkViewStore.list) { link in
                        if let name = link.name,
                           let url = URL(
                            string: link.url
                                .map { $0.replacingOccurrences(of: "*", with: displayName) }?
                                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                           ) {
                            Link(name, destination: url)
                        }
                    }
                }
                .onAppear {
                    externalLinkViewStore.send(.fetchExternalLinkList)
                }
            }
        }
    }

    func buttons(externalLinks: ExternalLinks) -> some View {
        Group {
            if let url = externalLinks.homepage {
                Link("HOMEPAGE".localized, destination: url)
            }
            if let url = externalLinks.tmdb {
                Link("TMDB", destination: url)
            }
            if let url = externalLinks.imdb {
                Link("IMDb", destination: url)
            }
            if let url = externalLinks.facebook {
                Link("Facebook", destination: url)
            }
            if let url = externalLinks.twitter {
                Link("Twitter", destination: url)
            }
            if let url = externalLinks.instagram {
                Link("Instagram", destination: url)
            }
        }
    }
}
