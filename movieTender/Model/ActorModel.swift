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
    var name: String?
    var actorPath: String?

    init(name: String, path: String) {
        self.name = name
        self.actorPath = path
    }
}
