//
//  ViewController.swift
//  take_movie
//
//  Created by Daichi Yoshikawa on 2020/09/25.
//

import UIKit
import AVFoundation
import Photos

class ViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {

    //AVCaptureMovieFileOutput()　は.movのみサポート(.mp4などはサポートしていない)
    let fileOutput = AVCaptureMovieFileOutput()
    
    @IBOutlet weak var recordButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.bringSubviewToFront(recordButton)

        setUpCamara()
    }
    
    func setUpCamara(){
        let captureSession: AVCaptureSession = AVCaptureSession()
        //ここでカメラを選択することができる(関数にして括り出した)
        let videoDevice: AVCaptureDevice? = defaultCamera()
        
        let audioDevice: AVCaptureDevice? = AVCaptureDevice.default(for: AVMediaType.audio)
        
        let videoInput: AVCaptureDeviceInput = try! AVCaptureDeviceInput(device: videoDevice!)
        captureSession.addInput(videoInput)
        
        let audioInput = try! AVCaptureDeviceInput(device: audioDevice!)
        captureSession.addInput(audioInput)
        
        captureSession.addOutput(fileOutput)
        
        captureSession.startRunning()
        
        //ビデオプレビューレイヤー(ここをストーリーボードを使った書き方に変えたい
        let videoLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoLayer.frame = self.view.bounds
        videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.view.layer.addSublayer(videoLayer)
        //レコードボタンを最前面に移動
        self.view.bringSubviewToFront(recordButton)
        
        
    }
    
    //レコードボタンを押した時の動作
    @IBAction func recordButton(_ sender: Any) {
        if self.fileOutput.isRecording{
            //stop recording
            fileOutput.stopRecording()
            self.recordButton.backgroundColor = .gray
            self.recordButton.setTitle("Record", for: .normal)
            
        }else{
            //start recording
            let tempDirectory: URL = URL(fileURLWithPath: NSTemporaryDirectory())
            let fileURL: URL = tempDirectory.appendingPathComponent("mytemp1.mov")
            fileOutput.startRecording(to: fileURL, recordingDelegate: self)
            
            self.recordButton.backgroundColor = .red
            self.recordButton.setTitle("Recording", for: .normal)
            
        }
        
    }
    
    //ファイル出力とそれを確認するダイアログ
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        let alert: UIAlertController = UIAlertController(title: "Record!", message: outputFileURL.absoluteString, preferredStyle: .alert)
        let okAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
        
        // ライブラリへの保存
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
        }) { completed, error in
            if completed {
                print("Video is saved!")
            }
        }

    }
    
    
    //カメラをセット(そのカメラがなかった時のエラーハンドリング込み)
    func defaultCamera() -> AVCaptureDevice? {
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                for: AVMediaType.video,
                                                position: .front) {
            print("前面カメラにセットしました")
            return device
        } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                            for: AVMediaType.video,
                            position: .back) {
            print("背面カメラに設定しました")
            return device
        } else {
            print("デバイスをセットできませんでした")
            return nil
        }
    }
    
    
    
}

