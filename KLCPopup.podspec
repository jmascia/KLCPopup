Pod::Spec.new do |s|
  s.name         = "KLCPopup"
  s.version      = "1.1.1"
  s.summary      = "KLCPopup is a simple and flexible iOS class for presenting any custom view as a popup"
  s.homepage     = "https://github.com/sumit-nathany/KLCPopup"
  s.authors      = {"Jeff Mascia" => "http://jeffmascia.com", "Sumit Nathany" => "sumit.nathany@gmail.com"}
  s.source_files = 'KLCPopup', 'KLCPopup/*.{h,m}'
  s.source       = {:git => 'https://github.com/sumit-nathany/KLCPopup.git', :tag => s.version.to_s}
  s.frameworks   = 'UIKit'
  s.requires_arc = true
  s.platform     = :ios, '7.0'
  s.license      = {
    :type => 'MIT',
    :file => 'LICENSE'
  }
end