//
//  DetailCast.swift
//  MovieDB
//
//  Created by allie on 18/7/2022.
//

import SwiftUI

extension DetailView {
    
    struct Cast: View {
        var credits: Media.Credits
        
        var cast: [Media.Cast] {
            credits.cast ?? []
        }
        
        var body: some View {
            VStack(alignment: .leading) {
                Text("主演")
                    .font(.title2.weight(.medium))
                    .padding(.horizontal)
                
                // MARK: - 演员列表
                ScrollView(.horizontal) {
                    HStack(alignment: .top, spacing: 0) {
                        ForEach(cast.prefix(10)) { cast in
                            NavigationLink {
                                DetailView(store: .init(
                                    initialState: .init(media: .from(cast)),
                                    reducer: DetailReducer()
                                ))
                            } label: {
                                ProfileView(
                                    profilePath: cast.profilePath ?? "",
                                    name: cast.name ?? "",
                                    job: cast.character ?? ""
                                )
                                .padding(.leading)
                            }
                            .buttonStyle(.plain)
                        }
                        
                        NavigationLink {
                            CreditView(credit: credits)
                        } label: {
                            HStack(spacing: 3) {
                                Text("查看更多")
                                Image(systemName: "chevron.right.circle.fill")
                                    .foregroundColor(.accentColor)
                            }
                            .padding()
                            .frame(height: 175)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                // MARK: - 完整演职员表
                NavigationLink {
                    CreditView(credit: credits)
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
        DetailView.Cast(credits: mockMovies[0].credits ?? .init())
    }
}
