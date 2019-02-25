Pod::Spec.new do |s|
  s.name             = 'JFSRN'
  s.version          = '0.1'
  s.summary          = 'rn热更新 iOS客户端'
  s.homepage         = 'https://github.com/manwithstories'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '刘澈' => 'liuche.go@qq.com' }
  s.source           = { :git => 'https://github.com/manwithstories/RN_HotUpdate.git'}
  s.ios.deployment_target = '8.0'
  
  s.subspec 'HotUpdate' do |ss|
    ss.public_header_files = 'JFSRN/JFSRN/Classes/HotUpdate/*/*.h'
    ss.source_files = 'JFSRN/JFSRN/Classes/HotUpdate/*/*.{h,m}'
  end

  s.subspec 'BSDiff' do |ss|
    ss.public_header_files = 'JFSRN/JFSRN/Classes/BSDiff/*.h'
    ss.source_files =  'JFSRN/JFSRN/Classes/BSDiff/*.{h,m}' 
  end
  s.requires_arc = true
end
