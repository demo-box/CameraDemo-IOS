//
//  ScanViewController.swift
//  CameraDemo
//
//  Created by 悖论 on 2019/1/12.
//  Copyright © 2019 悖论. All rights reserved.
//

import UIKit
import AVFoundation

let screenW = UIScreen.main.bounds.width
let screenH = UIScreen.main.bounds.height

class ScanViewController: ViewController {
    weak var delegate: ViewController!
    private lazy var cropRect: CGRect! = {
        return CGRect(x: screenW * 0.1, y: (screenH - screenW * 0.8) / 2, width: screenW * 0.8, height: screenW * 0.8)
    }()
    private lazy var captureSession: AVCaptureSession! = {
        return AVCaptureSession()
    }()
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var line: UIView!
    private var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initScan()
        initUI()
    }
    
    private func initUI() {
        // 返回按钮
        let backBtn = UILabel(frame: CGRect(x: 10, y: 20, width: 50, height: 50))
        backBtn.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.1)
        backBtn.textColor = UIColor.white
        backBtn.text = "返回"
        backBtn.textAlignment = .center
        backBtn.layer.cornerRadius = 25
        backBtn.layer.masksToBounds = true
        backBtn.isUserInteractionEnabled = true
        // tap事件处理器
        let gesture = UITapGestureRecognizer(target: self, action: #selector(backToHome))
        backBtn.addGestureRecognizer(gesture)
        view.addSubview(backBtn)
        // 框
        let scanBox = UIView(frame: cropRect)
        scanBox.backgroundColor = UIColor.clear
        scanBox.layer.borderColor = UIColor.cyan.cgColor
        scanBox.layer.borderWidth = 1.0
        view.addSubview(scanBox)
        // 线
        line = UIView(frame: CGRect(x: 4, y: 0, width: cropRect.size.width - 8, height: 1))
        line.backgroundColor = UIColor.cyan
        scanBox.addSubview(line)
        // 线条移动
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(moveLine), userInfo: nil, repeats: true)
    }
    
    private func initScan() {
        // 获取捕获数据的的设备对象
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        // 没有captureDevice， 如模拟器
        if captureDevice == nil {
            return
        }
        
        do {
            // 获取设备的输入流对象
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            // 将input添加到session中
            captureSession.addInput(input)
        } catch {
            print(error)
            return
        }
        
        // 初始化输出对象
        let output = AVCaptureMetadataOutput()
        // 设置scan区域
        output.rectOfInterest = CGRect(
            x: cropRect.origin.y / screenH,
            y: cropRect.origin.x / screenW,
            width: cropRect.size.height / screenH,
            height: cropRect.size.width / screenW
        )
        captureSession.addOutput(output)
        // 设置代理
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        // 添加视频预览层
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
    
        captureSession.startRunning()
    }
    
    func clear() {
        // 停止定时器
        timer.invalidate()
        // 停止扫码
        captureSession.stopRunning()
    }
    
    @objc func moveLine() {
        let newY = line.frame.origin.y + 1
        if newY > cropRect.size.height {
            line.frame.origin.y = 0
        } else {
            line.frame.origin.y = newY
        }
    }
    
    @objc func backToHome() {
        clear()
        dismiss(animated: true, completion: nil)
    }
}

extension ScanViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // metadataObjects可能为空数组
        if metadataObjects.count == 0 {
            return
        }
        
        // 一次可以捕获到多个二维码，只取第一个
        // 强制向下转型，来获取stringValue
        let metadata = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        print(metadata.stringValue!)
        clear()
        dismiss(animated: true, completion: { [weak self] in
            self?.delegate.qrcodeLabel.text = metadata.stringValue
        })
    }
}
