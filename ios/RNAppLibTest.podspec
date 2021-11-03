
Pod::Spec.new do |s|
  s.name         = "RNAppLibTest"
  s.version      = "1.0.1"
  s.summary      = "RNAppLibTest"
  s.description  = <<-DESC
                  RNAppLibTest
                   DESC
  s.homepage     = "www.baidu.com"
  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "author" => "author@domain.cn" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/author/RNAppLibTest.git", :tag => "master" }
  s.source_files  = "RNAppLibTest/**/*.{h,m}"
  s.requires_arc = true
  s.preserve_paths = 'RNAppLibTest/**/TYRZUISDK.framework'
  s.resources = ['RNAppLibTest/**/*.png']

  s.dependency "React"
  #s.dependency "others"

end

  