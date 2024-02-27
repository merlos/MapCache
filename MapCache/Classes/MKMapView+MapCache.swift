//
//  MkMapView+MapCache.swift
//  MapCache
//
//  Created by merlos on 04/06/2019.
//

import Foundation
import MapKit

/// Extension that provides MKMapView support to use MapCache.
///
/// - SeeAlso: Readme documentation
extension MKMapView {

    /// Will tell the map to use the cache passed as parameter for getting the tiles.
    ///
    /// - Parameter cache: A cache that implements the `MapCacheProtocol`. Typically an instance of `MapCache`
    /// - Parameter canReplaceMapContent: Does the overlay replace the default map? It can be used to add a tile layer with centain level of transparency.
    ///
    /// - SeeAlso: `Readme`
    @discardableResult
    public func useCache(_ cache: MapCacheProtocol, canReplaceMapContent: Bool = true, overlayLevel: MKOverlayLevel = .aboveLabels) -> CachedTileOverlay {

        let tileServerOverlay = CachedTileOverlay(withCache: cache)
        tileServerOverlay.canReplaceMapContent = canReplaceMapContent

        // Don't set `maximumZ` when wanting "over zooming".
        // TileOverlay will stop trying in zoom levels beyond `maximumZ`.
        // Our custom renderer `CachedTileOverlayZoomRenderer` will catch these "over zooms".
        if !cache.config.overZoomMaximumZ && cache.config.maximumZ > 0 {
            tileServerOverlay.maximumZ = cache.config.maximumZ
        }
        if cache.config.maximumZ > 0 {
            tileServerOverlay.maximumZ = cache.config.maximumZ
        }

        if cache.config.minimumZ > 0 {
            tileServerOverlay.minimumZ = cache.config.minimumZ
        }
        
        tileServerOverlay.tileSize = cache.config.tileSize
        if let firstOverlay = self.overlays.first {
            self.insertOverlay(tileServerOverlay, below: firstOverlay)
        }
        else {
            self.addOverlay(tileServerOverlay, level: overlayLevel)
        }
        return tileServerOverlay
    }

    /// Call this method within the MKMapView delegate function
    /// `mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer`
    ///
    /// - SeeAlso: Example project and Readme documentation
    public func mapCacheRenderer(forOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKind(of: MKTileOverlay.self) {
            return CachedTileOverlayRenderer(overlay: overlay)
        }
        return MKOverlayRenderer()
    }

    ///
    /// TODO: Implement this correctly. 
    /// Returns current zoom level
    ///
    public var zoomLevel: Int {
        let maxZoom: Double = 20
        let zoomScale = self.visibleMapRect.size.width / Double(self.frame.size.width)
        let zoomExponent = log2(zoomScale)
        return Int(maxZoom - ceil(zoomExponent))
    }
}
