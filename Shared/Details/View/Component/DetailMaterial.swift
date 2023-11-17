//
//  DetailMaterial.swift
//  MovieDB
//
//  Created by allie on 18/7/2022.
//

import SwiftUI

extension DetailView {

    struct Material: View {
        var detail: DetailModel

        private var map: [(String, String?)] {
            switch detail {
            case .movie(let movie):
                return [
                    ("ORIGINAL TITLE".localized, movie.originalTitle),
                    ("STATUS".localized, movie.status?.rawValue),
                    ("ORIGINAL LANGUAGE".localized, movie.originalLanguage),
                    ("BUDGET".localized, movie.budget.map { String(format: "$%d", locale: .current, $0) }),
                    ("REVENUE".localized, movie.revenue.map { String(format: "$%d", locale: .current, $0) })
                ]
            case .tvShow(let tvShow):
                return [
                    ("STATUS".localized, tvShow.status),
                    ("NETWORK".localized, tvShow.networks?.first?.name),
                    ("TYPE".localized, tvShow.type),
                    ("ORIGINAL LANGUAGE".localized, tvShow.originalLanguage)
                ]
            case .person(let person):
                return [
                    ("KNOWN FOR".localized, person.knownForDepartment),
                    ("GENDER".localized, person.gender?.description),
                    ("BIRTHDAY".localized, person.birthday),
                    ("PLACE OF BIRTH".localized, person.placeOfBirth),
                    ("ALSO KNOWN AS".localized, person.alsoKnownAs?.joined(separator: ", "))
                ]
            }
        }

        private var keywords: [Genre] {
            switch detail {
            case .movie(let movie):
                return movie.keywords?.keywords ?? []
            case .tvShow(let tvShow):
                return tvShow.keywords?.results ?? []
            case .person:
                return []
            }
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(map, id: \.0) { item in
                    VStack(alignment: .leading) {
                        Text(item.0)
                            .font(.headline)
                        Text(item.1 ?? "")
                    }
                }

                FlowLayout {
                    ForEach(keywords) { keyword in
                        NavigationLink {
                            DiscoverMediaView(store: .init(
                                initialState: .init(
                                    mediaType: detail.mediaType,
                                    name: keyword.name ?? "",
                                    filters: [URL.DiscoverQueryItem.keywords([keyword.id ?? 0])]
                                ),
                                reducer: { DiscoverMediaReducer() }
                            ))
                        } label: {
                            Text(keyword.name ?? "")
                        }
                    }
                }
            }
        }
    }
}

#if DEBUG
struct DetailFooter_Previews: PreviewProvider {
    static var previews: some View {
        DetailView.Material(detail: .movie(mockMovies[0]))

        DetailView.Material(detail: .tvShow(mockTVShows[0]))

        DetailView.Material(detail: .person(mockPeople[0]))
    }
}
#endif
