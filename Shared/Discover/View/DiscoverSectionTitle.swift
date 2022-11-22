//
//  DiscoverSectionTitle.swift
//  MovieDB
//
//  Created by allie on 1/7/2022.
//

import SwiftUI

extension DiscoverView {

    struct SectionTitle: View {
        let title: String
        @Binding var selectedIndex: Int

        var labels: [String] = []

        var body: some View {
            HStack {
                // MARK: - Section title
                Text(title)
                    .font(.title2)
                    .fontWeight(.medium)

                // MARK: - segmented
                Picker("", selection: $selectedIndex) {
                    ForEach(0..<labels.count, id: \.self) { index in
                        Text(labels[index])
                    }
                }
                .pickerStyle(.segmented)

                Spacer()
            }
            .padding(.horizontal)
        }
    }
}

struct DiscoverSectionTitle_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverView.SectionTitle(title: "热门", selectedIndex: .constant(0), labels: ["电视播出", "影院上映中"])
    }
}
