//
//  CachedTileZoomRenderer.swift
//  MapCache
//
//  Created by Cameron Deardorff on 9/20/20.
//

import Foundation
import MapKit

class CachedTileOverlayZoomRenderer: MKTileOverlayRenderer {
    
    override func canDraw(_ mapRect: MKMapRect, zoomScale: MKZoomScale) -> Bool {
        // very important to call super.canDraw first, some sort of side effect happening which allows this to work (???).
        let _ = super.canDraw(mapRect, zoomScale: zoomScale)
        return true
    }
    
    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        
        guard let cachedOverlay = overlay as? CachedTileOverlay else {
            super.draw(mapRect, zoomScale: zoomScale, in: context)
            return
        }
        // use default rendering when tiles are available
        guard cachedOverlay.shouldZoom(at: zoomScale) else {
            super.draw(mapRect, zoomScale: zoomScale, in: context)
            return
        }
        
        let tiles = cachedOverlay.tilesInMapRect(rect: mapRect, scale: zoomScale)
        for tile in tiles {
            cachedOverlay.loadTile(at: tile.path) { [weak self] (data, error) in
                
                guard let strongSelf = self,
                      let data = data,
                      let provider = CGDataProvider(data: data as CFData),
                      let image = CGImage(jpegDataProviderSource: provider, decode: nil, shouldInterpolate: false, intent: CGColorRenderingIntent.defaultIntent)
                        ?? CGImage(pngDataProviderSource: provider, decode: nil, shouldInterpolate: false, intent: CGColorRenderingIntent.defaultIntent)
                else { return }
                
                let tileScaleFactor = CGFloat(tile.overZoom) / zoomScale
                let cgRect = strongSelf.rect(for: tile.rect)
                let drawRect = CGRect(x: 0, y: 0, width: CGFloat(image.width), height: CGFloat(image.height))
                context.saveGState()
                context.translateBy(x: cgRect.minX, y: cgRect.minY)
                context.scaleBy(x: tileScaleFactor, y: tileScaleFactor)
                context.translateBy(x: 0, y: CGFloat(image.height))
                context.scaleBy(x: 1, y: -1)
                context.draw(image, in: drawRect)
                context.restoreGState()
            }
        }
    }
}

///
/// Specifies a single tile and area of the tile that should upscaled
///
struct ZoomableTile {
    let path: MKTileOverlayPath
    let rect: MKMapRect
    // delta from given tile z to desired tile z
    let overZoom: Zoom
}

extension MKZoomScale {
    func toZoomLevel(tileSize: CGFloat) -> Int {
        let numTilesAt1_0 = MKMapSize.world.width / Double(tileSize)
        let zoomLevelAt1_0 = log2(numTilesAt1_0)
        let zoomLevel: Double = Double.maximum(0, zoomLevelAt1_0 + Double(floor(log2(self) + 0.5)))
        return Int(zoomLevel)
    }
}
