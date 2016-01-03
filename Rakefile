def run(command)
  system(command) or raise "RAKE TASK FAILED: #{command}"
end

$PROJECT = "PhotoSlider"
$WORKSPACE = "#{$PROJECT}.xcworkspace"


namespace 'clean' do

  task :demo do
    run "xcodebuild -workspace #{$WORKSPACE} -scheme #{$PROJECT}Demo clean"
  end

  task :framework do
    run "xcodebuild -workspace #{$WORKSPACE} -scheme #{$PROJECT} clean"
  end

end

namespace "build" do

  desc "Build for all iOS targets"
  task :ios do |task, args|

    if ENV['DESTINATION']
      destination = ENV['DESTINATION']
    else
      destination = 'platform=iOS Simulator,name=iPhone 6s'
    end

    run "xcodebuild -workspace #{$WORKSPACE} -scheme #{$PROJECT} -destination '#{destination}' -configuration Debug clean build TEST_AFTER_BUILD=YES "

  end

end

task default: ["build:ios"]
