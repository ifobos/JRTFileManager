Pod::Spec.new do |s|
  s.name         = "JRTFileManager"
  s.version      = "0.1.0"
  s.summary      = "JRTFileManager is a class that helps the most common implementation."
  s.homepage     = "https://github.com/ifobos/JRTFileManager"
  s.license      = "MIT"
  s.author       = { "ifobos" => "juancarlos.garcia.alfaro@gmail.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/ifobos/JRTFileManager.git", :tag => "0.1.0" }
  s.source_files = "JRTFileManager/JRTFileManager/PodFiles/*.{h,m}"
  s.requires_arc = true
  s.dependency 'AFNetworking'
end
