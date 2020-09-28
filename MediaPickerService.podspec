# If you need help with the podspec file check the cocoapods guide 
# about podspec files here: https://guides.cocoapods.org/syntax/podspec.html

Pod::Spec.new do |spec|
	spec.platform = :ios
	spec.requires_arc = true
	
	# Change the following:
	spec.version = "2.1.1"
	spec.ios.deployment_target = "10.0"
	spec.name = "MediaPickerService"
	spec.summary = "A service class making it easier picking local images and videos in a customizable picker."
	spec.homepage = "https://github.com/makeabledk/ios_packages"
	spec.author = { "Martin Lindhof Simonsen" => "martin@makeable.dk" }

	# If the pod has dependencies you can add them below:


	# Do not change the following
	spec.source_files  = "#{spec.name}", "#{spec.name}/#{spec.name}/Source/*.swift"
	spec.ios.resource_bundle = { "#{spec.name}" => "#{spec.name}/#{spec.name}/Source/*.{xcassets,xib,storyboard}" }
	spec.license = { :type => "MIT", :file => "LICENSE.txt" }
	spec.source = { :git => "#{spec.homepage}.git", :tag => "#{spec.name}-v#{spec.version}" }
end