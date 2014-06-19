#
# Be sure to run `pod lib lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = "property-bindings"
  s.version          = "1.1.0"
  s.summary          = "provide a mechanism to bind the property of one object to the property of another's through KVO"
  s.description      = <<-DESC
                       Property Bindings for Objective-C

                       The Bindings extension on NSObject provide a mechanism to bind the property of one object to the property of another's through KVO.
                       DESC
  s.homepage         = "https://github.com/drewag/property-bindings"
  s.screenshots      = "http://upload.wikimedia.org/wikipedia/en/4/40/Octocat,_a_Mascot_of_Github.jpg"
  s.license          = 'http://opensource.org/licenses/MIT'
  s.author           = { "Andrew Wagner" => "cocoapods@drewag.me" }
  s.source           = { :git => "https://github.com/drewag/property-bindings.git", :tag => s.version.to_s }
  #s.social_media_url = 'https://twitter.com/EXAMPLE'

  s.platform     = :ios, '4.3'
  s.ios.deployment_target = '4.3'
  # s.osx.deployment_target = '10.7'
  s.requires_arc = false

  s.source_files = 'PropertyBindings/**/*.{h,m}'
  #s.resources = 'Assets/*.png'

  #s.ios.exclude_files = 'Classes/osx'
  #s.osx.exclude_files = 'Classes/ios'
  s.public_header_files = 'PropertyBindings/*.h'
  # s.frameworks = 'SomeFramework', 'AnotherFramework'
  # s.dependency 'JSONKit', '~> 1.4'
end
