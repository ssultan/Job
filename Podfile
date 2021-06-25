source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target 'Job' do

#    After running 'Pod Update' query
#    Increase the reqeust timeout time in 'SessionManager' class
    pod 'Alamofire'

    # Update color schema for Action sheet pickers for DateTime picker, string picker and in ActionSheetPicker
    # Update pickerView toolbar button colors: pickerToolbar.tintColor = [UIColor whiteColor]
    pod 'ActionSheetPicker-3.0'
    

    # After running 'Pod Update' query
    # change the color of PI progress circle inside 'JGProgressHUDPieIndicatorView' class funcation name -> 'setUpForHUDStyle' and Add the activity Indicator at the middle of the PI chart.
    pod 'JGProgressHUD'

    pod 'DeviceKit'
    pod 'ReachabilitySwift'
    pod 'SlideMenuControllerSwift'
    pod 'Zip'

    pod 'Firebase/Analytics'
    #pod 'Firebase/Performance'
    pod 'Firebase/Crashlytics'
    
    pod 'GoogleMaps'
    pod 'GooglePlaces'
    pod 'GooglePlacePicker'

    # After running 'Pod Update' query
    # Customize the Signature page. Remove the top navigation bar and add the buttons at the bottom of the page.
    # Need to change the Xib file, also there are some other chagnes in SignuatureViewController and view file.
    pod 'EPSignature'
    

    # After running 'Pod Update' query
    # After update 'EVReflection' SDK, need to change the date formate to "yyyy-MM-dd'T'HH:mm:ss.SSS" and "yyyy-MM-dd'T'HH:mm:ss". Because API service return this formated date
    pod 'EVReflection'



        
    #    pod 'Appsee'
    #    pod 'Fabric', '~> 1.10.1'
    #    pod 'Crashlytics', '~> 3.13.1'
    #    pod 'Smartlook'
    #    pod 'UXCam'
    #    pod 'UserX', '0.15.3'
    
    

  target 'JobTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'JobUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
