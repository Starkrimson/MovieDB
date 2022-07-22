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
                    VStack(alignment: .leading) {
                        Text(credit.department)
                            .font(.title2.weight(.medium))
                        ForEach(credit.credits) { item in
                            HStack {
                                Text(item.year)
                                NavigationLink(value: item) {
                                    Text(item.title)
                                }
                                .buttonStyle(.plain)
                                Text(item.character)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

