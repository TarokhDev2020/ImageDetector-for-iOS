//
//  ViewController.swift
//  ImageDetector
//
//  Created by Tarokh on 10/6/20.
//  Copyright © 2020 Tarokh. All rights reserved.
//

import UIKit
import CoreML
import Vision

class HomeViewController: UIViewController, UINavigationControllerDelegate {

    //MARK: - @IBOutlets
    @IBOutlet var addItem: UIBarButtonItem!
    @IBOutlet var firstView: UIView!
    @IBOutlet var secondView: UIView!
    @IBOutlet var detectImageView: UIImageView!
    @IBOutlet var detectLabel: UILabel!
    
    
    
    //MARK: - Variables
    
    
    //MARK: - Views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.detectImageView.layer.cornerRadius = 5.0
        self.detectImageView.layer.masksToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    //MARK: - Functions
    @IBAction func addItemTapped(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true) {
            print("We have the image!")
        }
    }
    
    private func detectImage(_ image: CIImage) {
        guard let squeezeModel = try? VNCoreMLModel(for: SqueezeNet().model) else {fatalError("Loading to CoreML failed")}
        let squeezeRequest = VNCoreMLRequest(model: squeezeModel) { (request, error) in
            if error != nil {
                print(error?.localizedDescription ?? "Error")
            }
            else {
                guard let result = request.results as? [VNClassificationObservation] else {fatalError("Cannot process the image")}
                if let firstResult = result.first {
                    self.detectLabel.text = "The selected image is: \(firstResult.identifier)"
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([squeezeRequest])
        }
        catch let error as NSError {
            print(error)
        }
    }
    

}

//MARK: - UIImagePickerControllerDelegate
extension HomeViewController: UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.firstView.isHidden = true
        self.secondView.isHidden = false
        guard let image = info[.originalImage] as? UIImage else {return}
        self.detectImageView.image = image
        guard let ciImage = CIImage(image: image) else {return}
        self.detectImage(ciImage)
        self.dismiss(animated: true, completion: nil)
    }
    
}


