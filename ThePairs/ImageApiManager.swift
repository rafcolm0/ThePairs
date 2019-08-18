//
//  ImageApiManager.swift
//  ThePairs
//
//  Created by Rafael Colon on 8/17/19.
//  Copyright © 2019 rafcolm. All rights reserved.
//

import Foundation
import Alamofire

class ImageApiManager: NSObject {
    //extends Swift Error class to specifically determine relevant error cases when calling API
    enum ImageApiManagerError: Error {
        case invalidData;
        case parsingError;
        case connectionError;
    }
    
    static let shared = ImageApiManager();
    let API_URL = "http://homework.shoany.com/images/";
    let API_HEADER_KEY = "X-SHO-verify"
    let API_HEADER_VALUE = "homework";
    let API_HEADER_AUTHO = "Authorization";
    let API_AUTH_TOKEN = "Bearer 308358df7811aa81e103a4b926cadf6f7f0dca2a";
    
    var viewdelagate:ViewControllerDelegate?;
    
    //global lazy header object - declared lazy to initiate once only (at first API query)
    lazy var MAIN_HEADER:HTTPHeaders = {
        return  [self.API_HEADER_AUTHO: self.API_AUTH_TOKEN, API_HEADER_KEY: API_HEADER_VALUE, "Content-Type" : "multipart/form-data;"];
    } ();
    
    /**
     Performs GET http command on global API_URL using MAIN_HEADER http header parameter values.
     - Uses Alamofire library to perform GET command.
     - Serializes JSON object from API response into ImageResponseModel by using JSONDecoder
     - Handles API response for succes/error by using parameter view model callback
     - Parameters:
        - completion completion parameter view model callback
    */
    func getImagesFromApi(completion: @escaping (ImageResponseModel?, Error?) -> Void) -> Void {
        guard let url = URL(string: self.API_URL) else {
            //invalid URL, return general web error
            completion(nil, ImageApiManagerError.connectionError);
            return;
        }
        Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: self.MAIN_HEADER)
            .responseJSON(completionHandler: { response in
                switch response.result {
                case .success:
                    guard let json = response.data else {
                        //invalid JSON data, return invalidData
                        completion(nil, ImageApiManagerError.invalidData);
                        return;
                    }
                    do {
                        //serializes JSON object into ImageResponseModel
                        let jsonDecoder = JSONDecoder()
                        let images = try jsonDecoder.decode(ImageResponseModel.self, from: json);
                        completion(images, nil);  //success, return ImageResponseModel model
                    } catch {   //error while serializing data, return parsingError
                        completion(nil, ImageApiManagerError.parsingError);
                    }
                case .failure( _):  //web error, return general web error
                    completion(nil, ImageApiManagerError.connectionError);
                }
        });
    }
}
