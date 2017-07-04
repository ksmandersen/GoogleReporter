Pod::Spec.new do |s|
  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.name         = "GoogleReporter"
  s.version      = "1.1.1"
  s.summary      = "Easily integrate your app with Google Analytics"

  s.description  = <<-DESC
  Easily integrate Google Analytics into your iOS, macOS, and tvOS app without downloading any of the Google SDKs.
                   DESC

  s.homepage     = "https://github.com/ksmandersen/GoogleReporter"

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.license      = "MIT"

  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.author             = { "Kristian Andersen" => "hello@kristian.co" }
  s.social_media_url   = "http://twitter.com/ksmandersen"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.ios.deployment_target = "9.0"
  s.osx.deployment_target = "10.12"
  s.tvos.deployment_target = "10.0"

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source       = { :git => "https://github.com/ksmandersen/GoogleReporter.git", :tag => "#{s.version}" }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source_files  = "Source", "GoogleReporter.swift"
end
