//
//  CGRect.extension.swift
//  movieTender
//
//  Created by 岩男高史 on 2020/07/07.
//  Copyright © 2020 岩男高史. All rights reserved.
//

import UIKit

extension CGRect {
    func scaledForCropping(to size: CGSize) -> CGRect {
        CGRect(
            x: self.origin.x * size.width,
            y: self.origin.y * size.height,
            width: (self.size.width * size.width),
            height: (self.size.height * size.height)
        )
    }
}
