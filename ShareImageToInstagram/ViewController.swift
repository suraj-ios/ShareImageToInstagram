//
//  ViewController.swift
//  ShareImageToInstagram
//
//  Created by Suraj on 08/12/18.
//  Copyright © 2018 Suraj. All rights reserved.
//

import UIKit

class ViewController: UIViewController ,UIDocumentInteractionControllerDelegate {

    let imageUrl = "http://thepotstill.co.uk/wp-content/uploads/2017/12/FB_IMG_1512671336728.jpg"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    var docFile: UIDocumentInteractionController?
    var imageToShare: UIImage!
    
    @IBAction func shareAction(_ sender: Any) {
            //shareToInsagramNow()
        
        
//            var instagramURL = URL(string: "instagram://library?AssetPath=\(imageUrl)")
//            if let anURL = instagramURL {
//                if UIApplication.shared.canOpenURL(anURL) {
//                    UIApplication.shared.openURL(anURL)
//                }
//            }
        
//            let instagramURL = URL(string: "instagram://app")
//            if UIApplication.shared.canOpenURL(instagramURL!) {
//                let imageData:NSData = NSData(contentsOf: URL(string: self.imageUrl)!)!
//                let writePath = (NSTemporaryDirectory() as NSString).appendingPathComponent("instagram.igo")
//                do {
//                    try imageData.write(to: URL(fileURLWithPath: writePath), options: .atomic)
//                } catch {
//                    print(error)
//                }
//                let fileURL = URL(fileURLWithPath: writePath)
//                self.docFile = UIDocumentInteractionController(url: fileURL)
//                self.docFile?.delegate = self
//                //com.instagram.exlusivegram
//                self.docFile?.uti = "com.instagram.photo"
//                if UIDevice.current.userInterfaceIdiom == .phone {
//                    self.docFile?.presentOpenInMenu(from: (self.view.bounds), in: (self.view)!, animated: true)
//                }
//            }
//
        
            //InstagramManager.obj.postImageToInstagramWithCaption(imageInstagram: self.imageUrl, instagramCaption: "New", view: self.view)
    
            shareToInsagramNow()
        }
    
    
    func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        print("documentInteractionControllerDidEndPreview")
    }
    
    func documentInteractionController(_ controller: UIDocumentInteractionController, willBeginSendingToApplication application: String?) {
        print("willBeginSendingToApplication\(controller.name)")
    }
    
    
    func shareToInsagramNow(){
            
            //instagram://library?AssetPath=yourVideoPath
            //self.items[indexNumber].displayImage
            if (URL(string: self.imageUrl)) != nil{
                let imageUrl:URL = URL(string: self.imageUrl)!
                
                if (NSData(contentsOf: imageUrl)) != nil{
                    let imageData:NSData = NSData(contentsOf: imageUrl)!
                    
                    var topImage = UIImage(data: imageData as Data)!
                    let newSize = CGSize(width: 375, height:  375)
                    UIGraphicsBeginImageContext(newSize)
                    
                    topImage.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
                    let finalImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    
                    let rotatedImage = finalImage!
                    
                    let imageDatas = rotatedImage.pngData()
                    let writePath = (NSTemporaryDirectory() as NSString).appendingPathComponent("instagram.igo")
                    
                    do {
                        try imageDatas?.write(to: URL(fileURLWithPath: writePath), options: .atomic)
                    } catch {
                        print(error)
                    }
                    
                    let fileURL = URL(fileURLWithPath: writePath)
                    //postToInstagramStories(image: rotatedImage, backgroundTopColorHex: String(), backgroundBottomColorHex: String(), deepLink: "instagram://")
                    
                    ShareImageInstagram.shareInstace.postToInstagramFeed(image: rotatedImage, caption: "", bounds: CGRect(x: 0, y: 0, width: 1080, height: 1080), view: self.view)
                    
                    //ShareImageInstagram.shareInstace.postToInstagramStories(image: rotatedImage, backgroundTopColorHex: "", backgroundBottomColorHex: "", deepLink: "")
                    
                    }
                }
            }
            
    }


