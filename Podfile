workspace 'RWFrameworkExample'

#Pod install fails without this, although i can't say i understand it
use_modular_headers!

target 'RWExample' do
  platform :ios, '10.0'
  project 'RWExample/RWExample.xcodeproj'
end

target 'RWFramework' do
  platform :ios, '10.0'
  pod "PromisesSwift", "~> 2.0.0"
  # For Geoswift to install you also need to have done:
  # `brew install autoconf automake libtool` before `pod install`
  pod "GEOSwift", "~> 5.0.0"
  pod "GEOSwiftMapKit", "~> 1.0.0"
  pod "Repeat", "~> 0.5.6"
  pod "ReachabilitySwift", "~> 5.0.0"
  project 'RWFramework/RWFramework.xcodeproj'
end
