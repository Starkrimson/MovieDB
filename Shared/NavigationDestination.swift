//
//  NavigationDestination.swift
//  MovieDB
//
//  Created by allie on 28/7/2022.
//

import Foundation
import SwiftUI

enum NavigationDestination: Hashable {
    case seasonList(showName: String, seasons: [Season])
}

extension View {

    func navigation<C>(
        @ViewBuilder destination: @escaping (NavigationDestination) -> C
    ) -> some View where C : View {
        navigationDestination(for: NavigationDestination.self, destination: destination)
    }
}

extension NavigationLink where Destination == Never {

    init(destination: NavigationDestination, label: () -> Label) {
        self.init(value: destination, label: label)
    }
}
