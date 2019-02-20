[![](http://img.shields.io/badge/Swift-4.1-blue.svg)]()
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg)](https://github.com/Carthage/Carthage)
[![CocoaPods compatible](https://img.shields.io/badge/CocoaPods-compatible-4BC51D.svg)](https://github.com/CocoaPods/CocoaPods)
[![](http://img.shields.io/badge/operator_overload-nope-green.svg)](https://gist.github.com/duemunk/61e45932dbb1a2ca0954)

# Google Reporter

Easily integrate Google Analytics into your iOS, macOS, and tvOS app without downloading any of the Google SDKs.

**Important Notice:** Google has officially discontiuned the option for mobile analytics tracking through Google Analytics. New apps are asked to use Firebase. Existing apps will stop collecting data on **October 31, 2019**. It is however still possible to use this library by setting up new tracking properties as websites instead of mobile apps (See [#14](https://github.com/ksmandersen/GoogleReporter/issues/14)).

[Read why I created Google Reporter here](https://medium.com/swift-digest/using-google-analytics-in-your-app-without-any-sdks-46f9a70bc178)

## Set Up

Works with Carthage & CocoaPods or just put ``GoogleReporter.swift`` into your project. 

From your ``AppDelegate``'s ``didFinishLaunchingWithOptions`` or where you initialize your app. You need to configure the
``GoogleReporter`` with ``UA-XXXXX-XX`` tracker ID.

```swift
import GoogleReporter

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        GoogleReporter.shared.configure(withTrackerId: "UA-XXXXX-XX")

        return true
    }
}
```

## Events

You can track any event you wish to using the ``event()`` method on the ``GoogleReporter``. Example:

```swift
func didCompleteSignUp() {
    GoogleReporter.shared.event("Authentication", action: "Sign Up Completed")
}
```

## Screenviews

In many cases you'll want to track what "screens" that the user navigates to. A natural place to do that is in your ``ViewController``s ``viewDidAppear``.
You can use the ``screenView()`` method of the ``GoogleReporter`` which works the same as ``event()``.

```swift
class BeerViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
	GoogleReporter.shared.screenView("Beer")
    }
}
```

## Sessions

You can track individual sessions for a user by calling ``session(start: true)`` when the user opens the app and ``session(start: false)`` when they close the app. Here's an example of how to do that in your apps ``UIApplicationDelegate``:

```swift
import GoogleReporter

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        GoogleReporter.shared.configure(withTrackerId: "UA-XXXXX-XX")

        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        GoogleReporter.shared.session(start: true)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        GoogleReporter.shared.session(start: false)
    }
}
```

## Technical Notes

In order to be GDPR compliant, Google Reporter will ask Google Analytics to anonymize users IP's by default. If you wish to opt-out of this you will neeed
to set ``anonymizeIP`` to false.

The GoogleReporter uses the native ``UserDefaults.standard`` to store a random UUID that uniquely identifies the user/install. Clearing or otherwise tampering
with the UserDefaults may cause the user identifier to be lost and the GoogleReporter will generate a new unique identifier.

The GoogleReporter class is not thread-safe. To avoid bugs, always use the ``GoogleReporter.shared`` accessor from the same thread. I suggest using the main thread.
The network call to log the data will still happen on a background thread.


## Roadmap

We're planning to to add more functionality to easily interact with the Measurement Protocol.

- [x] macOS compatability
- [x] Session tracking; start, end, duration.
- [ ] Custom variable tracking for screenviews

## License

Copyright 2017 Kristian Andersen

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
