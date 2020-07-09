//
//  PagingPerCellFlowLayout.swift
//  movieTender
//
//  Created by 岩男高史 on 2020/07/08.
//  Copyright © 2020 岩男高史. All rights reserved.
//

import UIKit

class PagingPerCellFlowLayout: UICollectionViewFlowLayout {

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        // 停止したい位置を計算して返す
        if let collectionViewBounds = self.collectionView?.bounds {
            let halfWidthOfVC = collectionViewBounds.size.width * 0.5
            let proposedContentOffsetCenterX = proposedContentOffset.x + halfWidthOfVC
            if let attributesForVisibleCells = self.layoutAttributesForElements(in: collectionViewBounds) {
                var candidateAttribute: UICollectionViewLayoutAttributes?
                for attributes in attributesForVisibleCells {
                    let candAttr: UICollectionViewLayoutAttributes? = candidateAttribute
                    if candAttr != nil {
                        let a = attributes.center.x - proposedContentOffsetCenterX
                        let b = candAttr!.center.x - proposedContentOffsetCenterX
                        if abs(a) < abs(b) {
                            candidateAttribute = attributes
                        }
                    } else {
                        candidateAttribute = attributes
                        continue
                    }
                }

                if candidateAttribute != nil {
                    return CGPoint(x: candidateAttribute!.center.x - halfWidthOfVC, y: proposedContentOffset.y)
                }
            }
        }
        return CGPoint.zero
    }

}
