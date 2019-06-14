//
//  MkMapView+MapCache.swift
//  MapCache
//
//  Created by merlos on 04/06/2019.
//

import Foundation
import MapKit

extension MKMapView {

    public func useCache(_ cache: MapCache) {
        
        let tileServerOverlay = CachedTileOverlay(withCache: cache)
        tileServerOverlay.canReplaceMapContent = true
        self.insertOverlay(tileServerOverlay, at: 0, level: .aboveLabels)
    }
    
    public func mapCacheRenderer(forOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKind(of: MKTileOverlay.self) {
            return MKTileOverlayRenderer(overlay: overlay)
        }
        return MKOverlayRenderer()
    }
}
