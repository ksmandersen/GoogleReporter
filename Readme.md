# Google Reporter

Easily integrate Google Analytics into your iOS/tvOS app without downloading any of the Google SDKs.

## Set Up

Works with Carthage or just put ``GoogleReporter.swift`` into your project. 

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

### Usage

You can track any event you wish to using the ``event()`` method on the ``GoogleReporter``. Example:

```swift
func didCompleteSignUp() {
    GoogleReporter.shared.event("Authentication", action: "Sign Up Completed")
}
```


### License

Copyright 2017 Kristian Andersen

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
