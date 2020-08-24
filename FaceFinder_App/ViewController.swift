//
//  ViewController.swift
//  FaceFinder_App
//
//  Created by Saurabh Dixit on 8/21/20.
//  Copyright © 2020 Dixit. All rights reserved.
//

import UIKit
import Photos
import Vision
class ViewController: UIViewController {
    @IBOutlet weak var msgLabel: UILabel!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        spinner.hidesWhenStopped = true
        setUpImageView()
        
    }

    
   func createFaceOutLet(for rectangle: CGRect){
       let yellowView = UIView()
       yellowView.backgroundColor = .clear
       yellowView.layer.borderColor = UIColor.yellow.cgColor
       yellowView.layer.borderWidth = 3
       yellowView.layer.cornerRadius = 5
       yellowView.alpha = 0.0
       yellowView.frame = rectangle
       self.view.addSubview(yellowView)
       
       UIView.animate(withDuration: 0.3) {
           yellowView.alpha = 0.75
           self.spinner.alpha = 0.0
           self.msgLabel.alpha = 0.0
       }
       self.spinner.stopAnimating()
   }
    func setUpImageView(){
        guard let image = UIImage(named: "faces") else { return }
        
        guard let cgimage = image.cgImage else {
            print("UIImage has no CGImage")
            return
        }
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        let scaledHeight = (view.frame.width / image.size.width) * image.size.height
        imageView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: scaledHeight)
        view.addSubview(imageView)
        spinner.startAnimating()
        //threading
        DispatchQueue.global(qos: .background).async {
            self.PerformVisionRequest(for: cgimage, withScaledHeight: scaledHeight)
               }
        
    }
    
    
    func PerformVisionRequest(for image: CGImage, withScaledHeight: CGFloat){
   
        let facedetectionRequest = VNDetectFaceRectanglesRequest { (VNRequest, error) in
            if let error = error {
                print("error", error)
            }
            VNRequest.results?.forEach({(result) in
                guard let faceobservation = result as? VNFaceObservation else { return }
                DispatchQueue.main.async {
                    let width = (self.view.frame.width) * faceobservation.boundingBox.width
                    let height = (withScaledHeight) * faceobservation.boundingBox.height
                    let x = self.view.frame.width * faceobservation.boundingBox.origin.x
                    let y = withScaledHeight * (1 - faceobservation.boundingBox.origin.y) - height
               let faceRectangle = CGRect(x: x, y: y, width: width, height: height)
                print("faceobservation?.boundingBox", faceobservation.boundingBox)
                self.createFaceOutLet(for: faceRectangle)
                }
            })
            print("inside facedetection", VNRequest.results?.count as Any)
        }
        let imageRequestHandler = VNImageRequestHandler(cgImage: image, options: [:])
        print(imageRequestHandler)
        do {
            try imageRequestHandler.perform([facedetectionRequest])
        } catch  {
            print("failed to perform image request:", error.localizedDescription)
            return
        }
    }
}

