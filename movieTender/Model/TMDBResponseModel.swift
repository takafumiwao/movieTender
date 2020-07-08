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
//    static var supportsSecureCoding: Bool
//
//
////    static var supportsSecureCoding: Bool = true
    // apikey
    private let api_key = "7e87f5b2dfa13fb9eb4d559ac2a189e8"
    // 映画ID
    private var movie_id: Int?
    // タイトル
    private var title: String?
    // ポスター画像URL
    private var poster_url: String?
    // 背景画像
    private var backdrop_path: String?
    // イメージ
    private var image: UIImageView?
    public var posterImage: UIImageView?
    public var backDropImage: UIImageView?
    // 時間
    private var time: String?
    // ジャンル
    private var genre: String?
    // 概要
    private var overView: String?

    // average
    private var average: Double?

    var actorDataArray = [ActorModel]()

  init(movie_id: Int?, title: String?, poster_url: String?, backdrop_path: String?, time: String?, genre: String?, overView: String?, average: Double?) {
        self.movie_id = movie_id
        self.title = title
        self.poster_url = poster_url
        self.backdrop_path = backdrop_path
        self.time = time
        self.genre = genre
        self.overView = overView
        self.average = average
    }

  required init?(coder: NSCoder) {
    self.movie_id = coder.decodeObject(forKey: "movie_id") as? Int
    self.title = coder.decodeObject(forKey: "title") as? String
    self.poster_url = coder.decodeObject(forKey: "poster_url") as? String
    self.backdrop_path = coder.decodeObject(forKey: "backdrop_path") as? String
    self.time = coder.decodeObject(forKey: "time") as? String
    self.genre = coder.decodeObject(forKey: "genre") as? String
    self.overView = coder.decodeObject(forKey: "overView") as? String
    self.average = coder.decodeObject(forKey: "average") as? Double
  }

  func encode(with coder: NSCoder) {
    if let movie_id = movie_id { coder.encode(movie_id, forKey: "movie_id")}
    if let title = title { coder.encode(title, forKey: "title")}
    if let poster_url = poster_url { coder.encode(poster_url, forKey: "poster_url")}
    if let backdrop_path = backdrop_path { coder.encode(backdrop_path, forKey: "backdrop_path")}
    if let time = time { coder.encode(time, forKey: "time")}
    if let genre = genre { coder.encode(genre, forKey: "genre")}
    if let overView = overView { coder.encode(overView, forKey: "overView")}
    if let average = average { coder.encode(average, forKey: "average")}
  }

  // 保存処理
    func saveData(_ value : [[String: TMDBResponseModel]]){
      guard let archiveData = try? NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: true) else {
          fatalError("Archive failed")
      }

      UserDefaults.standard.set(archiveData, forKey: "favorite")
  }

 // 削除処理
    func deleteData(_ key : String){

    }

    func loadData() -> [[String: TMDBResponseModel]]?{
      if let loadedData = UserDefaults().data(forKey: "favorite") {
        return try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(loadedData) as! [[String: TMDBResponseModel]]

      }
      return nil
  }



    // posterimage読み込み関数
    func posterLoadImage() -> UIImageView? {

        if poster_url != nil {

            posterImage?.sd_setImage(with: URL(string: poster_url!), completed: nil)

        }

        return posterImage
    }

    // backDropImage読み込み関数
    func backDropLoadImage() -> UIImageView? {

            if backdrop_path != nil {

                backDropImage?.sd_setImage(with: URL(string: backdrop_path!), completed: nil)
            }

        return backDropImage
    }


}
