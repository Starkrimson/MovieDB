//
//  DetailCollection.swift
//  MovieDB
//
//  Created by allie on 18/7/2022.
//

import SwiftUI

extension DetailView {
    
    struct Collection: View {
        let collection: BelongsToCollection
        
        var body: some View {
            ZStack(alignment: .leading) {
                // MARK: - 背景图
                GeometryReader { proxy in
                    URLImage(collection.backdropPath?.imagePath(.multiFaces(w: 1000, h: 450)))
                        .scaledToFill()
                        .frame(width: proxy.size.width, height: 258)
                        .clipped()
                }
                
                // MARK: - 渐变
                LinearGradient(
                    colors: [
                        Color(red: 3/255.0, green: 37/255.0, blue: 65/255.0, opacity: 1),
                        Color(red: 3/255.0, green: 37/255.0, blue: 65/255.0, opacity: 0.6),
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                
                // MARK: - 查看系列按钮
                VStack(alignment: .leading) {
                    Text("PART OF COLLECTION".localized(arguments: collection.name ?? ""))
                        .foregroundColor(.white)
                        .font(.largeTitle)
                    
                    NavigationLink {
                        MovieCollectionView(store: .init(
                            initialState: .init(belongsTo: collection),
                            reducer: MovieCollectionReducer()
                        ))
                    } label: {
                        Text("VIEW THE COLLECTION".localized)
                    }
                }
                .padding(.leading, 20)
            }
            .frame(height: 258)
        }
    }
}

struct DetailCollection_Previews: PreviewProvider {
    static var previews: some View {
        DetailView.Collection(collection: mockMovies[0].belongsToCollection ?? .init())
    }
}
