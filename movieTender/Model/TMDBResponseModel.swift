//
//  TMDBResponseModel.swift
//  movieTender
//
//  Created by 岩男高史 on 2020/07/08.
//  Copyright © 2020 岩男高史. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import Alamofire
import SwiftyJSON

class TMDBResponseModel: NSObject {
    // 映画ID
    private var movieId: Int?
    // タイトル
    private var title: String?
    // ポスター画像URL
    private var posterUrl: String?
    // 背景画像
    private var backdropPath: String?
    // イメージ
    private var image: UIImageView?
    var posterImage: UIImageView?
    var backDropImage: UIImageView?
    // 時間
    private var time: String?
    // ジャンル
    private var genre: String?
    // 概要
    private var overView: String?
    // 平均
    private var average: Double?

    var actorDataArray = [ActorModel]()

    init(movieId: Int?, title: String?, posterUrl: String?, backdropPath: String?, time: String?, genre: String?, overView: String?, average: Double?) {
        self.movieId = movieId
        self.title = title
        self.posterUrl = posterUrl
        self.backdropPath = backdropPath
        self.time = time
        self.genre = genre
        self.overView = overView
        self.average = average
    }

    required init?(coder: NSCoder) {
        self.movieId = coder.decodeObject(forKey: "movie_id") as? Int
        self.title = coder.decodeObject(forKey: "title") as? String
        self.posterUrl = coder.decodeObject(forKey: "poster_url") as? String
        self.backdropPath = coder.decodeObject(forKey: "backdrop_path") as? String
        self.time = coder.decodeObject(forKey: "time") as? String
        self.genre = coder.decodeObject(forKey: "genre") as? String
        self.overView = coder.decodeObject(forKey: "overView") as? String
        self.average = coder.decodeObject(forKey: "average") as? Double
    }

    func encode(with coder: NSCoder) {
        if let movieId = movieId { coder.encode(movieId, forKey: "movie_id") }
        if let title = title { coder.encode(title, forKey: "title") }
        if let posterUrl = posterUrl { coder.encode(posterUrl, forKey: "poster_url") }
        if let backdropPath = backdropPath { coder.encode(backdropPath, forKey: "backdrop_path") }
        if let time = time { coder.encode(time, forKey: "time") }
        if let genre = genre { coder.encode(genre, forKey: "genre") }
        if let overView = overView { coder.encode(overView, forKey: "overView") }
        if let average = average { coder.encode(average, forKey: "average") }
    }

    // posterimage読み込み関数
    func posterLoadImage() -> UIImageView? {
        if let posterUrl = posterUrl {
            posterImage?.sd_setImage(with: URL(string: posterUrl), completed: nil)
        }
        return posterImage
    }

    // backDropImage読み込み関数
    func backDropLoadImage() -> UIImageView? {
        if let backdropPath = backdropPath {
            backDropImage?.sd_setImage(with: URL(string: backdropPath), completed: nil)
        }
        return backDropImage
    }

}
