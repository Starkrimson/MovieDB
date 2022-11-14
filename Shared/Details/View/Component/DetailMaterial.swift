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
            case .tv(let tv):
                return [
                    ("STATUS".localized, tv.status),
                    ("NETWORK".localized, tv.networks?.first?.name),
                    ("TYPE".localized, tv.type),
                    ("ORIGINAL LANGUAGE".localized, tv.originalLanguage)
                ]
            case .person(let person):
                return [
                    ("KNOWN FOR".localized, person.knownForDepartment),
                    ("GENDER".localized, person.gender?.description),
                    ("BIRTHDAY".localized, person.birthday),
                    ("PLACE OF BIRTH".localized, person.placeOfBirth),
                ]
            }
        }
        
        private var keywords: [Genre] {
            switch detail {
            case .movie(let movie):
                return movie.keywords?.keywords ?? []
            case .tv(let tv):
                return tv.keywords?.results ?? []
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
                                    filters: [.keywords([keyword.id ?? 0])]
                                ),
                                reducer: DiscoverMediaReducer()
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

struct DetailFooter_Previews: PreviewProvider {
    static var previews: some View {
        DetailView.Material(detail: .movie(mockMovies[0]))
        
        DetailView.Material(detail: .tv(mockTVShows[0]))
        
        DetailView.Material(detail: .person(mockPeople[0]))
    }
}
