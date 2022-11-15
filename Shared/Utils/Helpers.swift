//
//  Helpers.swift
//  MovieDB
//
//  Created by allie on 13/7/2022.
//

import Foundation
import SwiftUI

enum FileSize {
    case original
    case face(w: Int, h: Int)
    case multiFaces(w: Int, h: Int)
    case best(w: Int, h: Int)
    case duotone(w: Int, h: Int, filter: String = "032541,01b4e4")

    var rawValue: String {
        switch self {
        case .original:
            return "original"
            
        case .face(let w, let h):
            return "w\(w)_and_h\(h)_face"
            
        case .multiFaces(let w, let h):
            return "w\(w)_and_h\(h)_multi_faces"
            
        case .best(w: let w, h: let h):
            return "w\(w)_and_h\(h)_bestv2"
            
        case let .duotone(w, h, filter):
            return "w\(w)_and_h\(h)_multi_faces_filter(duotone,\(filter))"
        }
    }
}

extension String {
    static let baseURL = "https://api.themoviedb.org/3"

    func imagePath(_ fileSize: FileSize = .face(w: 440, h: 660)) -> String {
        "https://image.tmdb.org/t/p/\(fileSize.rawValue)\(self)"
    }
    
    var localized: String {
        localized(comment: "")
    }
    
    func localized(comment: String) -> String {
        NSLocalizedString(self, comment: comment)
    }
    
    func localized(comment: String = "", arguments: CVarArg...) -> String {
        String(format: localized(comment: ""), arguments: arguments)
    }
}

extension Double {
    var scoreColor: Color {
        if self >= 7 {
            return .green
        } else if self >= 4 {
            return .yellow
        } else {
            return .pink
        }
    }
}

let defaultQueryItems = [
    URLQueryItem(name: "api_key", value: ""),
    URLQueryItem(name: "language", value: "LANGUAGE".localized),
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
    ///   - appendToResponse: 详情附加参数
    /// - Returns: 请求链接
    static func details(mediaType: MediaType, id: Int, appendToResponse: AppendToResponse...) -> URL {
        url(
            paths: [mediaType.rawValue, id],
            queryItems: [
                "append_to_response": appendToResponse.map { $0.rawValue }.joined(separator: ",")
            ]
        )
    }
    
    /// 生成电影系列请求链接
    /// - Parameter id: collection ID
    /// - Returns: URL
    static func collection(id: Int) -> URL {
        url(
            paths: ["collection", id],
            queryItems: [:]
        )
    }

    /// 生成剧集季 URL
    /// - Parameters:
    ///   - tvID: 剧集 ID
    ///   - seasonNumber: seasonNumber
    /// - Returns: URL
    static func season(tvID: Int, seasonNumber: Int) -> URL {
        url(
            paths: ["tv", tvID, "season", seasonNumber],
            queryItems: [:]
        )
    }
    
    enum DiscoverQueryItem: Equatable {
        /// Specify the page of results to query. minimum: 1 maximum: 1000 default: 1
        case page(Int)
        /// Choose from one of the many available sort options.
        /// Allowed Values: , popularity.asc, popularity.desc, release_date.asc, release_date.desc, revenue.asc, revenue.desc, primary_release_date.asc, primary_release_date.desc, original_title.asc, original_title.desc, vote_average.asc, vote_average.desc, vote_count.asc, vote_count.desc
        /// default: popularity.desc
        case sortBy(String)
        /// Comma separated value of genre ids that you want to include in the results.
        case genres([Int])
        /// A comma separated list of keyword ID's. Only includes movies that have one of the ID's added as a keyword.
        case keywords([Int])
        /// Filter and only include movies that have a vote count that is greater or equal to the specified value. minimum: 0
        case voteCountGTE(Int)
        /// Filter and only include movies that have a vote count that is less than or equal to the specified value. minimum: 1
        case voteCountLTE(Int)
        /// Filter and only include movies that have a rating that is greater or equal to the specified value. minimum: 0
        case voteAverageGTE(Int)
        /// Filter and only include movies that have a rating that is less than or equal to the specified value. minimum: 0
        case voteAverageLTE(Int)
        
        var key: String {
            switch self {
            case .page:
                return "page"
            case .sortBy:
                return "sort_by"
            case .genres:
                return "with_genres"
            case .keywords:
                return "with_keywords"
            case .voteCountGTE:
                return "vote_count.gte"
            case .voteCountLTE:
                return "vote_count.lte"
            case .voteAverageGTE:
                return "vote_average.gte"
            case .voteAverageLTE:
                return "vote_average.lte"
            }
        }
        
        var value: String {
            switch self {
            case .page(let value),
                 .voteCountGTE(let value), .voteCountLTE(let value),
                 .voteAverageGTE(let value), .voteAverageLTE(let value):
                return "\(value)"
            case .sortBy(let sort):
                return sort
            case .genres(let ids), .keywords(let ids):
                return ids.map(String.init).joined(separator: ",")
            }
        }
    }
    
    /// 生成 Discover URL
    /// - Parameters:
    ///   - mediaType: 类型
    ///   - queryItems: query 参数
    /// - Returns: URL
    static func discover(mediaType: MediaType, queryItems: [DiscoverQueryItem]) -> URL {
        url(
            paths: ["discover", mediaType.rawValue],
            queryItems: queryItems.reduce(into: [:]) { result, item in
                result[item.key] = item.value
            }
        )
    }
    
    /// 生成 Search URL
    /// - Parameter query: 关键字
    /// - Parameter page: 页数
    /// - Returns: URL
    static func search(query: String, page: Int) -> URL {
        url(
            paths: ["search", "multi"],
            queryItems: ["query": query, "page": page]
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

extension Date {
    
    func string(_ localizedDateFormatFromTemplates: String..., locale identifier: String? = Locale.preferredLanguages.first) -> String {
        let dateFormatter = DateFormatter()
        let template = localizedDateFormatFromTemplates.reduce(into: "") { $0 += $1 }
        dateFormatter.locale = Locale(identifier: identifier ?? "en_US")
        dateFormatter.setLocalizedDateFormatFromTemplate(template)
        return dateFormatter.string(from: self)
    }
}
