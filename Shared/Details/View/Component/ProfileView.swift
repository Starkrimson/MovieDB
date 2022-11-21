//
//  ProfileView.swift
//  MovieDB
//
//  Created by allie on 18/7/2022.
//

import SwiftUI

struct ProfileView: View {
    var axis: Axis = .vertical
    let profilePath: String
    let name: String
    let job: String
    
    var body: some View {
        if axis == .vertical {
            // MARK: - 图片名称垂直排列
            VStack(alignment: .leading) {
                URLImage(profilePath.imagePath(.face(w: 276, h: 350)))
                    .frame(width: 138, height: 175)
                    .cornerRadius(4)
                Text(name)
                    .font(.headline)
                    .lineLimit(2)
                Text(job)
                    .font(.footnote)
                    .lineLimit(2)
            }
            .frame(maxWidth: 138)
        } else {
            // MARK: - 图片名称水平排列
            HStack {
                URLImage(profilePath.imagePath(.face(w: 132, h: 132)))
                    .frame(width: 66, height: 66)
                    .cornerRadius(4)
                VStack(alignment: .leading) {
                    Text(name)
                        .font(.headline)
                    Text(job)
                        .font(.footnote)
                }
            }
            .frame(maxHeight: 66)
        }
    }
}

#if DEBUG
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProfileView(
                profilePath: mockMovies[0].credits?.cast?[0].profilePath ?? "",
                name: mockMovies[0].credits?.cast?[0].name ?? "",
                job: mockMovies[0].credits?.cast?[0].character ?? ""
            )

            ProfileView(
                axis: .horizontal,
                profilePath: mockMovies[0].credits?.cast?[0].profilePath ?? "",
                name: mockMovies[0].credits?.cast?[0].name ?? "",
                job: mockMovies[0].credits?.cast?[0].character ?? ""
            )
            
            ProfileView(
                profilePath: "",
                name: mockMovies[0].credits?.cast?[0].name ?? "",
                job: mockMovies[0].credits?.cast?[0].character ?? ""
            )

            ProfileView(
                axis: .horizontal,
                profilePath: "",
                name: mockMovies[0].credits?.cast?[0].name ?? "",
                job: mockMovies[0].credits?.cast?[0].character ?? ""
            )
        }
    }
}
#endif
