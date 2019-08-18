//
//  ImageResponseModel.swift
//  ThePairs
//
//  Created by Rafael Colon on 8/17/19.
//  Copyright © 2019 rafcolm. All rights reserved.
//

import Foundation
/**
 Simple struct model for API JSON response.
 - Extends Decocable to automate JSON serialization based on field names
 */
struct ImageResponseModel: Decodable {
    var count: Int?
    var images: [[String:String]];
}
