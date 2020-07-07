//
//  ViewController.swift
//  movieTender
//
//  Created by 岩男高史 on 2020/07/07.
//  Copyright © 2020 岩男高史. All rights reserved.
//

import UIKit
import Lottie

class TutorialViewController: UIViewController {

    private let pageViewController = UIPageViewController(transitionStyle: UIPageViewController.TransitionStyle.scroll, navigationOrientation: UIPageViewController.NavigationOrientation.horizontal, options: nil)

    private var viewControllersArray: [UIViewController] = []

    private let pageControl = UIPageControl()

    private var onboardArray = ["rotate", "movie"]

    private var animationView = AnimationView()

    override func viewDidLoad() {
        super.viewDidLoad()
        pageViewController.dataSource = self

        // PageViewControllerに表示するViewControllerを生成し配列に追加する
        createAndSetVC()

        // DelegateとDataSourceの設定
        pageViewController.dataSource = self

        // はじめに生成するページを設定
        firstViewSetting()

        //PageControlの生成
        settingPageControl()

        // mainページに遷移するボタンの追加
        addButton()

    }

    private func createAndSetVC() {
        // Controllerの数は3つ
        for index in 0 ..< 3 {
            let viewController = UIViewController()

            viewController.view.backgroundColor = .black
            viewController.view.tag = index

            // 2、3つめはアニメーションを追加する
            if index != 0 {
                let animation = Animation.named(onboardArray[index - 1])
                animationView.frame.size = CGSize(width: view.frame.width / 2, height: view.frame.width / 2)
                animationView.center.x = view.center.x
                animationView.center.y = view.center.y
                animationView.animation = animation
                animationView.contentMode = .scaleAspectFit
                animationView.backgroundBehavior = .pauseAndRestore
                animationView.loopMode = .loop
                animationView.play()
                viewController.view.addSubview(animationView)
            }
            viewControllersArray.append(viewController)
        }

    }

    private func firstViewSetting() {
        guard let viewController = [viewControllersArray.first] as? [UIViewController] else {
            return

        }
        pageViewController.setViewControllers(viewController, direction: .forward, animated: true, completion: nil)
        pageViewController.view.frame = self.view.frame
        guard let view = pageViewController.view else {
            return
        }
        self.view.addSubview(view)
    }

    private func settingPageControl() {
        pageControl.frame = CGRect(x: 0, y: self.view.frame.height / 16, width: self.view.frame.width, height: 50)
        pageControl.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        pageControl.pageIndicatorTintColor = #colorLiteral(red: 0.5925047994, green: 0.3051190674, blue: 0.589530766, alpha: 1)
        pageControl.currentPageIndicatorTintColor = #colorLiteral(red: 0.923158586, green: 0.3102681637, blue: 0.9005842209, alpha: 1)

        // PageControlするページ数を設定する
        pageControl.numberOfPages = 3

        // 現在ページを設定する
        pageControl.currentPage = 0
        pageControl.isUserInteractionEnabled = false
        self.view.addSubview(pageControl)
    }

    private func addButton() {
        let button = UIButton()

        button.backgroundColor = #colorLiteral(red: 0.923158586, green: 0.3102681637, blue: 0.9005842209, alpha: 1)
        button.frame.size = CGSize(width: self.view.frame.width * 3.5 / 5, height: self.view.frame.height / 16)
        button.center.x = self.view.frame.width / 2
        button.frame.origin.y = self.view.frame.height - (self.view.frame.height / 16) * 2
        button.layer.cornerRadius = 15
        button.setTitle("Movtenderを始める", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.titleLabel?.textColor = .white
        // 画面遷移処理
        button.addTarget(self, action: #selector(tapButton), for: .touchUpInside)
        self.view.addSubview(button)
    }

    @objc func tapButton() {
        // 画面遷移する
        //        guard let nxVC = self.storyboard?.instantiateViewController(identifier: "MainViewController") as? MainViewController else
        //        { return }
        //                nxVC.modalPresentationStyle = .fullScreen
        //                self.present(nxVC, animated: true, completion: nil)
    }

}

extension TutorialViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = viewController.view.tag
        pageControl.currentPage = index
        if index == 0 {
            return nil
        }

        index -= 1
        return viewControllersArray[index]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = viewController.view.tag
        pageControl.currentPage = index
        if index == 2 {
            return nil
        }

        index += 1
        return viewControllersArray[index]
    }
}
