#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint system_proxy_resolver.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'system_proxy_resolver'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }

  s.source           = { :path => '.' }
  s.source_files     = [ 'Classes/**/*', 'third_party/dart-sdk/**/*.{c,h}' ]
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = {
    'HEADER_SEARCH_PATHS' => [
      '$(PODS_TARGET_SRCROOT)/../src',
      '$(PODS_TARGET_SRCROOT)/../third_party/dart-sdk/src/runtime/include',
    ],
    'DEFINES_MODULE' => 'YES',
  }
  s.swift_version = '5.0'
end
