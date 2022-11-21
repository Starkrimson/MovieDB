//
//  URLImage.swift
//  MovieDB
//
//  Created by allie on 27/7/2022.
//

import SwiftUI
import Kingfisher

struct URLImage: View {
    let url: URL?

    init(_ url: URL?) {
        self.url = url
    }

    init(_ urlString: String?) {
        self.url = URL(string: urlString ?? "")
    }

    var body: some View {
        KFImage(url)
            .placeholder {
                Image(systemName: "photo")
                    .font(.largeTitle)
            }
            .resizable()
            .background(Color.secondary.opacity(0.5))
    }
}

extension Image {
    init(_ image: KFCrossPlatformImage) {
        #if os(macOS)
        self = .init(nsImage: image)
        #else
        self = .init(uiImage: image)
        #endif
    }
}

extension URLImage: Transferable {
    var imageData: Data {
        get async throws {
            guard let url else { throw AppError.badURL }
            return try await withCheckedThrowingContinuation { continuation in
                KingfisherManager.shared.retrieveImage(with: url) { result in
                    switch result {
                    case .success(let data):
                        if let imageData = data.image.kf.pngRepresentation() {
                            continuation.resume(returning: imageData)
                        } else {
                            continuation.resume(throwing: AppError.badURL)
                        }
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }

    static var transferRepresentation: some TransferRepresentation {
        if #available(iOS 16.1, *) {
            return ProxyRepresentation<URLImage, Image>(exporting: { item in
                guard let cpImage = KFCrossPlatformImage(data: try await item.imageData) else {
                    throw AppError.badURL
                }
                return Image(cpImage)
            })
        } else {
            return ProxyRepresentation<URLImage, Image>(exporting: { item in
                guard let url = item.url else {
                    throw AppError.badURL
                }
                let data = try Data(contentsOf: url)
                guard let cpImage = KFCrossPlatformImage(data: data) else {
                    throw AppError.badURL
                }
                return Image(cpImage)
            })
        }
    }
}

struct URLImage_Previews: PreviewProvider {
    static var previews: some View {
        URLImage(URL(string: "/8bcoRX3hQRHufLPSDREdvr3YMXx.jpg".imagePath(.duotone(width: 1920, height: 600))))
    }
}
