//
//  ExternalLinkMenu.swift
//  MovieDB
//
//  Created by allie on 26/4/2023.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

struct ExternalLinkMenu: View {
    let displayName: String
    let detailState: DetailReducer.DetailState?

    @Query var customLinks: [ExternalLink]

    var body: some View {
        Menu("VISIT".localized) {
            if let detailState {
                switch detailState {
                case .movie(let movie):
                    buttons(externalLinks: movie.movie.externalLinks)
                case .tvShow(let tvShow):
                    buttons(externalLinks: tvShow.tvShow.externalLinks)
                case .person(let person):
                    buttons(externalLinks: person.person.externalLinks)
                }
                if !customLinks.isEmpty {
                    Divider()
                }
            }
            ForEach(customLinks) { link in
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
