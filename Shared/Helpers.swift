//
//  Helpers.swift
//  MovieDB
//
//  Created by allie on 13/7/2022.
//

import Foundation

enum FileSize: String {
    case original
    case w440_and_h660_face
    case w1000_and_h450_multi_faces
    case w1920_and_h800_multi_faces
    case w1920_and_h600_multi_faces_duotone = "w1920_and_h600_multi_faces_filter(duotone,032541,01b4e4)"
}

extension String {
    static let baseURL = "https://api.themoviedb.org/3"

    func imagePath(_ fileSize: FileSize = .w440_and_h660_face) -> String {
        "https://image.tmdb.org/t/p/\(fileSize.rawValue)\(self)"
    }
}

let defaultQueryItems = [
    URLQueryItem(name: "api_key", value: ""),
    URLQueryItem(name: "language", value: "zh"),
    URLQueryItem(name: "include_image_language", value: "en,null"),
]

extension URL {
    
    /// 生成热门请求链接
    /// - Parameters:
    ///   - mediaType: 类型, .all 不可用
    ///   - page: 页码数
    /// - Returns: 请求链接
    static func popular(mediaType: MediaType, page: Int = 1) -> URL {
        url(
            paths: [
                mediaType.rawValue,
                "popular",
            ],
            queryItems: ["page": page]
        )
    }
    
    /// 生成趋势请求链接
    /// - Parameters:
    ///   - mediaType: 类型
    ///   - timeWindow: 时间
    ///   - page: 页码数
    /// - Returns: 请求链接
    static func trending(mediaType: MediaType, timeWindow: TimeWindow, page: Int = 1) -> URL {
        url(
            paths: [
                "trending",
                mediaType.rawValue,
                timeWindow.rawValue
            ],
            queryItems: ["page": page]
        )
    }
    
    /// 生成详情请求链接
    /// - Parameters:
    ///   - mediaType: 类型
    ///   - id: id
    /// - Returns: 请求链接
    static func details(mediaType: MediaType, id: Int, appendToResponse: AppendToResponse...) -> URL {
        url(
            paths: [mediaType.rawValue, id],
            queryItems: [
                "append_to_response": appendToResponse.map { $0.rawValue }.joined(separator: ",")
            ]
        )
    }
    
    private static func url(paths: [Any], queryItems: [String: Any]) -> URL {
        var url = URL(string: .baseURL)!
        paths.map { "\($0)" }.forEach { url.append(path: $0) }
        url.append(
            queryItems: defaultQueryItems + queryItems
                .mapValues { "\($0)" }
                .map(URLQueryItem.init)
        )
        return url
    }
}
