# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'MeTalk' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for MeTalk

post_install do |installer|
 installer.generated_projects.each do |project|
   project.targets.each do |target|
     target.build_configurations.each do |config|
       config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
     end
  end
 end
end

  target 'MeTalkTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'MeTalkUITests' do
    # Pods for testing
  end

  pod 'Firebase/Core'
  pod 'Firebase/Firestore'
  pod 'Firebase/Auth'
  pod 'Firebase/Database'
  pod 'Firebase/Storage'
  #ここから一般ライブラリ
  pod 'FloatingPanel', '~> 2.5.4'
  pod 'SideMenu'
  pod 'MessageKit', '>= 1.0.0'
  pod 'RealmSwift'
  pod 'ReachabilitySwift'
  end
