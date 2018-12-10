//
//  ShareStories.swift
//  mymixtapez
//
//  Created by Fabricio Oliveira on 5/11/18.
//  Copyright © 2018 mymixtapez. All rights reserved.
//

import Foundation
import UIKit
import Photos

public protocol ShareStoriesDelegate {
    func error(message: String)
    func success()
}

open class ShareImageInstagram {
    
    private let instagramURL = URL(string: "instagram://app")
    private let instagramStoriesURL = URL(string: "instagram-stories://share")
    
    static let shareInstace = ShareImageInstagram()
    
    
    var delegate: ShareStoriesDelegate?
    
    public init() {
        
    }
    
    public func postToInstagramFeed(image: UIImage, caption: String, bounds: CGRect, view: UIView) {
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }, completionHandler: { success, error in
            if success {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                if let lastAsset = fetchResult.firstObject {
                    let localIdentifier = lastAsset.localIdentifier
                    let urlFeed = "instagram://library?LocalIdentifier=" + localIdentifier
                    guard let url = URL(string: urlFeed) else {
                        self.delegate?.error(message: "Could not open url")
                        return
                    }
                    DispatchQueue.main.async {
                        if UIApplication.shared.canOpenURL(url) {
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                                    self.delegate?.success()
                                })
                            } else {
                                UIApplication.shared.openURL(url)
                                self.delegate?.success()
                            }
                        } else {
                            self.delegate?.error(message: "Instagram not found")
                        }
                    }
                }
            } else if let error = error {
                self.delegate?.error(message: error.localizedDescription)
            }
            else {
                self.delegate?.error(message: "Could not save the photo")
            }
        })
    }
    
    public func postToInstagramStories(data: NSData, image: UIImage, backgroundTopColorHex: String, backgroundBottomColorHex: String, deepLink: String) {
        
        DispatchQueue.main.async {
            
            guard let url = self.instagramURL else {
                self.delegate?.error(message: "URL not valid")
                return
            }
            
            if UIApplication.shared.canOpenURL(url) {
                
                guard let urlScheme = self.instagramStoriesURL else {
                    self.delegate?.error(message: "URL not valid")
                    return
                }
                
                let pasteboardItems = ["com.instagram.sharedSticker.backgroundImage": image,
                                       "com.instagram.sharedSticker.backgroundTopColor" : backgroundTopColorHex,
                                       "com.instagram.sharedSticker.backgroundBottomColor" : backgroundBottomColorHex,
                                       "com.instagram.sharedSticker.backgroundVideo": data,
                                       "com.instagram.sharedSticker.contentURL": deepLink] as [String : Any]
                
                if #available(iOS 10.0, *) {
                    let pasteboardOptions = [UIPasteboard.OptionsKey.expirationDate : NSDate().addingTimeInterval(60 * 5)]
                    UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
                    
                } else {
                    UIPasteboard.general.items = [pasteboardItems]
                }
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(urlScheme, options: [:], completionHandler: { (success) in
                        self.delegate?.success()
                    })
                } else {
                    UIApplication.shared.openURL(urlScheme)
                    self.delegate?.success()
                }
                
            } else {
                self.delegate?.error(message: "Could not open instagram URL. Check if you have instagram installed and you configured your LSApplicationQueriesSchemes to enable instagram's url")
            }
        }
    }
    
    public func postToInstagramStories(image: UIImage, backgroundTopColorHex: String, backgroundBottomColorHex: String, deepLink: String) {
        
        DispatchQueue.main.async {
            
            guard let url = self.instagramURL else {
                self.delegate?.error(message: "URL not valid")
                return
            }
            
            if UIApplication.shared.canOpenURL(url) {
                
                guard let urlScheme = self.instagramStoriesURL else {
                    self.delegate?.error(message: "URL not valid")
                    return
                }
                //com.instagram.sharedSticker.stickerImage ///backgroundImage
                let pasteboardItems = ["com.instagram.sharedSticker.backgroundImage": image,
                                       "com.instagram.sharedSticker.backgroundTopColor" : backgroundTopColorHex,
                                       "com.instagram.sharedSticker.backgroundBottomColor" : backgroundBottomColorHex,
                                       "com.instagram.sharedSticker.contentURL": deepLink] as [String : Any]
                
                if #available(iOS 10.0, *) {
                    let pasteboardOptions = [UIPasteboard.OptionsKey.expirationDate : NSDate().addingTimeInterval(60 * 5)]
                    UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
                    
                } else {
                    UIPasteboard.general.items = [pasteboardItems]
                }
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(urlScheme, options: [:], completionHandler: { (success) in
                        self.delegate?.success()
                    })
                } else {
                    UIApplication.shared.openURL(urlScheme)
                    self.delegate?.success()
                }
                
            } else {
                self.delegate?.error(message: "Could not open instagram URL. Check if you have instagram installed and you configured your LSApplicationQueriesSchemes to enable instagram's url")
            }
        }
    }
    
}
