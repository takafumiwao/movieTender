//
//  ViewController.swift
//  movieTender
//
//  Created by 岩男高史 on 2020/07/07.
//  Copyright © 2020 岩男高史. All rights reserved.
//

import UIKit
import AVFoundation
import Vision
import CoreML
import Pastel
import Lottie
import Alamofire
import SwiftyJSON

class MainViewController: UIViewController {

    // APIKEY
    private let apiKey = "7e87f5b2dfa13fb9eb4d559ac2a189e8"
    // 言語
    private let language = "ja-JP"

    // カメラ関係プロパティ
    private let cameraView = UIView()
    private let session = AVCaptureSession()
    private let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
    private let output = AVCaptureVideoDataOutput()

    // PageView(Main)
    private let pastelView = PastelView()
    private let favoriteViewController = FavoriteListViewController()
    private let trendViewController = TrendViewController()
    private let favoriteButton = UIButton()
    private let favoriteLabel = UILabel()
    private let trendButton = UIButton()
    private let trendLabel = UILabel()
    private let startButton = UIButton()
    private var animationView = AnimationView()
    private var viewControllersArray: [UIViewController] = []
    private let pageViewController = UIPageViewController(transitionStyle: UIPageViewController.TransitionStyle.scroll, navigationOrientation: UIPageViewController.NavigationOrientation.horizontal, options: nil)
    private let pageControl = UIPageControl()

    // 画像処理
    private var ciImage: CIImage?
    private var features = [CIFaceFeature]()
    private var findface = [CGRect]()
    private var feelingArray = [String]()
    private var rectView = UIView()

    // 分析
    private var responseData: [TMDBResponseModel]?
    private var responseDataArray = [TMDBResponseModel]()
    private var resultListDataArray = [TMDBResponseModel]()
    private var feelingGenresArray = [Int]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // datasource.delegate設定
        pageViewController.dataSource = self
        // カメラの設定
        setupCamera()
        // viewControllerの設定
        settingVC()

        // PageViewの設定

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // PastelViewの設定
        settingPastel()
    }

    private func settingPastel() {

        //        let pastelView = PastelView(frame: view.bounds)
        pastelView.frame = view.bounds
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
        self.view.insertSubview(pastelView, at: 0)

    }

    private func setupAnimation() -> CASpringAnimation {
        let animation = CASpringAnimation(keyPath: "transform.scale")
        animation.duration = 2.0
        animation.fromValue = 1.25
        animation.toValue = 1.0
        animation.mass = 1.0
        animation.initialVelocity = 30.0
        animation.damping = 3.0
        animation.stiffness = 120.0

        return animation
    }

    private func settingVC() {

        for index in 0 ..< 3 {
            var viewController = UIViewController()

            if index == 0 {
                viewController = favoriteViewController

            } else if index == 1 {
                settingMainVC(vc: viewController)

            } else if index == 2 {
                viewController = trendViewController

            }

            viewController.view.tag = index
            viewControllersArray.append(viewController)
        }
        // はじめに生成するページを設定
        pageViewController.setViewControllers([viewControllersArray[1]], direction: .forward, animated: true, completion: nil)
        pageViewController.view.frame = self.view.frame
        if let pageControllerView = pageViewController.view {
            self.view.addSubview(pageControllerView)
        }

        //PageControlの生成
        pageControl.frame = CGRect(x: 0, y: self.view.frame.height / 13, width: self.view.frame.width, height: 10)
        pageControl.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        pageControl.pageIndicatorTintColor = UIColor.black
        pageControl.currentPageIndicatorTintColor = UIColor.white

        // PageControlするページ数を設定する
        pageControl.numberOfPages = 3

        // 現在ページを設定する
        pageControl.currentPage = 1
        pageControl.isUserInteractionEnabled = false
        self.view.addSubview(pageControl)
        self.cameraView.frame = self.view.frame
        self.cameraView.alpha = 0
        self.view.addSubview(self.cameraView)

    }

    private func settingMainVC(vc: UIViewController) {

        // スタートボタン設定
        animationView = settingLottie(name: "moveButton")
        let animation = setupAnimation()
        let width = self.view.frame.width
        let x = self.view.center.x
        let y = self.view.center.y
        animationView.frame.size = CGSize(width: width / 2, height: width / 2)
        animationView.center = CGPoint(x: x, y: y)
        animationView.layer.add(animation, forKey: nil)

        let af = CGRect(x: x, y: y, width: width / 2, height: width / 2)

        // お気に入りボタン設定
        favoriteButton.tag = 0
        favoriteButton.frame = CGRect(x: width / 25, y: width / 25 * 4, width: af.width / 3, height: af.width / 4)
        favoriteButton.setImage(UIImage(named: "favorite"), for: .normal)
        favoriteButton.imageView?.contentMode = .scaleAspectFit
        favoriteButton.addTarget(self, action: #selector(send), for: .touchUpInside)
        let fbf = favoriteButton.frame

        // お気に入りラベル
        favoriteLabel.text = "フォルダ"
        favoriteLabel.textColor = .white
        favoriteLabel.font = UIFont.boldSystemFont(ofSize: 12)
        favoriteLabel.frame = CGRect(x: fbf.origin.x, y: fbf.height + fbf.origin.y, width: fbf.width, height: fbf.height / 2)
        favoriteLabel.center.x = favoriteButton.center.x
        favoriteLabel.textAlignment = .center

        // トレンドボタン設定
        trendButton.tag = 2
        trendButton.frame = CGRect(x: width - fbf.origin.x - fbf.width, y: width / 25 * 4, width: af.width / 3, height: af.width / 4)
        trendButton.setImage(UIImage(named: "trend"), for: .normal)
        trendButton.imageView?.contentMode = .scaleAspectFit
        trendButton.addTarget(self, action: #selector(send), for: .touchUpInside)
        let tbf = trendButton.frame

        // トレンドラベル
        trendLabel.text = "トレンド"
        trendLabel.textColor = .white
        trendLabel.font = UIFont.boldSystemFont(ofSize: 12)
        trendLabel.textAlignment = .center
        trendLabel.frame = CGRect(x: tbf.origin.x, y: tbf.height + tbf.origin.y, width: tbf.width, height: tbf.height / 2)
        trendLabel.center.x = trendButton.center.x

        // viewに追加
        vc.view.addSubview(startButton)
        vc.view.addSubview(favoriteButton)
        vc.view.addSubview(trendButton)
        vc.view.addSubview(favoriteLabel)
        vc.view.addSubview(trendLabel)
        vc.view.addSubview(animationView)

    }

    private func settingLottie(name: String) -> AnimationView {

        let animation = Animation.named(name)
        animationView.frame.size = CGSize(width: view.frame.width / 2, height: view.frame.width / 2)
        animationView.center.x = view.center.x
        animationView.center.y = view.center.y
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit

        animationView.play()
        animationView.loopMode = .loop
        animationView.backgroundBehavior = .pauseAndRestore

        let tap = UITapGestureRecognizer(target: self, action: #selector(lottieTap))

        animationView.isUserInteractionEnabled = true

        animationView.addGestureRecognizer(tap)

        return animationView
    }

    @objc func lottieTap() {
        animationView.pause()
        animationView.isUserInteractionEnabled = false
        startCamera()
    }

    @objc func send(_ sender: UIButton) {
        pageControl.currentPage = sender.tag
        var direction = UIPageViewController.NavigationDirection.forward
        if sender.tag == 0 {
            direction = .reverse
        }

        self.pageViewController.setViewControllers([self.viewControllersArray[sender.tag]], direction: direction, animated: true, completion: nil)
    }
}

extension MainViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

    private func setupCamera() {
        // capturelayerの設定
        let captureLayer = AVCaptureVideoPreviewLayer(session: session)
        captureLayer.frame = self.view.bounds
        captureLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.cameraView.layer.addSublayer(captureLayer)

        guard let device = device else {
            return
        }

        do {
            // sessionのin,outputの設定
            let input = try AVCaptureDeviceInput(device: device)

            output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
            output.alwaysDiscardsLateVideoFrames = true
            output.setSampleBufferDelegate(self, queue: .global())

            session.addInput(input)
            session.addOutput(output)

        } catch {
            print(error)
            return
        }
    }

    private func startCamera() {
        // 操作を無効にする
        pageViewController.isPagingEnabled = false
        favoriteButton.isEnabled = false
        trendButton.isEnabled = false
        pageControl.isEnabled = false
        UIView.animate(withDuration: 1.2) {
            self.cameraView.alpha = 1
        }
        // セッション開始
        session.startRunning()

        let hideimage = UIImageView()
        hideimage.backgroundColor = UIColor.black

        for feature in features {
            let faceRect = feature.bounds

            hideimage.draw(faceRect)
        }

        // ロックが解除されるまで待つ
        var keepAlive = true
        let runLoop = RunLoop.current
        while  keepAlive && runLoop.run(mode: .default, before: Date(timeIntervalSinceNow: 0.1)) {
            // 0.1秒毎の処理なので、処理が止まらない
            if feelingArray.count >= 15 {
                keepAlive = false
            }
        }

        favoriteButton.isHidden = true
        trendButton.isHidden = true
        pageControl.isHidden = true
        favoriteLabel.isHidden = true
        trendLabel.isHidden = true

        UIView.animate(withDuration: 1.2) {
            self.rectView.alpha = 0
            self.cameraView.alpha = 0
        }

        session.stopRunning()

        // 分析をする
        analysys()

    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if connection.videoOrientation != .portrait {
            connection.videoOrientation = .portrait
            return
        }
        //同期処理（非同期処理ではキューが溜まりすぎて画面がついていかない）
        DispatchQueue.main.sync(execute: {

            //バッファーをUIImageに変換
            let image = self.imageFromSampleBuffer(sampleBuffer: sampleBuffer)
            let ciimage: CIImage! = CIImage(image: image)

            //CIDetectorAccuracyHighだと高精度（使った感じは遠距離による判定の精度）だが処理が遅くなる
            guard let detector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyLow] ) else {
                return
            }
            let faces = detector.features(in: ciimage) as NSArray

            if faces.count != .zero {
                var rects = [CGRect]()
                var _ : CIFaceFeature = CIFaceFeature()
                for feature in faces {
                    // 座標変換
                    var faceRect: CGRect = (feature as AnyObject).bounds
                    let widthPer = (self.view.bounds.width / image.size.width)
                    let heightPer = (self.view.bounds.height / image.size.height)

                    // UIKitは左上に原点があるが、CoreImageは左下に原点があるので揃える
                    faceRect.origin.y = image.size.height - faceRect.origin.y - faceRect.size.height

                    //倍率変換
                    faceRect.origin.x *= widthPer
                    faceRect.origin.y *= heightPer
                    faceRect.size.width *= widthPer
                    faceRect.size.height *= heightPer

                    rects.append(faceRect)
                }

                guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                    return
                }
                ciImage = CIImage(cvImageBuffer: buffer)
                let options = [CIDetectorSmile: true, CIDetectorEyeBlink: true]

                guard let decF = detector.features(in: ciImage!, options: options) as? [CIFaceFeature] else {
                    return
                }

                features = decF
                faceDetection(buffer)

                DispatchQueue.main.async {
                    self.findface = rects
                    let rect = self.findface[0]
                    self.rectView.frame = rect
                    //                    self.waitLabel?.isHidden = true
                    self.rectView.layer.contents = UIImage(named: "frame")?.cgImage
                    self.view.addSubview(self.rectView)
                }

            } else {
                DispatchQueue.main.async {
                    self.rectView.layer.borderColor = UIColor.clear.cgColor
                    self.rectView.layer.contents = nil
                }

            }
        })

    }

    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage {
        //バッファーをUIImageに変換
        guard let cmSBGImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return UIImage()
        }
        let imageBuffer: CVImageBuffer = cmSBGImageBuffer
        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let baseAddress = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = (CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
        guard let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            return UIImage()
        }
        guard let imageRef = context.makeImage() else {
            return UIImage()
        }

        CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let resultImage = UIImage(cgImage: imageRef)
        return resultImage
    }

    private func faceDetection(_ buffer: CVImageBuffer) {
        let request = VNDetectFaceRectanglesRequest { request, _ in
            guard let resutls = request.results as? [VNFaceObservation] else {
                return
            }
            if let image = self.ciImage, let result = resutls.first {
                let face = self.getFaceCGImage(image: image, face: result)
                if let cg = face {
                    self.scanImage(cgImage: cg)

                }
            }
        }
        let handler = VNImageRequestHandler(cvPixelBuffer: buffer, options: [:])
        try? handler.perform([request])
    }

    private func getFaceCGImage(image: CIImage, face: VNFaceObservation) -> CGImage? {
        let imageSize = image.extent.size
        let box = face.boundingBox.scaledForCropping(to: imageSize)
        guard image.extent.contains(box) else {
            return nil
        }

        let size = CGFloat(300.0)

        let transform = CGAffineTransform(scaleX: size / box.size.width, y: size / box.size.height)
        let faceImage = image.cropped(to: box).transformed(by: transform)

        let ctx = CIContext()
        guard let cgImage = ctx.createCGImage(faceImage, from: faceImage.extent) else {
            assertionFailure()
            return nil
        }
        return cgImage
    }

    private func scanImage(cgImage: CGImage) {
        let image = CIImage(cgImage: cgImage)

        guard let model = try? VNCoreMLModel(for: feeling().model) else {
            return
        }
        let request = VNCoreMLRequest(model: model) { request, _ in
            guard let results = request.results as? [VNClassificationObservation] else {
                return
            }
            guard let mostConfidentResult = results.first else {
                return
            }

            DispatchQueue.main.async {
                self.feelingArray.append(mostConfidentResult.identifier)

            }
        }
        let requestHandler = VNImageRequestHandler(ciImage: image, options: [:])
        try? requestHandler.perform([request])
    }

}

extension MainViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = viewController.view.tag
        print("before:\(index)")
        pageControl.currentPage = index
        if index == 0 {
            return nil
        }

        index -= 1
        return viewControllersArray[index]

    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = viewController.view.tag
        print("after:\(index)")
        pageControl.currentPage = index
        if index == 2 {
            return nil
        }

        index += 1
        return viewControllersArray[index]

    }

}

extension MainViewController {
    private func analysys() {
        animationView = settingLottie(name: "analysis")
        let animation = setupAnimation()
        animationView.frame.size = CGSize(width: view.frame.width * 1.5, height: view.frame.width * 1.5)
        animationView.center = CGPoint(x: view.center.x, y: view.center.y)
        animationView.isUserInteractionEnabled = false
        animationView.layer.add(animation, forKey: nil)

        // APIのパラメータを設定する
        settingAPI(feelingArray: feelingArray)
        // APIを呼ぶ
        callTMDBAPI()

    }

    private func settingAPI(feelingArray: [String]) {

        let g = Genres.self
        let cry = [g.romance.rawValue, g.family.rawValue, g.action.rawValue, g.history.rawValue, g.documentary.rawValue]
        let disgust = [g.music.rawValue, g.drama.rawValue, g.family.rawValue, g.romance.rawValue, g.documentary.rawValue]
        let joy = [g.adventure.rawValue, g.comedy.rawValue, g.western.rawValue, g.fantasy.rawValue, g.scienceFiction.rawValue]
        let angry = [g.war.rawValue, g.crime.rawValue, g.tvMovie.rawValue, g.drama.rawValue, g.fantasy.rawValue, g.romance.rawValue]
        let fear = [g.horror.rawValue, g.crime.rawValue, g.thriller.rawValue, g.war.rawValue, g.western.rawValue, g.comedy.rawValue]
        let suprise = [g.thriller.rawValue, g.action.rawValue, g.adventure.rawValue, g.animation.rawValue, g.fantasy.rawValue]

        var int = 0
        let f = FeelType.self
        feelingArray.forEach { feel in
            switch feel {
            case f.cry.rawValue:
                int = cry[Int(arc4random()) % cry.count]
            case f.disgust.rawValue:
                int = disgust[Int(arc4random()) % disgust.count]
            case f.joy.rawValue:
                int = joy[Int(arc4random()) % joy.count]
            case f.angry.rawValue:
                int = angry[Int(arc4random()) % angry.count]
            case f.fear.rawValue:
                int = fear[Int(arc4random()) % fear.count]
            default:
                int = suprise[Int(arc4random()) % suprise.count]
            }
            feelingGenresArray.append(int)
        }

    }

    private func callTMDBAPI() {
        let dispathchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        for index in 0 ..< 4 {
            dispathchGroup.enter()
            dispatchQueue.async(group: dispathchGroup) {
                [weak self] in
                guard let self = self else {
                    return
                }
                let url = "https://api.themoviedb.org/3/discover/movie?api_key=\(self.apiKey)&with_genres=\(self.feelingGenresArray[index])&language=\(self.language)&page=1"
                AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { responseData in
                    // JSON解析
                    switch responseData.result {
                    case .success:
                        for i in 0...19 {
                            let json = JSON(responseData.data as Any)
                            let id = json["results"][i]["id"].int
                            let title = json["results"][i]["title"].string
                            let overView = json["results"][i]["overview"].string
                            let average = json["results"][i]["vote_average"].double
                            let time = json["results"][i]["release_date"].string
                            let posterUrl = json["results"][i]["poster_path"].string
                            let backdropPath = json["results"][i]["backdrop_path"].string
                            let resData = TMDBResponseModel(movieId: id ?? 0, title: title ?? "", posterUrl: posterUrl ?? "", backdropPath: backdropPath ?? "", time: time ?? "", genre: "", overView: overView ?? "", average: average ?? 0)
                            self.responseDataArray.append(resData)
                        }
                    case .failure(let error):
                        print(error)
                    }
                    dispathchGroup.leave()
                }
            }
        }

        dispathchGroup.notify(queue: .main) {
            for _ in 0...4 {
                self.resultListDataArray.append(self.responseDataArray[Int(arc4random()) % self.feelingGenresArray.count])
            }

            // 呼んだら画面遷移
            self.gotoResult()
            return
        }
    }

    private func gotoResult() {
        // 画面遷移する
        let storyboard = UIStoryboard(name: "ResultViewController", bundle: nil)
        guard let nxVC = storyboard.instantiateViewController(identifier: "ResultViewController") as? ResultViewController else {
            return
        }
        nxVC.transformDelegate = self
        nxVC.modalPresentationStyle = .fullScreen
        nxVC.modalTransitionStyle = .coverVertical
        self.present(nxVC, animated: true, completion: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        appDelegate.resultList = resultListDataArray
    }
}

extension MainViewController: TransformDelegate {
    func backTheAnimation() {
        animationView.stop()
        animationView = settingLottie(name: "moveButton")
        let animation = setupAnimation()
        let width = self.view.frame.width
        let x = self.view.center.x
        let y = self.view.center.y
        animationView.frame.size = CGSize(width: width / 2, height: width / 2)
        animationView.center = CGPoint(x: x, y: y)
        animationView.layer.add(animation, forKey: nil)

        pastelView.startAnimation()
        favoriteButton.isHidden = false
        trendButton.isHidden = false
        pageControl.isHidden = false
        favoriteLabel.isHidden = false
        trendLabel.isHidden = false

        // 操作を有効にする
        pageViewController.isPagingEnabled = true
        favoriteButton.isEnabled = true
        trendButton.isEnabled = true
        pageControl.isEnabled = true

        feelingArray = []
        features = []
        findface = []
        feelingArray = []
        responseDataArray = []
        resultListDataArray = []
        feelingGenresArray = []

    }
}
