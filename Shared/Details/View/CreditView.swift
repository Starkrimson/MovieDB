//
//  CreditView.swift
//  MovieDB
//
//  Created by allie on 22/7/2022.
//

import SwiftUI
import ComposableArchitecture

struct CreditView: View {
    let store: StoreOf<CreditReducer>

    var body: some View {
        WithViewStore(store) {
            $0
        } content: { viewStore in
            ScrollView {
                ForEach(viewStore.combinedCredits) { credit in
                    GridLayout(estimatedItemWidth: 250) {
                        ForEach(credit.credits) { item in
                            NavigationLink(route: .detail(.init(media: .from(item)))) {
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
}

#if DEBUG
struct CreditView_Previews: PreviewProvider {
    static var previews: some View {
        CreditView(store: .init(
            initialState: .init(credit: mockMovies[0].credits ?? .init()),
            reducer: {
                CreditReducer()
            })
        )
    }
}
#endif
