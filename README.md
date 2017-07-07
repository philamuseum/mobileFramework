# mobileFramework Readme #

The mobile framework is a collection of utilities, which we found to be repeated across multiple apps. In order to bundle those features together, we are hoping to reduce the amount of time we need to keep multiple apps up to date and also share these tools with the community, hopefully helping others to work on the actual ideas instead of reinventing the wheel.

## The framework has the following features implemented: ##

* Caching assets locally (downloading items in the background)
* Custom URL protocol to allow loading assets from cache, without any additional overhead
* Custom URL protocol handles caching transparently for UIImages / Data as well as UIWebViews
* iBeacon ranging
* Support for GoeJSON-based indoor positioning

## Features to be added in the future: ##
* Save manually requested URLs locally
* Queue stop / pause
* Custom log output
* Route calculation for indoor wayfinding

## How to use it ##

### Downloading assets ###

For assets, there are two environments: *live* and *staging*. By default, any newly downloaded assets will be stored in *staging* and only be available in the *live* environment, when they have been manually published.

When downloading assets, the framework will automatically create folders based on the URL and works completely transparent, so no folder configuration is needed.

Code sample:

~~~~swift
let downloadQueue = QueueController.sharedInstance

// let's assign our view controller as delegate, so we can track progress
self.downloadQueue.delegate = self

// let's clean up the staging environment before we do anything, to make sure we don't keep old files around
downloadQueue.purgeEnvironment(environment: Constants.cache.environment.staging, completion: { _ in })

// let's assume we have an array of URLs to download
let urlsToDownload : [URL] = ["http://www.example.com/assetOne.json"]

for url in urlsToDownload {
    downloadQueue.addItem(url: url)
}

downloadQueue.startDownloading()
~~~~

There are two delegate methods that will be called for *progress* and when the queued items are *downloaded successfully*.

~~~~swift
extension ViewController : QueueControllerDelegate {
    func QueueControllerDownloadInProgress(queueController: QueueController, withProgress progress: Float) {
        print("Download queue progress update: \(progress) %")
        DispatchQueue.main.async {
            // update your UI here with progress information
        }

    }


    func QueueControllerDidFinishDownloading(queueController: QueueController) {
        print("Download queue finished downloading.")
        DispatchQueue.main.async {
            // now it's safe to publish our staging content into live if we want
						CacheService.sharedInstance.publishStagingEnvironment(completion: { success in
            print("Publishing content successful: \(success)")
        })
        }
    }
}
~~~~

That's it, we downloaded a whole bunch of data into our staging folder and once the downloaded completed, we moved it into live.
**Note**: Publishing data means that all content in the live folder will be deleted before the staging content will be copied over.


### Cached and uncached requests ###

Let's assume we downloaded a whole bunch of image files using the above QueueController and want to display those images within a UIWebView. If the files are available locally (in the live folder), we want to display images without having to transfer them over the network.

~~~~swift
// let's register our custom URL protocol that takes care of all the cache requests transparently
URLProtocol.registerClass(mobileFrameworkURLProtocol.self)

let url = URL(string: "http://www.example.com/some_image.jpg")
// use CacheService to generate your URLRequest
let request = CacheService.sharedInstance.makeRequest(url: url!)
self.webView.loadRequest(request)
~~~~

Now the URL protocol will take care of the request and check if the file exists locally and if it does, it will serve it from your phone. If not, it will be handled like any other request and be fetched from remote.

**Note**: By default, the URL protocol will not save the requested file offline, this is a feature that will be added in the future.

**Hint**: You can see in the Xcode console if a request is coming from remote or local.

Sometimes however, you need to make sure you get fresh data, even if we have a cached version of a file (think of a JSON file referencing new posted images from a feed).

~~~~swift
let url = URL(string: "http://www.example.com/some_image.jpg")
let request = CacheService.sharedInstance.makeRequest(url: url!, forceUncached: true)
~~~~

To download assets into Data (to use it with UIImage for example), see the following code sample:

~~~~swift
CacheService.sharedInstance.requestData(url: url!, forceUncached: false, completion: {
    localPath, data in
        if data != nil {
            let image = UIImage(data: data!)
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
    })
~~~~

**Note**: By default, any requestData call will save the requested file locally and serve the cached version from now on. To prevent this behavior, use forceCached: true.

### iBeacon ranging ###

For the iBeacon ranging, there are the following prerequesits:

* iBeacon definition JSON file
* Location definition JSON file
* For wayfinding capabilities, an additional edges definition JSON file is required

#### iBeacon Sample File ####

~~~~JSON
{
  "devices": [
    {
    "alias": "LFH_R",
    "major": 46453,
    "minor": 61315,
    "uniqueId": "OlDU"
    },
    {
    "alias": "GSH_1_T_R",
    "major": 54733,
    "minor": 24192,
    "uniqueId": "x0lw"
    }
  ]
}
~~~~

#### Location Sample File ####

~~~~JSON
[
  {
  "Name": "100",
  "Title": "100",
  "Floor": "first",
  "Open": true
  },
  {
  "Name": "101",
  "Title": "101",
  "Floor": "first",
  "Open": true
  },
  {
  "Name": "175",
  "Title": "175",
  "Floor": "first",
  "Open": true
  }
]
~~~~

#### Edges Sample File ####

~~~~JSON
[
 {
    "nodeA": "100",
    "nodeB": "101",
    "weight":1
 },
 {
    "nodeA": "101",
    "nodeB": "102",
    "weight":1
 }
]
~~~~

#### Sample Implementation ####

~~~~swift

let locationManager = GalleryLocationManager(locationManager: CLLocationManager())

// setting ourself up as delegate for location updates
locationManager.delegate = self

// we need to ask the user for when in use permissions
locationManager.requestPermissions()

// define the UUID you want to monitor along with a unique identifier
let sampleRegion = CLBeaconRegion(proximityUUID: "Your UUID", identifier: "Your identifier")
locationManager.beaconRegion = sampleRegion

// loading our location assets that are stored locally
do {
    try FeatureStore.sharedInstance.load(filename: "sampleLocations", type: .location, completion: {
        if let asset = FeatureStore.sharedInstance.getAsset(for: .location) as? LocationAsset {
            LocationStore.sharedInstance.load(fromAsset: asset)
        }
    })
} catch {
    print("Error loading locations")
}

// loading our beacon assets
do {
    try FeatureStore.sharedInstance.load(filename: "sampleBeacons", type: .beacon, completion: {
        if let asset = FeatureStore.sharedInstance.getAsset(for: .beacon) as? BeaconAsset {
            BeaconStore.sharedInstance.load(fromAsset: asset)
        }
    })
} catch {
    print("Error loading beacons")
}

// just some debug output
print("Number of beacons loaded: \(BeaconStore.sharedInstance.beacons.count)")
print("Number of locations loaded: \(LocationStore.sharedInstance.locations.count)")

// let's start ranging locations
do {
    try locationManager.startLocationRanging()
    print("Started ranging locations")
} catch {
    print("Error staring location ranging")
}
~~~~


### GeoJSON Indoor Positioning ###

Declare your ViewController as Delegate for *GalleryLocationManagerDelegate*, request permissions and start location tracking using the Apple Method.

~~~~swift
let locationManager = GalleryLocationManager(locationManager: CLLocationManager())
locationManager.delegate = self
locationManager.requestPermissions()

do {
    try FeatureStore.sharedInstance.load(filename: "locations", ext: "json", type: .location, completion: {
        if let asset = FeatureStore.sharedInstance.getAsset(for: .location) as? LocationAsset {
            LocationStore.sharedInstance.load(fromAsset: asset)
        }
    })
} catch {
    print("Error reading locations data")
}

do {
    try FeatureStore.sharedInstance.load(filename: "sample", ext: "geojson", type: .geojson, completion: {
        if let asset = FeatureStore.sharedInstance.getAsset(for: .geojson) as? GeoJSONAsset {
            LocationStore.sharedInstance.load(fromAsset: asset)
        }
    })
} catch {
    print("Error reading geojson data")
}

do {
    try locationManager.startLocationRanging(with: Constants.locationSensing.method.apple)
    print("Started ranging locations (apple)")
} catch {
    print("Error staring location ranging")
}
~~~~

The delegate method will then be called if a location match could be found:

~~~~swift
func locationManager(locationManager: GalleryLocationManager, didEnterKnownLocation location: Location) {
        print("Entered location: \(location.name)")
        DispatchQueue.main.async {
            //update your UI here
        }
    }
~~~~

Please check out the mobileFrameworkDemo project for sample GeoJSON data.

## Contact us ##

Please raise questions using issues on GitHub or direct any questions to Peter Alt (peter.alt@philamuseum.org)
