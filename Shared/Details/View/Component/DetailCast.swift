//
//  DetailCast.swift
//  MovieDB
//
//  Created by allie on 18/7/2022.
//

import SwiftUI

extension DetailView {
    
    struct Cast: View {
        var cast: [Media.Cast]
        
        var body: some View {
            VStack(alignment: .leading) {
                Text("主演")
                    .font(.title2.weight(.medium))
                    .padding(.horizontal)
                
                // MARK: - 演员列表
                ScrollView(.horizontal) {
                    HStack(alignment: .top, spacing: 0) {
                        ForEach(cast.prefix(10)) { cast in
                            NavigationLink(value: cast) {
                                ProfileView(
                                    profilePath: cast.profilePath ?? "",
                                    name: cast.name ?? "",
                                    job: cast.character ?? ""
                                )
                                .padding(.leading)
                            }
                            .buttonStyle(.plain)
                        }
                        
                        Button {
                            
                        } label: {
                            HStack(spacing: 3) {
                                Text("查看更多")
                                Image(systemName: "chevron.right.circle.fill")
                                    .foregroundColor(.accentColor)
                            }
                            .padding()
                        }
                        .buttonStyle(.plain)
                        .frame(height: 175)
                    }
                }
                
                // MARK: - 完整演职员表
                Button {
                    
                } label: {
                    Text("完整演职员表")
                        .font(.title3.weight(.medium))
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
            }
        }
    }

}
struct DetailCast_Previews: PreviewProvider {
    static var previews: some View {
        DetailView.Cast(cast: mockMovies[0].credits?.cast ?? [])
    }
}
