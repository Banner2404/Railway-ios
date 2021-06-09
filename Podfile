inhibit_all_warnings!
use_frameworks!
platform :ios, '11.3'

def shared_pods
    pod 'Firebase/Crashlytics'
    pod 'Reveal-SDK', '24', :configurations => ['Debug']
    pod 'GoogleAPIClientForREST/Gmail'
    pod 'GoogleSignIn'
end

target 'Railway' do
    shared_pods
end

target 'RailwayTests' do
    shared_pods
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 9.0
              config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
            end
        end
    end
end
