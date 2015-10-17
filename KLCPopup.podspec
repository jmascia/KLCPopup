Pod::Spec.new do |s|
  s.name         = "KLCPopup"
  s.version      = "2.0"
  s.summary      = "KLCPopup is a simple and flexible iOS class for presenting any custom view as a popup"
  s.homepage     = "https://github.com/jmascia/KLCPopup"
  s.author       = {"Jeff Mascia" => "http://jeffmascia.com"}
  s.source_files = 'KLCPopupView', 'KLCPopupView/*.{h,m}'
  s.source       = {:git => 'https://github.com/jmascia/KLCPopup.git', :tag => s.version.to_s}
  s.frameworks   = 'UIKit', 'Foundation'
  s.requires_arc = true
  s.platform     = :ios, '8.0'
  s.license      = {
    :type => 'MIT',
    :file => 'LICENSE'
  }

end
