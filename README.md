# MapCache Swift

<p><div style="text-align:center"><img src="./images/MapCache.png"></div>
</p>

[![CI Status](https://travis-ci.com/merlos/MapCache.svg?branch=master)](https://travis-ci.org/merlos/MapCache)
[![Version](https://img.shields.io/cocoapods/v/MapCache.svg?style=flat)](https://cocoapods.org/pods/MapCache)
[![License](https://img.shields.io/cocoapods/l/MapCache.svg?style=flat)](https://cocoapods.org/pods/MapCache)
[![Platform](https://img.shields.io/cocoapods/p/MapCache.svg?style=flat)](https://cocoapods.org/pods/MapCache)

The missing part of MapKit: A simple way to cache data.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

MapCache is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'MapCache'
```
## How to use the MapCache?

In the view controller where you have the `MKMapView` import `MapCache`

```swift
import MapCache
```

Then wihtin the ViewController add

```swift

class ViewController: UIViewController {
  @IBOutlet weak var map: MKMapView!

  override func viewDidLoad() {
    super.viewDidLoad()

    ...

    map.delegate = self

    ...

   // First setup the your cache
    let config = MapCacheConfig(withTileUrlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png")

    // Tell the map to use MapCache with the config
    map.useMapCache(withConfig: config)

    ...
}
```

Finally, tell the map delegate to use mapCacheRenderer

```swift

// Assuming that ViewController is the delegate of the map
// add this extension:
extension ViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return mapView.mapCacheRenderer(for: overlay)
    }
}
```

## Author

merlos

## License

MapCache is available under the MIT license. See the LICENSE file for more info.
