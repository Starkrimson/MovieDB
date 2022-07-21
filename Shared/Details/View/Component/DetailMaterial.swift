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
                    ("原产地片名", movie.originalTitle),
                    ("状态", movie.status?.rawValue),
                    ("原始语言", movie.originalLanguage),
                    ("预算", movie.budget.map { String(format: "$%d", locale: .current, $0) }),
                    ("票房", movie.revenue.map { String(format: "$%d", locale: .current, $0) })
                ]
            case .tv(let tv):
                return [
                    ("状态", tv.status),
                    ("电视网", tv.networks?.first?.name),
                    ("类型", tv.type),
                    ("原始语言", tv.originalLanguage)
                ]
            case .person(let person):
                return [
                    ("代表作", person.knownForDepartment),
                    ("性别", person.gender?.description),
                    ("生日", person.birthday),
                    ("出生地", person.placeOfBirth),
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
                
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(keywords) { keyword in
                            Button {
                                
                            } label: {
                                Text(keyword.name ?? "")
                            }
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
