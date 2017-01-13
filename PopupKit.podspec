Pod::Spec.new do |s|
  s.name         = "PopupKit"
  s.version      = "4.0.0"
  s.summary      = "PopupKit is a simple and flexible iOS class for presenting any custom view as a popup, forked from KLCPopup."
  s.homepage     = "https://github.com/rynecheow/PopupKit"
  s.author       = {"Jeff Mascia" => "http://jeffmascia.com", "Ryne Cheow" => "http://rynecheow.com"}
  s.source_files = 'PopupKit/*.swift'
  s.source       = {:git => 'https://github.com/rynecheow/PopupKit.git', :tag => s.version.to_s}
  s.frameworks   = 'UIKit', 'Foundation'
  s.requires_arc = true
  s.ios.deployment_target = '9.0'
  s.tvos.deployment_target = '9.0'
  s.license      = {
    :type => 'MIT',
    :file => 'LICENSE'
  }

end
