//
//  SettingsView.swift
//  MovieDB
//
//  Created by allie on 27/4/2023.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            ExternalLinkSettingView(
                store: .init(
                    initialState: .init(),
                    reducer: ExternalLinkReducer()
                )
            )
        }
        .frame(minWidth: 375, minHeight: 300)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .previewLayout(.fixed(width: 375, height: 700))
    }
}
