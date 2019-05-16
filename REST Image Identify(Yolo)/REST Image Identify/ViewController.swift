//
//  ViewController.swift
//  REST Image Identify
//
//  Created by 林仁鴻 on 2018/5/14.
//  Copyright © 2018年 林仁鴻. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController,
    UIImagePickerControllerDelegate,UINavigationControllerDelegate
{
    @IBOutlet weak var PhotoLibrary: UIButton!
    
    @IBOutlet weak var ImageDisplay: UIImageView!
    
    var image : UIImage?
    var httpResult : String = ""
    var predictResult : String = ""

    
    /*                    Here is very important!!!                    */
    // here must be modify -> YOUR_Server_IP:YOUR_Server_PORT
    // Ex:    SERVER_IP = 172.20.10.4
    //        SERVER_PORT = 5050
    
    let SERVER_IP = "YOUR_SERVER_IP"
    let SERVER_PORT = "YOUR_SERVER_PORT"
    
    var url : URL!
    
    struct ImgDetect :  Decodable
    {
        
        struct Result:Decodable {
            var label : String
            var probability : Double
        }
        
        var result : String?
        var success : Bool
        var href : String?
        var predictions : [ Result ]
       
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get url of server
        url = URL(string:"http://\(SERVER_IP):\(SERVER_PORT)/predict")!
        
        self.PhotoLibrary.layer.borderColor = UIColor.black.cgColor
        self.PhotoLibrary.layer.borderWidth = 2.0;
        self.PhotoLibrary.contentEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 10,right: 10)
        self.ImageDisplay.contentMode = .scaleAspectFit
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    @IBAction func PhotoLibraryAction(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true;
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        self.image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)]as? UIImage
        self.ImageDisplay.image = image
        
        
        sendRequest(image: self.image!)
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func sendRequest( image:UIImage )
    {
        let request = NSMutableURLRequest(url:url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Keep-Alive", forHTTPHeaderField: "Connection")
        
        let imageData = image.jpegData(compressionQuality: 0.9)
        let base64String = imageData?.base64EncodedString( options:NSData.Base64EncodingOptions.endLineWithCarriageReturn )
        
        let params = ["image": base64String]
        
        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions(rawValue: 0))
        }catch{
            print("Error")
        }
        
        print( "Size : \(String(describing: request.httpBody))" )
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error -> Void in
            
            print( "Response: \(String(describing: response))\nData: \(String(describing: data))\nError: \(String(describing: error))" )
            
            if((error) != nil) {
                print( "Network has some problem!" )
            }
            else {
                print( "Network has no problem!" )
            }
            
            DispatchQueue.main.async
            {
                do {
                    print( "This is my data(JSON) : \(String(describing: String(data: data!, encoding: .utf8)))" )
                    
                    // Resolve JSON
                    let imgDetect = try JSONDecoder().decode(ImgDetect.self, from:data!)
                    
                    print("success? : \(imgDetect.success)")
                    
                    let dataDecoded : NSData = NSData(base64Encoded: imgDetect.result!, options: NSData.Base64DecodingOptions(rawValue: 0))!
                    
                    let decodedimage : UIImage = UIImage(data: dataDecoded as Data)!
                    
                    self.ImageDisplay.image = decodedimage
                    self.httpResult = imgDetect.href!
                    
                    for result in imgDetect.predictions
                    {
                        self.predictResult += "label : " + result.label + "\nprobability : " + String(result.probability) + "\n\n"
                    }
                    
                    print(self.predictResult)
                    
                    //UserDefault object
                    let userDefaultStore = UserDefaults.standard
                    
                    userDefaultStore.set(dataDecoded, forKey: "image_Data")
                    userDefaultStore.set(self.httpResult, forKey: "http_String")
                    userDefaultStore.set(self.predictResult, forKey: "predict_String")
                    
                    let secondVC = self.storyboard?.instantiateViewController(withIdentifier: "ResultFirstViewController") as! ResultFirstViewController
                    self.navigationController?.pushViewController(secondVC, animated: true)
                    

                } catch let myError {
                    print( "Error : \(myError)" )
                }
            }
            
        })
        
        task.resume()
        
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
