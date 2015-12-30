# Makefile
PROJECT = PhotoSlider
WORKSPACE = $(PROJECT).xcworkspace

clean:
	xcodebuild \
		-workspace $(WORKSPACE) \
		-scheme $(PROJECT)Demo \
		clean

build:
	xcodebuild \
		-workspace $(WORKSPACE) \
		-scheme $(PROJECT) \
		-configuration Debug \
		TEST_AFTER_BUILD=YES \
		TEST_HOST=

test:
	xcodebuild \
		-workspace $(WORKSPACE) \
		-scheme $(PROJECT) \
		-destination-timeout 1 \
		-sdk iphonesimulator \
		-configuration Debug \
		-destination 'platform=iOS Simulator,name=iPhone 6' \
		clean test

