//
//  CreditView.swift
//  MovieDB
//
//  Created by allie on 22/7/2022.
//

import SwiftUI
import ComposableArchitecture

struct CreditView: View {
    let credit: Media.Credits
    
    private var combinedCredits: [Media.CombinedCredits]
    
    init(credit: Media.Credits) {
        self.credit = credit

        // MARK: - 演员列表
        self.combinedCredits = [
            .init(department: "Acting", credits: credit.cast?.map {
                .init(
                    year: "",
                    title: $0.name ?? "",
                    character: $0.character ?? "",
                    posterPath: $0.profilePath,
                    id: $0.id
                )
            } ?? []),
            .init(department: "Directing", credits: []),
            .init(department: "Writing", credits: [])
        ]
        
        // MARK: - 工作人员列表
        credit.crew?.forEach { crew in
            let item = Media.CombinedCredits.Credit(
                year: "",
                title: crew.name ?? "",
                character: crew.job?.localized ?? "",
                id: crew.id
            )
            if let index = combinedCredits.firstIndex(where: { $0.department == crew.department }) {
                if !combinedCredits[index].credits.contains(where: { $0.id == crew.id }) {
                    combinedCredits[index].credits.append(item)
                }
            } else {
                combinedCredits.append(
                    .init(department: crew.department ?? "", credits: [ item ])
                )
            }
        }
        
        combinedCredits.removeAll(where: { $0.credits.isEmpty })
    }
        
    var body: some View {
        ScrollView {
            ForEach(combinedCredits) { credit in
                GridLayout(estimatedItemWidth: 250) {
                    ForEach(credit.credits) { item in
                        NavigationLink {
                            DetailView(store: .init(
                                initialState: .init(media: .from(item)),
                                reducer: DetailReducer()
                            ))
                        } label: {
                            ProfileView(
                                axis: .horizontal,
                                profilePath: item.posterPath ?? "",
                                name: item.title,
                                job: item.character
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
                .header(credit.department.localized)
            }
            Color.clear
        }
        .navigationTitle("FULL CAST & CREW".localized)
    }
}

struct CreditView_Previews: PreviewProvider {
    static var previews: some View {
        CreditView(credit: mockMovies[0].credits ?? .init())
            .frame(width: 400)
    }
}
