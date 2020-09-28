# MediaPickerService iOS
A service class making it easier picking local images and videos in a customizable picker.

- Can be customized in design.
- Can be used for photos, videos or both.
- Can show a "Take Photo" / "Record Video" cell.

### Installation (Cocoapods)
- Add the following to your podfile:
    ```
    pod 'MediaPickerService', :git => 'ssh://git@github.com/makeabledk/ios_packages.git'
    ```
- Run the following in your terminal:
    ```
    pod install
    ```
    
### How to use it
You can use the MediaPickerService anywhere in your app, where you need to let the user pick a media element locally from their phone.

- First of all you need to add 4 things to your info.plist file.
  - Privacy - Camera Usage Description (example: "You will have to give access to camera to take photos.")
  - Privacy - Microphone Usage Description (example: "You will have to give access to the microphone to record the audio with the video.")
  - Privacy - Photo Library Additions Usage Description (example: "You will have to give access to save the photo/video in your photo library, to see it in the list.")
  - Privacy - Photo Library Usage Description (example: "You will have to give access to your photo library to see the photos/videos in the list.")
  
- Now you need to go into your viewcontroller and import Photos and MediaPickerService:
    ```
    import Photos
    import MediaPickerService
    ```
    
- Save an instance of the MediaPickerService in a variable within your viewcontroller. The owner is your viewcontroller:
  ```
  mediaPickerService = MediaPickerService(owner: self)
  ```
  
- Present the MediaPicker from a button click or anywhere inside your viewcontroller:
  ```
  mediaPickerService.presentPicker(animated: true, completion: nil)
  ```
  
- Try to run your app and see the MediaPicker appear :)

### Customization
- It is possible to customize the MediaPicker by changing the layout, the colors, the text, the fonts etc. All you have to do is build a settings object and set this on the MediaPickerService instance. Below is shown all the settings that you can change. You do not have to implement those, you do not want to customize. The settings below are the default settings, which will be used, if you do not change them:
    ```
    let settings = MediaPickerServiceSettings.Builder()
        .setAutoCloseOnSingleSelect(false)
        .setShowsCancelButton(true)
        .setMaxSelectableCount(0)
        .setAssetsPerRow(3)
        .setTitleFontSize(17)
        .setButtonFontSize(17)
        .setInsets(UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        .setCornerRadius(0)
        .setNavigationBarTitle("Media Picker")
        .setImagesSegmentTitle("Images")
        .setVideosSegmentTitle("Videos")
        .setCancelButtonTitle("Cancel")
        .setDoneButtonTitle("Done")
        .setCameraSourceText("Take Photo")
        .setVideoSourceText("Record Video")
        .setAlertMaxSelectableAssetsTitle("Maximum assets reached")
        .setAlertMaxSelectableAssetsMessage("You can't pick more assets.")
        .setPermissionDeniedAlertTitle("Permission denied")
        .setPermissionDeniedCameraAlertMessage("You need to give the app permission to use your camera to be able to take a photo.")
        .setPermissionDeniedPhotoLibraryAlertMessage("You need to give the app permission to use your photo library to use the asset picker.")
        .setPermissionDeniedMicrophoneAlertMessage("You need to give the app permission to use your microphone to record a video.")
        .setPermissionDeniedAlertGoToSettingsButtonTitle("Go to settings")
        .setNavigationBarColor(.white)
        .setBackgroundColor(.white)
        .setCollectionViewBackgroundColor(.white)
        .setTitleColor(.black)
        .setButtonColor(.black)
        .setSourceCellBackgroundColor(.white)
        .setSourceCellTintColor(.black)
        .setSegmentedControlTintColor(.black)
        .setGeneralTextColor(.black)
        .setAssetBorderColor(.black)
        .setAssetCountLabelColor(.white)
        .setTextFont(.systemFont(ofSize: 14))
        .setCameraSourceImageName("MAMediaCameraIcon")
        .setVideoSourceImageName("MAMediaVideoIcon")
        .setAssetType(.both)
        .setSourceType(.both)
        .build()
        
    mediaPickerService.setSettings(settings)
    ```
- You can specify in the settings object if you want the user to be able to pick images, videos or both with the .setAssetType() function
    -  .photos, 
    -  .videos
    -  .both (default)
- You can also specify if you want the user to be able to take a photo, record a video, both or none with the .setSourceType() function
    -  .camera
    -  .video
    -  .both (default)
    -  .none
