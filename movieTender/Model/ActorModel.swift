//
//  ActorModel.swift
//  movieTender
//
//  Created by 岩男高史 on 2020/07/08.
//  Copyright © 2020 岩男高史. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


class ActorModel {

  let api_key = ""
  let language = "ja-JP"

  var name : String?
  var actorPath : String?

  init(name: String, path: String) {
    self.name = name
    self.actorPath = path
  }


  func getActor() {
    AF.request("https://api.themoviedb.org/3/movie/top_rated?api_key=\(self.api_key)&language=\(self.language)&page=5", method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { (responseData) in
        // JSON解析
        switch responseData.result {
            case .success:
                for i in 0...19 {
                    let json = JSON(responseData.data as Any)
                    let title = json[i]["name"].string
                    let overView = json[i]["profile_path"].string
                    let time = json[i]["birthday"].string


                }
            break
        case .failure(let error):
            print(error)
            break
        }
    }
  }
}
