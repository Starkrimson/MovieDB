//
//  KnownFor.swift
//  MovieDB
//
//  Created by allie on 22/7/2022.
//

import SwiftUI

extension PersonDetailView {
    
    struct KnownFor: View {
        let knownFor: [Media.Cast]
        
        var body: some View {
            VStack(alignment: .leading) {
                if !knownFor.isEmpty {
                    Text("代表作")
                        .font(.title2.weight(.medium))
                        .padding(.leading)
                    
                    ScrollView(.horizontal) {
                        HStack(alignment: .top) {
                            ForEach(knownFor) { item in
                                NavigationLink {
                                    DetailView(store: .init(
                                        initialState: .init(media: .from(item)),
                                        reducer: DetailReducer()
                                    ))
                                } label: {
                                    MediaItem(media: .from(item))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
}

struct KnownFor_Previews: PreviewProvider {
    static var previews: some View {
        PersonDetailView.KnownFor(knownFor: Array(mockPeople[0].combinedCredits?.cast?.prefix(10) ?? []))
    }
}
