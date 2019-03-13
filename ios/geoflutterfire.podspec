#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'geoflutterfire'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin for querying firestore based on geo-hashes.'
  s.swift_version    = '4.2'
  s.description      = <<-DESC
Flutter plugin for querying firestore based on geo-hashes.
                       DESC
  s.homepage         = 'https://github.com/DarshanGowda0/GeoFlutterFire'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'noeatsleepdev@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'

  s.ios.deployment_target = '8.0'
end

