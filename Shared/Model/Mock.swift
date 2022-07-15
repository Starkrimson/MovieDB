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
        backdropPath: "/p1F51Lvj3sMopG948F5HsBbl43C.jpg",
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
        backdropPath: "/p1F51Lvj3sMopG948F5HsBbl43C.jpg",
        genres: [
            .init(id: 28, name: "动作"),
            .init(id: 12, name: "冒险"),
            .init(id: 14, name: "奇幻"),
        ],
        id: 616037,
        originalTitle: "Thor: Love and Thunder",
        overview: "屠神者格尔几乎不朽，拥有超人的力量，耐力和抗伤能力。还能操纵黑暗并将其塑造成固态物。格尔出生在一个情况恶劣的星球上，由于神祇没有回应那些迫切需要帮助的人的祈祷，格尔认为诸神不值得任何崇拜，反之更应该遭到报应。在痛失挚爱后，格尔觉得神或许根本就不存在，但在证实世上确有神后，格尔便立誓要将他们全部铲除消灭。他也成功地屠杀了众多神祇，雷神也便顺其自然地成为了他的攻击目标。",
        posterPath: "/i1NAuDW8oOlV5dBbXPPTuPlt8sl.jpg",
        releaseDate: "2022-07-06",
        runtime: 119,
        tagline: "The one is not the only.",
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
