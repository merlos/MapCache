//
//  MkMapView+MapCache.swift
//  MapCache
//
//  Created by merlos on 04/06/2019.
//

import Foundation
import MapKit

/// Extension that provides MKMapView support to use MapCache
///
/// - SeeAlso: Readme documentation
extension MKMapView {

    /// Will tell the map to use the cache passed as parameter.
    public func useCache(_ cache: MapCache) {
        
        let tileServerOverlay = CachedTileOverlay(withCache: cache)
        tileServerOverlay.canReplaceMapContent = true
        self.insertOverlay(tileServerOverlay, at: 0, level: .aboveLabels)
    }
    
    /// Call this method within the MKMapView delegate function
    /// `mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer`
    ///
    /// - SeeAlso: Example project and Readme documentation
    public func mapCacheRenderer(forOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKind(of: MKTileOverlay.self) {
            return MKTileOverlayRenderer(overlay: overlay)
        }
        return MKOverlayRenderer()
    }
}
