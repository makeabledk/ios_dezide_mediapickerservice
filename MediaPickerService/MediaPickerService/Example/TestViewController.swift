//
//  TestViewController.swift
//  media-picker-service
//
//  Created by Martin Lindhof Simonsen on 26/02/2019.
//  Copyright © 2019 makeable. All rights reserved.
//

import UIKit
import Photos

class TestViewController: UIViewController {
    
    var mediaPickerService: MediaPickerService?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mediaPickerService = MediaPickerService(owner: self)
        
        setupMediaPickerSettings()
        setupMediaPickerCallbacks()
    }
    
    func setupMediaPickerSettings() {
        let settings = MediaPickerServiceSettings.Builder()
            .setAutoCloseOnSingleSelect(false)
            .setShowsCancelButton(true)
            .setGeoTagImages(true)
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
            .setGoToSettingsButtonText("Go to settings")
            .setContinueWithoutButtonText("Continue without")
            .setLocationServicesNotEnabledTitle("Location services is disabled")
            .setLocationServicesNotEnabledMessage("For the app to be able to geotag your images you have to turn location services on in settings on your iPhone.\n(Anonymity -> Location Services)")
            .setLocationPermissionNotAcceptedTitle("Location permission denied")
            .setLocationPermissionNotAcceptedMessage("For the app to be able to geotag your images you have to give the app permission to use your location in the app settings")
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
        
        mediaPickerService?.setSettings(settings)
    }

    func setupMediaPickerCallbacks() {
        mediaPickerService?.setDidCancelCallback {
            // Callback when the user closes the picker by pressing the cancel button.
            print("didCancelMediaPicker")
        }
        
        mediaPickerService?.setDidSelectAssetsCallback(completion: { (assets) in
            // Callback when the user presses the done button in the picker containing the picked assets in the picked order.
            print("didSelectAssets count: \(assets.count)")
        })
    }
    
    @IBAction func openMediaPickerButtonPressed(_ sender: UIButton) {
        mediaPickerService?.presentPicker(animated: true, completion: nil)
    }
}

