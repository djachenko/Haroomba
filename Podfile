project 'Haroomba.xcodeproj'

platform :ios, '16.0'

workspace 'Haroomba.xcworkspace'

def shared_pods
  pod 'DITranquillity'
end

target 'Haroomba' do
  use_frameworks!

  # Pods for Haroomba

end

target 'Tetris' do
  project 'Tetris/Tetris.xcodeproj'
  shared_pods
end

target 'TestUI' do
  project 'TestUI/TestUI.xcodeproj'
  shared_pods
end
