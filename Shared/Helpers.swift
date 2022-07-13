//
//  Helpers.swift
//  MovieDB
//
//  Created by allie on 13/7/2022.
//

import Foundation

extension String {
    static let baseURL = "https://api.themoviedb.org/3"
}

let defaultQueryItems = [
    URLQueryItem(name: "api_key", value: ""),
    URLQueryItem(name: "language", value: "zh"),
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
    
    private static func url(paths: [String], queryItems: [String: Any]) -> URL {
        var url = URL(string: .baseURL)!
        paths.forEach { url.append(path: $0) }
        url.append(
            queryItems: defaultQueryItems + queryItems
                .mapValues { "\($0)" }
                .map(URLQueryItem.init)
        )
        return url
    }
}
