//
//  Modifiers.swift
//  MovieDB
//
//  Created by allie on 17/11/2022.
//

import SwiftUI

extension View {
    func header(_ text: String) -> some View {
        header {
            Text(text)
        }
    }
    
    func header<Header: View>(@ViewBuilder _ content: @escaping () -> Header) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
                .font(.title3.weight(.medium))
                .padding([.horizontal, .top])
                .padding(.bottom, 6)
            self
        }
    }
    
    func footer(_ key: LocalizedStringKey) -> some View {
        footer {
            Text(key)
        }
    }

    func footer<Footer: View>(@ViewBuilder _ content: @escaping () -> Footer) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            self
            content()
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
                .padding(.top, 6)
        }
    }
}
