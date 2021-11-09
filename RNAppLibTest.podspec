
Pod::Spec.new do |s|
  s.name         = "RNAppLibTest"
  s.version      = "1.0.0"
  s.summary      = "RNAppLibTest"
  s.description  = <<-DESC
                  RNAppLibTest
                   DESC
  s.homepage     = "www.baidu.com"
  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "author" => "author@domain.cn" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/xuyushiguang/NPM_Lib_Test.git", :tag => "master" }
  s.source_files  = "ios/**/*.{h,m}"
  s.requires_arc = true
  s.preserve_paths = 'ios/**/TYRZUISDK.framework'
  s.resources = ['ios/**/*.png']

  s.dependency "React"
  #s.dependency "others"

end

  