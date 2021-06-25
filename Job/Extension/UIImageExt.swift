//
//  UIImageExt.swift
//  Job V2
//
//  Created by Saleh Sultan on 1/20/17.
/*
 Copyright (c) 2019. Davaco, Inc. All Rights Reserved. Permission to use, copy, modify, and distribute this software and its documentation without fee and without a signed licensing agreement, is hereby strictly prohibited.
 
 IN NO EVENT SHALL DAVACO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF DAVACO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 DAVACO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". DAVACO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */
//


import UIKit
import ImageIO
import CoreLocation



extension UIImage {
    
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        
        let widthRatio  = targetSize.width  / self.size.width
        let heightRatio = targetSize.height / self.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
    func imageScaleAspectToMinSize(newSize: CGFloat) -> UIImage? {
        let size = self.size
        let ratio: CGFloat!
        if size.width > size.height {
            ratio = newSize / size.height
        }
        else {
            ratio = newSize / size.width
        }
        
        let rect: CGRect = CGRect(x: 0, y: 0, width: ratio * size.width, height: ratio * size.height)
        UIGraphicsBeginImageContext(rect.size)
        self.draw(in: rect)
        let scaledImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImg
    }
    
    // IT's not good.
//    func resizeImageWithOutComp(newSize: CGSize) -> UIImage {
//
//        let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral
//        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
//        let context = UIGraphicsGetCurrentContext()
//
//        // Set the quality level to use when rescaling
//        context!.interpolationQuality = CGInterpolationQuality.default
//        let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: newSize.height)
//
//        context!.concatenate(flipVertical)
//        // Draw into the context; this scales the image
//        context?.draw(self.cgImage!, in: CGRect(x: 0.0,y: 0.0, width: newRect.width, height: newRect.height))
//
//        let newImageRef = context!.makeImage()! as CGImage
//        let newImage = UIImage(cgImage: newImageRef)
//
//        // Get the resized image from the context and a UIImage
//        UIGraphicsEndImageContext()
//
//        return newImage
//    }
    
    
    func textToImage(drawText text: NSString, atPoint point: CGPoint) -> UIImage {
        // Setup the font specific variables
        let textColor: UIColor = .white
        let textFont: UIFont = UIFont(name: "Helvetica", size: 24)!
        
        //Setup the image context using the passed image.
        UIGraphicsBeginImageContext(self.size)
        
        //Setups up the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
            ] as [NSAttributedString.Key : Any]
        
        //Put the image into a rectangle as large as the original image.
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        
        
        // Creating a point within the space that is as bit as the image.
        let rect: CGRect = CGRect(x: point.x, y: point.y, width: 250, height: self.size.height)
        
        //Now Draw the text into an image.
        text.draw(in: rect, withAttributes: textFontAttributes)
        
        // Create a new image out of the images we have created
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
        //And pass it back up to the caller.
        return newImage
    }
    
    
    // Reduce the image size until it is below 300k. Reduce by 40% radio each time.
    func reduceImageKbSize() -> NSData? {
        
        if let photoData = self.jpegData(compressionQuality: 1.0) {
            var pNSData = NSData(data: photoData)
            
            if (pNSData.length/1024 > 300) {
                if let photo = UIImage(data: pNSData as Data) {
                    pNSData = NSData(data: photo.jpegData(compressionQuality: CGFloat(Constants.IMAGE_COMPRESSION_RATIO))!)
                }
            }
            
            return pNSData
        }
        
        return nil
    }
    
    func addImageMetadata(photoName: String, photoCreator: String, photoDesc: String, imgMetaDataDic: NSDictionary, lossyData:Bool) -> Data? {
        
        let imgData = lossyData ? self.reduceImageKbSize() : self.jpegData(compressionQuality: 1.0) as NSData?
        let metadata = NSMutableDictionary(dictionary: imgMetaDataDic as! [AnyHashable : Any])
        
        if metadata[kCGImagePropertyGPSDictionary] == nil {
            let locManager = CLLocationManager()
            if let location = locManager.location {
                metadata[kCGImagePropertyGPSDictionary] = gpsDictionaryForLocation(location: location)
            }
        }
        
        var newOrientation = -1
        switch self.imageOrientation {
        case .up:
            newOrientation = 1
        case .down:
            newOrientation = 3
        case .left:
            newOrientation = 8
        case .right:
            newOrientation = 6
        case .upMirrored:
            newOrientation = 2
        case .downMirrored:
            newOrientation = 4
        case .leftMirrored:
            newOrientation = 5
        case .rightMirrored:
            newOrientation = 7
        default:
            newOrientation = 1
        }
        
        if newOrientation != -1 {
            metadata[kCGImagePropertyOrientation] = newOrientation
        }
        
        var rawDic = [AnyHashable : Any]()
        if #available(iOS 12.0, *) {
            rawDic = [kCGImagePropertyPNGDescription : photoDesc as CFString,
                      kCGImagePropertyPNGTitle : photoName as CFString,
                      kCGImagePropertyPNGAuthor: photoCreator as CFString,
                      kCGImagePropertyPNGComment: photoDesc as CFString,
                      kCGImagePropertyPNGCopyright: "Copyright © 2019 Clearthread. All rights reserved." as CFString,
                      kCGImagePropertyPNGDisclaimer: "https://davacoinc.com/" as CFString]
        } else {
            rawDic = [kCGImagePropertyPNGDescription : photoDesc as CFString,
                      kCGImagePropertyPNGTitle : photoName as CFString,
                      kCGImagePropertyPNGAuthor: photoCreator as CFString,
                      kCGImagePropertyPNGCopyright: "Copyright © 2019 Clearthread. All rights reserved." as CFString]
        }
        metadata[kCGImagePropertyRawDictionary] = rawDic
        metadata[kCGImagePropertyPNGDictionary] = rawDic
        
        
        if let dic = metadata[kCGImagePropertyExifDictionary] as? NSDictionary {
            let exifDic = NSMutableDictionary(dictionary: dic as! [AnyHashable : Any])
            exifDic[kCGImagePropertyExifMakerNote] = photoCreator as CFString
            exifDic[kCGImagePropertyExifUserComment] = photoDesc as CFString
            metadata[kCGImagePropertyExifDictionary] = exifDic
        }
        
        // Removed Apple maker notes. Because it's containing binary data, which causing problem to store data in local database.
        metadata.removeObject(forKey: kCGImagePropertyMakerAppleDictionary)
        metadata.removeObject(forKey: "kCGImageDestinationICCProfile")
        return writeImageMetadata(imgData, metadata)
    }
    
    func writeImageMetadata(_ imgData: NSData?, _ metadata: NSMutableDictionary) -> Data? {
        // create an imagesourceref
        if let source = CGImageSourceCreateWithData(imgData!, nil) {
            
            // this is the type of image (e.g., public.jpeg)
            if let UTI = CGImageSourceGetType(source) {
                
                // create a new data object and write the new image into it
                let destData = NSMutableData()
                
                if let destination = CGImageDestinationCreateWithData(destData, UTI, 1, nil) {
                    CGImageDestinationAddImageFromSource(destination, source, 0, metadata)
                    
                    if CGImageDestinationFinalize(destination) {
                        return destData as Data
                    }
                }
            }
        }
        return imgData as Data?
    }
    
    
    // Get location dictionary for photo/image metadata.
    
    func gpsDictionaryForLocation(location: CLLocation) -> NSDictionary {
        let timeZone = NSTimeZone(name: "UTC")
        let formatter = DateFormatter()
        formatter.timeZone = timeZone as TimeZone?
        formatter.dateFormat = "HH:mm:ss.ss"
        
        let dateStump = NSTimeZone(name: "UTC")
        let formatterDate = DateFormatter()
        formatterDate.timeZone = dateStump as TimeZone?
        formatterDate.dateFormat = "yyyy:MM:dd"
        
        let gpsDic: NSDictionary = [kCGImagePropertyGPSLatitude as NSString: fabs(location.coordinate.latitude),
                                    kCGImagePropertyGPSLatitudeRef as NSString: ((location.coordinate.latitude >= 0) ? "N" : "S"),
                                    kCGImagePropertyGPSLongitude as NSString: fabs(location.coordinate.longitude),
                                    kCGImagePropertyGPSLongitudeRef as NSString: ((location.coordinate.longitude > 0) ? "E" : "W"),
                                    kCGImagePropertyGPSTimeStamp as NSString: formatter.string(from: location.timestamp),
                                    kCGImagePropertyGPSDateStamp as NSString: formatterDate.string(from: location.timestamp),
                                    kCGImagePropertyGPSAltitude as NSString: fabs(location.altitude)]
        
        return gpsDic
    }
}
