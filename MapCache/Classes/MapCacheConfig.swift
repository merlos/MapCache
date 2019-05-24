//
//  MapCacheConfig.swift
//  MapCache
//
//  Created by merlos on 13/05/2019.
//

import Foundation

public class MapCacheConfig : NSObject {
    
    public var tileUrlTemplate: String?
    
    public var useCache: Bool = true
    
    override public init() {
        super.init()
    }
    
    public init(withTileUrlTemplate: String)  {
        super.init()
        tileUrlTemplate = withTileUrlTemplate
    }
}
