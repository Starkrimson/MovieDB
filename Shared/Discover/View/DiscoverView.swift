//
//  DiscoverView.swift
//  MovieDB (iOS)
//
//  Created by allie on 1/7/2022.
//

import SwiftUI
import Kingfisher

struct DiscoverView: View {
    @State var keyword: String = ""
    @State var popularIndex: Int = 0
    @State var trendingIndex: Int = 0

    var body: some View {
        ScrollView {
            Header(keyword: $keyword)
            SectionTitle(title: "热门", selectedIndex: $popularIndex, labels: ["电视播出", "影院上映中"])
            CardRow()
            SectionTitle(title: "趋势", selectedIndex: $trendingIndex, labels: ["今日", "本周"])
            CardRow()
        }
        .frame(minWidth: 320)
        .navigationTitle("Discover")
    }
}

struct DiscoverView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverView()
    }
}
