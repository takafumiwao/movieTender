//
//  CarouselView.swift
//  movieTender
//
//  Created by 岩男高史 on 2020/07/08.
//  Copyright © 2020 岩男高史. All rights reserved.
//

import UIKit
import SDWebImage

class CarouselView: UICollectionView {

    private let cellIdentifier = "carousel"
    private let pageCount = 5
    private let colors: [UIColor] = [.blue, .yellow, .red, .green, .gray]
    private let isInfinity = true
    var resultList = [TMDBResponseModel]()
    weak var resultListDelegate: ResultListDelegate?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.delegate = self
        self.dataSource = self
        self.register(CarouselCell.self, forCellWithReuseIdentifier: cellIdentifier)
    }

    convenience init(frame: CGRect) {
        let layout = PagingPerCellFlowLayout()
        layout.itemSize = CGSize(width: frame.width * 3 / 5, height: frame.height * 1.8 / 3)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = -19
        let screenCenterx: CGFloat = UIScreen.main.bounds.width / 2// 画面の中心座標
        layout.sectionInset.left = screenCenterx
        layout.sectionInset.right = screenCenterx
        layout.sectionInset.bottom = 40
        self.init(frame: frame, collectionViewLayout: layout)

        // 水平方向のスクロールーバーを非表示にする
        self.backgroundColor = UIColor.white
        self.showsHorizontalScrollIndicator = false
    }

    func transformScale(cell: UICollectionViewCell) {
        let cellCenter: CGPoint = self.convert(cell.center, to: nil)// セルの中心座標
        let screenCenterx: CGFloat = UIScreen.main.bounds.width / 2// 画面の中心座標
        let reductionRatio: CGFloat = -0.0011// 縮小率
        let maxScale: CGFloat = 1// 最大値
        let cellCenterDisX: CGFloat = abs(screenCenterx - cellCenter.x) //中心までの距離
        let newScale = reductionRatio * cellCenterDisX + maxScale// 新しいいスケール
        cell.transform = CGAffineTransform(scaleX: newScale, y: newScale)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 画面内に表示されているセルをしゅとく
        let cells = self.visibleCells
        for cell in cells {
            // セルのScaleを変更する
            transformScale(cell: cell)
        }
        guard let ce = self.visibleCells as? [CarouselCell] else {
            return
        }
        resultListDelegate?.resultListdel(cell: ce)
    }

    func scrollToFirstItem() {
        self.layoutIfNeeded()
        if isInfinity {
            self.scrollToItem(at: IndexPath(row: 2, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
}

extension CarouselView: UICollectionViewDataSource, UICollectionViewDelegate {
    // セクションごとのセル数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.pageCount
    }

    // セルの設定
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? CarouselCell else {
            return UICollectionViewCell()
        }
        configureCell(cell: cell, indexPath: indexPath)

        return cell
    }

    private func configureCell(cell: CarouselCell, indexPath: IndexPath) {
        let fixedIndex = isInfinity ? indexPath.row % pageCount : indexPath.row
        if resultList != [] {

            let favoriteModel = resultList[fixedIndex]
            let posterImageUrl = favoriteModel.getPosterImageUrl()
            let imageView = favoriteModel.getPosterImage()
            guard let url = URL(string: "https://image.tmdb.org/t/p/w200" + posterImageUrl) else {
                return
            }

            cell.content.sd_setImage(with: url, completed: nil)
            cell.content.contentMode = UIView.ContentMode.redraw
            cell.countLabel.text = favoriteModel.getTitle()
            cell.timeLabel.text = favoriteModel.getTime()
            cell.starLabel.text = favoriteModel.getAverage()

            cell.countLabel.textColor = UIColor.clear
            cell.backgroundColor = .clear

            if fixedIndex == 0 {

                cell.content.layer.cornerRadius = 20
                cell.contentView.layer.cornerRadius = 20

            }

        }
    }
}
