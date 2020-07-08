import UIKit
import AVFoundation
import Vision

class FaceTrackerModel: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    let captureSession = AVCaptureSession()
    let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
    var videoOutput = AVCaptureVideoDataOutput()
    var view: UIView
    private var findface : (_ arr: [CGRect]) -> Void
    required init(view: UIView, findface: @escaping (_ arr: [CGRect]) -> Void) {
        self.view = view
        self.findface = findface
        super.init()
        self.initialize()
    }

    func initialize() {
        //各デバイスの登録
        let videoLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        videoLayer.frame = self.view.bounds
        videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill

        self.view.layer.addSublayer(videoLayer)

        do {
            let videoInput = try AVCaptureDeviceInput(device: self.videoDevice!) as AVCaptureDeviceInput
            self.captureSession.addInput(videoInput)
        } catch let error as NSError {
            print(error)
        }

        self.videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        self.videoOutput.alwaysDiscardsLateVideoFrames = true
        self.videoOutput.setSampleBufferDelegate(self, queue: .global())

        self.captureSession.addOutput(self.videoOutput)

        self.captureSession.startRunning()
    }

    func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage {
        //バッファーをUIImageに変換
        let imageBuffer: CVImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let baseAddress = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = (CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
        let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
        let imageRef = context!.makeImage()

        CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let resultImage = UIImage(cgImage: imageRef!)
        return resultImage
    }

    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection!) {

        if connection.videoOrientation != .portrait {
            connection.videoOrientation = .portrait
            return
        }

        //同期処理（非同期処理ではキューが溜まりすぎて画面がついていかない）
        DispatchQueue.main.sync(execute: {

            //バッファーをUIImageに変換
            let image = self.imageFromSampleBuffer(sampleBuffer: sampleBuffer)
            let ciimage: CIImage! = CIImage(image: image)

            if let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue)) {
                let handler = VNImageRequestHandler(ciImage: ciimage, orientation: orientation)
                let request = VNDetectFaceRectanglesRequest { request, _ in
                    print(request.results?.count ?? "0")
                }
                do {
                    try handler.perform([request])
                } catch {
                }
            }

            //CIDetectorAccuracyHighだと高精度（使った感じは遠距離による判定の精度）だが処理が遅くなる
            let detector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyLow] )!
            let faces: Array = detector.features(in: ciimage) as Array

            if !faces.isEmpty {
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
                self.findface(rects)
            }
        })
    }
}
