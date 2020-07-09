//
//  ResultListDelegate.swift
//  movieTender
//
//  Created by 岩男高史 on 2020/07/08.
//  Copyright © 2020 岩男高史. All rights reserved.
//

import Foundation
import UIKit

protocol ResultListDelegate: AnyObject {
    func resultListdel(cell: [CarouselCell])
    func resultListdel(indexPath: Int)
    func resultcell(cell: UICollectionViewCell)
}
