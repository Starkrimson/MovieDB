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
            // MARK: - 演员列表
            ScrollView(.horizontal) {
                HStack(alignment: .top) {
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
                        }
                        .buttonStyle(.plain)
                    }

                    NavigationLink {
                        CreditView(credit: credits)
                    } label: {
                        HStack(spacing: 3) {
                            Text("VIEW MORE".localized)
                            Image(systemName: "chevron.right.circle.fill")
                                .foregroundColor(.accentColor)
                        }
                        .padding()
                        .frame(height: 175)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
            }
            .header("TOP BILLED CAST".localized)
            .footer {
                NavigationLink {
                    CreditView(credit: credits)
                } label: {
                    Text("FULL CAST & CREW".localized)
                }
            }
        }
    }
}

#if DEBUG
struct DetailCast_Previews: PreviewProvider {
    static var previews: some View {
        DetailView.Cast(credits: mockMovies[0].credits ?? .init())
            .frame(height: 700)
    }
}
#endif
