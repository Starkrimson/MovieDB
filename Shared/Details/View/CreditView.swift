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
    
    private let crew: [(String, [Media.Crew])]
    
    #if !os(macOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    #endif
    
    init(credit: Media.Credits) {
        self.credit = credit
            
        self.crew = credit.crew?
            .reduce(into: [(String, [Media.Crew])](), { partialResult, crew in
                let department = crew.department ?? ""
                if let index = partialResult.firstIndex(where: { $0.0 == department }) {
                    partialResult[index].1.append(crew)
                } else {
                    partialResult.append((department, [crew]))
                }
            }) ?? []
    }
    
    // MARK: - 演员列表
    var acting: some View {
        LazyVStack(alignment: .leading) {
            Text("演员")
                .font(.headline)
            ForEach(credit.cast ?? []) { item in
                NavigationLink(value: item) {
                    ProfileView(
                        axis: .horizontal,
                        profilePath: item.profilePath ?? "",
                        name: item.name ?? "",
                        job: item.character ?? ""
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - 工作人员列表
    var member: some View {
        LazyVStack(alignment: .leading) {
            Text("工作人员")
                .font(.headline)
            
            ForEach(crew, id: \.0) { crew in
                Text(crew.0)
                    .font(.headline)
                ForEach(crew.1) { item in
                    NavigationLink(value: item) {
                        ProfileView(
                            axis: .horizontal,
                            profilePath: item.profilePath ?? "",
                            name: item.name ?? "",
                            job: item.job ?? ""
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    var regularBody: some View {
        HStack(alignment: .top) {
            acting
                .frame(width: 240)

            member
                .frame(width: 240)

            Spacer()
        }
        .padding()
    }
    
    var body: some View {
        ScrollView {
            #if !os(macOS)
            if horizontalSizeClass == .compact {
                Group {
                    HStack {
                        acting
                        Spacer()
                    }
                    HStack {
                        member
                        Spacer()
                    }
                }
                .padding()
            } else {
                regularBody
            }
            #else
            regularBody
            #endif
        }
        .navigationTitle("完整演职员表")
    }
}

struct CreditView_Previews: PreviewProvider {
    static var previews: some View {
        CreditView(credit: mockMovies[0].credits ?? .init())
    }
}
