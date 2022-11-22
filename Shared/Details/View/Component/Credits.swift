//
//  Credits.swift
//  MovieDB
//
//  Created by allie on 22/7/2022.
//

import SwiftUI
import ComposableArchitecture

extension PersonDetailView {

    struct Credits: View {
        let credits: IdentifiedArrayOf<Media.CombinedCredits>

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(credits) { credit in
                    ForEach(credit.credits) { item in
                        HStack {
                            Text(item.year)
                                .frame(minWidth: 40)
                            NavigationLink {
                                DetailView(store: .init(
                                    initialState: .init(media: .from(item)),
                                    reducer: DetailReducer()
                                ))
                            } label: {
                                Text(item.title)
                            }
                            .buttonStyle(.plain)
                            Text(item.character)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                    .header(credit.department.localized)
                }
            }
        }
    }
}
