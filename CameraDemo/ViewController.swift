//
//  ViewController.swift
//  CameraDemo
//
//  Created by 悖论 on 2019/1/12.
//  Copyright © 2019 悖论. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    @IBOutlet weak var qrcodeLabel: UILabel!
    @IBOutlet weak var imagePreview: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func pickImage(_ sender: Any) {
        // 模拟器没有camera，直接return
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("source type camera 不可用")
            return
        }
        
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        picker.sourceType = .camera
        picker.cameraDevice = .rear
        present(picker, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! ScanViewController
        dest.delegate = self
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // 点击取消后执行，默认会dismiss, 所以直接注释掉了
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        print("cancel")
//        picker.dismiss(animated: true, completion: nil)
//    }
    
    // 选择图片后执行
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        imagePreview.image = image
        dismiss(animated: true, completion: nil)
    }
}
