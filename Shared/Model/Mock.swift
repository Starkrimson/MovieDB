//
//  Mock.swift
//  MovieDB
//
//  Created by allie on 13/7/2022.
//

import Foundation

#if DEBUG

let mockMediaMovies: [Media] = [
    .init(
        title: "小黄人大眼萌2：格鲁的崛起",
        originalTitle: "Minions: The Rise of Gru",
        id: 438148
    ),
    .init(
        title: "奇异博士2：疯狂多元宇宙",
        originalTitle: "Doctor Strange in the Multiverse of Madness",
        id: 453395
    ),
    .init(
        title: "雷神4：爱与雷霆",
        originalTitle: "Thor: Love and Thunder",
        id: 616037
    ),
]

let mockMediaTVShows: [Media] = [
    .init(
        name: "Stranger Things",
        originalName: "Stranger Things",
        id: 66732
    ),
    .init(
        name: "黑袍纠察队",
        originalName: "The Boys",
        id: 76479
    ),
    .init(
        name: "终极名单",
        originalName: "The Terminal List",
        id: 120911
    ),
]

let mockMedias: [Media] = [
    .init(
        title: "雷神4：爱与雷霆",
        originalTitle: "Thor: Love and Thunder",
        id: 616037,
        posterPath: "/i1NAuDW8oOlV5dBbXPPTuPlt8sl.jpg",
        voteAverage: 7
    ),
    .init(
        name: "Stranger Things",
        originalName: "Stranger Things",
        id: 66732,
        posterPath: "/2mYLTEQd1oHuXA6NICPIKX7OOvo.jpg",
        voteAverage: 8
    ),
    .init(
        name: "Natalie Portman",
        profilePath: "/edPU5HxncLWa1YkgRPNkSd68ONG.jpg",
        mediaType: .person,
        id: 524
    ),
]

let mockMovies: [Movie] = [
    .init(
        id: 616037,
        originalTitle: "Thor: Love and Thunder",
        posterPath: "/i1NAuDW8oOlV5dBbXPPTuPlt8sl.jpg",
        title: "雷神4：爱与雷霆",
        voteAverage: 7
    ),
    .init(
        id: 453395,
        originalTitle: "Doctor Strange in the Multiverse of Madness",
        posterPath: "/fCNNXrGvGi4EDlzZgPOGVdkgtuc.jpg",
        title: "奇异博士2：疯狂多元宇宙",
        voteAverage: 7
    ),
    .init(
        id: 438148,
        originalTitle: "Minions: The Rise of Gru",
        posterPath: "/hCie8qIrmMsEvPxDdvqJczj82n9.jpg",
        title: "小黄人大眼萌2：格鲁的崛起",
        voteAverage: 7
    ),
]

let mockTVShows: [TVShow] = [
    .init(
        id: 66732,
        name: "Stranger Things",
        originalName: "Stranger Things",
        posterPath: "/2mYLTEQd1oHuXA6NICPIKX7OOvo.jpg",
        voteAverage: 8
    ),
]

let mockPeople: [Person] = [
    .init(
        id: 524,
        name: "Natalie Portman",
        profilePath: "/edPU5HxncLWa1YkgRPNkSd68ONG.jpg"
    ),
]

#endif
