//
//  ProfileImages.swift
//  MovieDB
//
//  Created by allie on 22/7/2022.
//

import SwiftUI

extension PersonDetailView {
    
    struct ProfileImages: View {
        let profiles: [Media.Image]
        var body: some View {
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach(profiles) { image in
                        URLImage(image.filePath?.imagePath(.face(w: 276, h: 350)))
                            .frame(width: 138, height: 175)
                            .cornerRadius(4)
                            .padding(.leading)
                    }
                }
            }
        }
    }
}


struct ProfileImages_Previews: PreviewProvider {
    static var previews: some View {
        PersonDetailView.ProfileImages(profiles: mockPeople[0].images?.profiles ?? [])
    }
}
