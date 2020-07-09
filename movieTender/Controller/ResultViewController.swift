//
//  ResultViewController.swift
//  movieTender
//
//  Created by 岩男高史 on 2020/07/08.
//  Copyright © 2020 岩男高史. All rights reserved.
//

import UIKit
import Pastel

class ResultViewController: UIViewController {

    @IBOutlet private weak var toolbar: UIToolbar!

    private var carouselView: CarouselView!
    private var resultList: [TMDBResponseModel]?
    weak var transformDelegate: TransformDelegate?

    private var theTitle = UILabel()
    private var time = UILabel()
    private var imageView = UIImageView()
    private var star = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        //        settingPastelView()
        //        settingView()
        //        settingToolBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        resultList = appDelegate.resultList
        settingPastelView()
        settingView()
        settingToolBar()
    }

    private func settingPastelView() {
        let pastelView = PastelView(frame: view.bounds)

        // Custom Direction
        pastelView.startPastelPoint = .bottomLeft
        pastelView.endPastelPoint = .topRight

        // Custom Duration
        pastelView.animationDuration = 3.0

        // Custom Color
        pastelView.setColors([UIColor(red: 126 / 255, green: 9 / 255, blue: 146 / 255, alpha: 1.0),
                              UIColor(red: 225 / 255, green: 34 / 255, blue: 99 / 255, alpha: 1.0),
                              UIColor(red: 93 / 255, green: 1 / 255, blue: 132 / 255, alpha: 1.0),
                              UIColor(red: 2 / 255, green: 46 / 255, blue: 225 / 255, alpha: 1.0),
                              UIColor(red: 2 / 255, green: 128 / 255, blue: 225 / 255, alpha: 1.0),
                              UIColor(red: 60 / 255, green: 90 / 255, blue: 97 / 255, alpha: 1.0),
                              UIColor(red: 28 / 255, green: 225 / 255, blue: 187 / 255, alpha: 1.0)])

        pastelView.startAnimation()
        view.addSubview(pastelView)
    }

    private func settingView() {
        let w = self.view.frame.width
        let h = self.view.frame.height
        let thirtyW = self.view.frame.width / 13

        theTitle.frame = CGRect(x: 0, y: h - (thirtyW * 5.5), width: w, height: thirtyW * 2)
        theTitle.numberOfLines = 0
        theTitle.font = UIFont.boldSystemFont(ofSize: 24)
        theTitle.textAlignment = .center
        theTitle.textColor = UIColor.white

        time.text = ""
        time.font = UIFont.boldSystemFont(ofSize: 25)
        time.textColor = UIColor.white

        imageView.image = UIImage(named: "star")
        imageView.contentMode = .scaleAspectFill

        star.text = ""
        star.font = UIFont.boldSystemFont(ofSize: 25)
        star.textColor = UIColor.white

        carouselView = CarouselView(frame: CGRect(x: 0, y: 0, width: w, height: h))
        carouselView.center = CGPoint(x: w / 2, y: h / 2)
        carouselView.scrollToFirstItem()
        carouselView.backgroundColor = UIColor.clear
        guard let resultList = resultList else {
            return
        }
        carouselView.resultList = resultList
        carouselView.reloadData()
        carouselView.resultListDelegate = self
        self.view.addSubview(carouselView)
        self.view.addSubview(theTitle)
        self.view.addSubview(time)
        self.view.addSubview(imageView)
        self.view.addSubview(star)

    }

    private func settingToolBar() {
        self.view.bringSubviewToFront(toolbar)
        toolbar.tintColor = UIColor.white
        toolbar.isTranslucent = true
        toolbar.setBackgroundImage(UIImage(), forToolbarPosition: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        toolbar.setShadowImage(UIImage(), forToolbarPosition: UIBarPosition.any)
    }

    @IBAction func tapCancel(_ sender: Any) {
        transformDelegate?.backTheAnimation()
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func tapFavorite(_ sender: Any) {
    }
}

extension ResultViewController: ResultListDelegate {

    func resultListdel(cell: [CarouselCell]) {
        let w = self.view.frame.width
        let h = self.view.frame.height
        let thW = self.view.frame.width / 13

        switch cell.count {
        case 1:
            theTitle.text = cell[0].countLabel.text
            time.text = cell[0].timeLabel.text
            star.text = cell[0].starLabel.text
        case 2:
            if cell[1].frame.width >= cell[0].frame.width {
                theTitle.text = cell[1].countLabel.text
                time.text = cell[1].timeLabel.text
                star.text = cell[1].starLabel.text
            } else {
                theTitle.text = cell[0].countLabel.text
                time.text = cell[0].timeLabel.text
                star.text = cell[0].starLabel.text
            }
        default:
            if cell[0].frame.width >= cell[1].frame.width && cell[0].frame.width >= cell[2].frame.width {
                theTitle.text = cell[0].countLabel.text
                time.text = cell[0].timeLabel.text
                star.text = cell[0].starLabel.text
            } else if cell[1].frame.width >= cell[0].frame.width && cell[1].frame.width >= cell[2].frame.width {
                theTitle.text = cell[1].countLabel.text
                time.text = cell[1].timeLabel.text
                star.text = cell[1].starLabel.text
            } else if cell[2].frame.width >= cell[0].frame.width && cell[2].frame.width >= cell[1].frame.width {
                theTitle.text = cell[2].countLabel.text
                time.text = cell[2].timeLabel.text
                star.text = cell[2].starLabel.text
            }
        }

        let rect: CGSize = theTitle.sizeThatFits(CGSize(width: w, height: CGFloat.greatestFiniteMagnitude))
        theTitle.frame = CGRect(x: 0, y: h - (thW * 5), width: rect.width, height: rect.height)
        theTitle.textAlignment = .center
        theTitle.center.x = UIScreen.main.bounds.width / 2
        let timerect: CGSize = time.sizeThatFits(CGSize(width: w, height: CGFloat.greatestFiniteMagnitude))
        time.frame = CGRect(x: w / 9, y: theTitle.frame.origin.y + theTitle.frame.height, width: timerect.width, height: timerect.height)
        imageView.frame = CGRect(x: time.frame.origin.x + time.frame.width + 10, y: time.frame.origin.y, width: thW, height: thW)
        let staerrect: CGSize = time.sizeThatFits(CGSize(width: w / 12, height: CGFloat.greatestFiniteMagnitude))
        star.frame = CGRect(x: imageView.frame.origin.x + imageView.frame.width + 5, y: theTitle.frame.origin.y + theTitle.frame.height, width: staerrect.width, height: staerrect.height)
        imageView.center.y = time.center.y
        star.center.y = time.center.y
    }

    func resultListdel(indexPath: Int) {

        guard let resultList = resultList else {
            return
        }
        theTitle.text = resultList[indexPath].getTitle()
    }

    func resultcell(cell: UICollectionViewCell) {
        guard let cell = cell as? CarouselCell else {
            return
        }
        theTitle.text = cell.countLabel.text
    }

}
