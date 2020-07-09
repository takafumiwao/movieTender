//
//  CarouselCell.swift
//  movieTender
//
//  Created by 岩男高史 on 2020/07/08.
//  Copyright © 2020 岩男高史. All rights reserved.
//

import UIKit

class CarouselCell: UICollectionViewCell {

    var countLabel = UILabel()
    var timeLabel = UILabel()
    var starLabel = UILabel()
    var content = UIImageView()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    private func setup() {
        // セルの縦横をしゅとくする
        let width: CGFloat = self.contentView.frame.width
        //適当なmargin
        let margin: CGFloat = 2
        // 数字ラベルを設置する
        countLabel.frame = CGRect(x: margin, y: margin, width: width - margin * 2, height: 50)
        countLabel.textAlignment = .center
        countLabel.textColor = UIColor.black
        countLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        content.frame = contentView.frame
        content.layer.masksToBounds = true
        content.layer.cornerRadius = 20
        content.frame = contentView.frame

        self.contentView.addSubview(countLabel)
        self.contentView.addSubview(content)
        // セルの背景色を変える
        self.contentView.backgroundColor = UIColor.white
        // セルの枠線の太さを変える
        self.contentView.layer.borderWidth = 0
        self.contentView.layer.cornerRadius = 20
        // 影の位置
        self.contentView.layer.shadowOffset = CGSize(width: 1, height: 1)
        // 影の色
        self.contentView.layer.shadowColor = UIColor.gray.cgColor
        // 影の透明度
        self.contentView.layer.shadowOpacity = 0.7
        // 影の広がり
        self.contentView.layer.shadowRadius = 5
    }

}
