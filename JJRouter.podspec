Pod::Spec.new do |s|

s.name = 'JJRouter'
s.version = '0.0.1'
s.platform = :ios, '7.0'
s.summary = '轻量级路由设计，用法简单'
s.homepage = 'https://github.com/andyfangjunjie/JJRouter'
s.license = 'MIT'
s.author = { 'andyfangjunjie' => 'andyfangjunjie@163.com' }
s.source = {:git => 'https://github.com/andyfangjunjie/JJRouter.git', :tag => s.version}
s.source_files = 'JJRouter/**/*.{h,m}'
s.requires_arc = true
s.framework  = 'UIKit','Foundation'

end