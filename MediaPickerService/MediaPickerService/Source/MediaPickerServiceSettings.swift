//
//  MediaPickerServiceSettings.swift
//  MediaPickerService
//
//  Created by Martin Lindhof Simonsen on 27/02/2019.
//

import UIKit

/// The types of asset the picker should show
public enum MediaPickerServiceAssetType {
    case photos, videos, both
}

/// The types of sources to be able to use as a user.
public enum MediaPickerServiceSourceType {
    case camera, video, both, none
}

public class MediaPickerServiceSettings {
    let autoCloseOnSingleSelect: Bool
    let showsCancelButton: Bool
    let geoTagImages: Bool
    let maxSelectableCount: Int
    let assetsPerRow: Int
    let titleFontSize: CGFloat
    let buttonFontSize: CGFloat
    let insets: UIEdgeInsets
    let cornerRadius: CGFloat
    let navigationBarTitle: String
    let imagesSegmentTitle: String
    let videosSegmentTitle: String
    let cancelButtonTitle: String
    let doneButtonTitle: String
    let cameraSourceText: String
    let videoSourceText: String
    let alertMaxSelectableAssetsTitle: String
    let alertMaxSelectableAssetsMessage: String
    let permissionDeniedAlertTitle: String
    let permissionDeniedCameraAlertMessage: String
    let permissionDeniedPhotoLibraryAlertMessage: String
    let permissionDeniedMicrophoneAlertMessage: String
    let goToSettingsButtonText: String
    let continueWithoutButtonText: String
    let locationServicesNotEnabledTitle: String
    let locationServicesNotEnabledMessage: String
    let locationPermissionNotAcceptedTitle: String
    let locationPermissionNotAcceptedMessage: String
    let navigationBarColor: UIColor
    let backgroundColor: UIColor
    let collectionViewBackgroundColor: UIColor
    let titleColor: UIColor
    let buttonColor: UIColor
    let sourceCellBackgroundColor: UIColor
    let sourceCellTintColor: UIColor
    let segmentedControlTintColor: UIColor
    let generalTextColor: UIColor
    let assetBorderColor: UIColor
    let assetCountLabelColor: UIColor
    let textFont: UIFont
    let cameraSourceImageName: String
    let videoSourceImageName: String
    let assetType: MediaPickerServiceAssetType
    let sourceType: MediaPickerServiceSourceType
    
    private init (autoCloseOnSingleSelect: Bool,
                  showsCancelButton: Bool,
                  geoTagImages: Bool,
                  maxSelectableCount: Int,
                  assetsPerRow: Int,
                  titleFontSize: CGFloat,
                  buttonFontSize: CGFloat,
                  insets: UIEdgeInsets,
                  cornerRadius: CGFloat,
                  navigationBarTitle: String,
                  imagesSegmentTitle: String,
                  videosSegmentTitle: String,
                  cancelButtonTitle: String,
                  doneButtonTitle: String,
                  cameraSourceText: String,
                  videoSourceText: String,
                  alertMaxSelectableAssetsTitle: String,
                  alertMaxSelectableAssetsMessage: String,
                  permissionDeniedAlertTitle: String,
                  permissionDeniedCameraAlertMessage: String,
                  permissionDeniedPhotoLibraryAlertMessage: String,
                  permissionDeniedMicrophoneAlertMessage: String,
                  goToSettingsButtonText: String,
                  continueWithoutButtonText: String,
                  locationServicesNotEnabledTitle: String,
                  locationServicesNotEnabledMessage: String,
                  locationPermissionNotAcceptedTitle: String,
                  locationPermissionNotAcceptedMessage: String,
                  navigationBarColor: UIColor,
                  backgroundColor: UIColor,
                  collectionViewBackgroundColor: UIColor,
                  titleColor: UIColor,
                  buttonColor: UIColor,
                  sourceCellBackgroundColor: UIColor,
                  sourceCellTintColor: UIColor,
                  segmentedControlTintColor: UIColor,
                  generalTextColor: UIColor,
                  assetBorderColor: UIColor,
                  assetCountLabelColor: UIColor,
                  textFont: UIFont,
                  cameraSourceImageName: String,
                  videoSourceImageName: String,
                  assetType: MediaPickerServiceAssetType,
                  sourceType: MediaPickerServiceSourceType) {
        self.autoCloseOnSingleSelect = autoCloseOnSingleSelect
        self.showsCancelButton = showsCancelButton
        self.geoTagImages = geoTagImages
        self.maxSelectableCount = maxSelectableCount
        self.assetsPerRow = assetsPerRow
        self.titleFontSize = titleFontSize
        self.buttonFontSize = buttonFontSize
        self.insets = insets
        self.cornerRadius = cornerRadius
        self.navigationBarTitle = navigationBarTitle
        self.imagesSegmentTitle = imagesSegmentTitle
        self.videosSegmentTitle = videosSegmentTitle
        self.cancelButtonTitle = cancelButtonTitle
        self.doneButtonTitle = doneButtonTitle
        self.cameraSourceText = cameraSourceText
        self.videoSourceText = videoSourceText
        self.alertMaxSelectableAssetsTitle = alertMaxSelectableAssetsTitle
        self.alertMaxSelectableAssetsMessage = alertMaxSelectableAssetsMessage
        self.permissionDeniedAlertTitle = permissionDeniedAlertTitle
        self.permissionDeniedCameraAlertMessage = permissionDeniedCameraAlertMessage
        self.permissionDeniedPhotoLibraryAlertMessage = permissionDeniedPhotoLibraryAlertMessage
        self.permissionDeniedMicrophoneAlertMessage = permissionDeniedMicrophoneAlertMessage
        self.goToSettingsButtonText = goToSettingsButtonText
        self.continueWithoutButtonText = continueWithoutButtonText
        self.locationServicesNotEnabledTitle = locationServicesNotEnabledTitle
        self.locationServicesNotEnabledMessage = locationServicesNotEnabledMessage
        self.locationPermissionNotAcceptedTitle = locationPermissionNotAcceptedTitle
        self.locationPermissionNotAcceptedMessage = locationPermissionNotAcceptedMessage
        self.navigationBarColor = navigationBarColor
        self.backgroundColor = backgroundColor
        self.collectionViewBackgroundColor = collectionViewBackgroundColor
        self.titleColor = titleColor
        self.buttonColor = buttonColor
        self.sourceCellBackgroundColor = sourceCellBackgroundColor
        self.sourceCellTintColor = sourceCellTintColor
        self.segmentedControlTintColor = segmentedControlTintColor
        self.generalTextColor = generalTextColor
        self.assetBorderColor = assetBorderColor
        self.assetCountLabelColor = assetCountLabelColor
        self.textFont = textFont
        self.cameraSourceImageName = cameraSourceImageName
        self.videoSourceImageName = videoSourceImageName
        self.assetType = assetType
        self.sourceType = sourceType
    }
    
    public class Builder {
        private var autoCloseOnSingleSelect = false
        private var showsCancelButton = true
        private var geoTagImages = true
        private var maxSelectableCount = 0
        private var assetsPerRow = 3
        private var titleFontSize: CGFloat = 17
        private var buttonFontSize: CGFloat = 16
        private var insets: UIEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        private var cornerRadius: CGFloat = 0
        private var navigationBarTitle: String = "Media Picker"
        private var imagesSegmentTitle: String = "Images"
        private var videosSegmentTitle: String = "Videos"
        private var cancelButtonTitle: String = "Cancel"
        private var doneButtonTitle: String = "Done"
        private var cameraSourceText: String = "Take Photo"
        private var videoSourceText: String = "Record Video"
        private var alertMaxSelectableAssetsTitle: String = "Maximum assets reached"
        private var alertMaxSelectableAssetsMessage: String = "You can't pick more assets."
        private var permissionDeniedAlertTitle: String = "Permission denied"
        private var permissionDeniedCameraAlertMessage: String = "You need to give the app permission to use your camera to be able to take a photo."
        private var permissionDeniedPhotoLibraryAlertMessage: String = "You need to give the app permission to use your photo library to use the asset picker."
        private var permissionDeniedMicrophoneAlertMessage: String = "You need to give the app permission to use your microphone to record a video."
        private var goToSettingsButtonText: String = "Go to settings"
        private var continueWithoutButtonText: String = "Continue without"
        private var locationServicesNotEnabledTitle: String = "Location services is disabled"
        private var locationServicesNotEnabledMessage: String = "For the app to be able to geotag your images you have to turn location services on in settings on your iPhone.\n(Anonymity -> Location Services)"
        private var locationPermissionNotAcceptedTitle: String = "Location permission denied"
        private var locationPermissionNotAcceptedMessage: String = "For the app to be able to geotag your images you have to give the app permission to use your location in the app settings"
        private var navigationBarColor: UIColor = .white
        private var backgroundColor: UIColor = .white
        private var collectionViewBackgroundColor: UIColor = .white
        private var titleColor: UIColor = .black
        private var buttonColor: UIColor = .black
        private var sourceCellBackgroundColor: UIColor = .white
        private var sourceCellTintColor: UIColor = .black
        private var segmentedControlTintColor: UIColor = .black
        private var generalTextColor: UIColor = .black
        private var assetBorderColor: UIColor = .black
        private var assetCountLabelColor: UIColor = .white
        private var textFont: UIFont = .systemFont(ofSize: 14)
        private var cameraSourceImageName: String = "MAMediaCameraIcon"
        private var videoSourceImageName: String = "MAMediaVideoIcon"
        private var assetType: MediaPickerServiceAssetType = .both
        private var sourceType: MediaPickerServiceSourceType = .both
        
        public init() {}
        
        /// Auto close picker on single select. Default is false.
        public func setAutoCloseOnSingleSelect(_ bool: Bool) -> Builder {
            self.autoCloseOnSingleSelect = bool
            return self
        }
        
        /// A bool value indicating whether the picker shows the cancel button. Default is true.
        public func setShowsCancelButton(_ bool: Bool) -> Builder {
            self.showsCancelButton = bool
            return self
        }
        
        /// If this is set to true, the picker will ask for the users location and use this to geoTag all images taken in the picker. Default is true.
        public func setGeoTagImages(_ bool: Bool) -> Builder {
            self.geoTagImages = bool
            return self
        }
        
        /// The maximum count of assets which the user will be able to select, a value of 0 means no limit. Default is 0.
        public func setMaxSelectableCount(_ count: Int) -> Builder {
            self.maxSelectableCount = count
            return self
        }
        
        /// The number of assets to display per row. Default is 3.
        public func setAssetsPerRow(_ count: Int) -> Builder {
            self.assetsPerRow = count
            return self
        }
        
        /// The font size of the title. Default is 17.
        public func setTitleFontSize(_ size: CGFloat) -> Builder {
            self.titleFontSize = size
            return self
        }
        
        /// The font size of the buttons in the navigation bar. Default is 16.
        public func setButtonFontSize(_ bool: CGFloat) -> Builder {
            self.buttonFontSize = bool
            return self
        }
        
        /// The insets between the asset cells. Default is UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5).
        public func setInsets(_ insets: UIEdgeInsets) -> Builder {
            self.insets = insets
            return self
        }
        
        /// The corner radius of all the assets. Default is 0.
        public func setCornerRadius(_ cornerRadius: CGFloat) -> Builder {
            self.cornerRadius = cornerRadius
            return self
        }
        
        /// The navigation bar title. Default is "Media Picker".
        public func setNavigationBarTitle(_ string: String) -> Builder {
            self.navigationBarTitle = string
            return self
        }
        
        /// The title of the images segment. Default is "Images"
        public func setImagesSegmentTitle(_ string: String) -> Builder {
            self.imagesSegmentTitle = string
            return self
        }
        
        /// The title of the videos segment. Default is "Videos"
        public func setVideosSegmentTitle(_ string: String) -> Builder {
            self.videosSegmentTitle = string
            return self
        }
        
        /// The title on the cancel button. Default is "Cancel"
        public func setCancelButtonTitle(_ string: String) -> Builder {
            self.cancelButtonTitle = string
            return self
        }
        
        /// The title on the done button. Default is "Done"
        public func setDoneButtonTitle(_ string: String) -> Builder {
            self.doneButtonTitle = string
            return self
        }
        
        /// The text on the camera source cell. Default is "Take Photo"
        public func setCameraSourceText(_ string: String) -> Builder {
            self.cameraSourceText = string
            return self
        }
        
        /// The text on the video source cell. Default is "Record Video"
        public func setVideoSourceText(_ string: String) -> Builder {
            self.videoSourceText = string
            return self
        }
        
        /// The title of the alert shown when reached max selectable assets. Default is "Maximum assets reached"
        public func setAlertMaxSelectableAssetsTitle(_ string: String) -> Builder {
            self.alertMaxSelectableAssetsTitle = string
            return self
        }
        
        /// The message of the alert shown when reached max selectable assets. Default is "You can't pick more assets."
        public func setAlertMaxSelectableAssetsMessage(_ string: String) -> Builder {
            self.alertMaxSelectableAssetsMessage = string
            return self
        }
        
        /// The title of the alert shown when the user has denied permission. Default is "Permission denied"
        public func setPermissionDeniedAlertTitle(_ string: String) -> Builder {
            self.permissionDeniedAlertTitle = string
            return self
        }
        
        /// The message of the alert shown when the user has denied permission. Default is "You need to give the app permission to use your camera to be able to take a photo."
        public func setPermissionDeniedCameraAlertMessage(_ string: String) -> Builder {
            self.permissionDeniedCameraAlertMessage = string
            return self
        }
        
        /// The message of the alert shown when the user has denied permission. Default is "You need to give the app permission to use your photo library to use the asset picker."
        public func setPermissionDeniedPhotoLibraryAlertMessage(_ string: String) -> Builder {
            self.permissionDeniedPhotoLibraryAlertMessage = string
            return self
        }
        
        /// The message of the alert shown when the user has denied permission. Default is "You need to give the app permission to use your microphone to record a video."
        public func setPermissionDeniedMicrophoneAlertMessage(_ string: String) -> Builder {
            self.permissionDeniedMicrophoneAlertMessage = string
            return self
        }
        
        /// The text on the "Go To Settings" button of the alert shown when the user has denied permission. Default is "Go to settings"
        public func setGoToSettingsButtonText(_ string: String) -> Builder {
            self.goToSettingsButtonText = string
            return self
        }
        
        /// The text on the "Continue without" button of the alert shown when the user has denied location permission. Default is "Continue without"
        public func setContinueWithoutButtonText(_ string: String) -> Builder {
            self.continueWithoutButtonText = string
            return self
        }
        
        /// The title of the alert shown when the user has turned off location services on the device. Default is "Location services is disabled"
        public func setLocationServicesNotEnabledTitle(_ string: String) -> Builder {
            self.locationServicesNotEnabledTitle = string
            return self
        }
        
        /// The message of the alert shown when the user has turned off location services on the device. Default is "For the app to be able to geotag your images you have to turn this on in settings on your iPhone"
        public func setLocationServicesNotEnabledMessage(_ string: String) -> Builder {
            self.locationServicesNotEnabledMessage = string
            return self
        }
        
        /// The title of the alert shown when the user has denied to share their location with the app. Default is "Location permission denied"
        public func setLocationPermissionNotAcceptedTitle(_ string: String) -> Builder {
            self.locationPermissionNotAcceptedTitle = string
            return self
        }
        
        /// The message of the alert shown when the user has denied to share their location with the app. Default is "For the app to be able to geotag your images you have to give the app permission to use your location in the app settings"
        public func setLocationPermissionNotAcceptedMessage(_ string: String) -> Builder {
            self.locationPermissionNotAcceptedMessage = string
            return self
        }
        
        /// The color the picker should use on the navigation bar. Default is .white.
        public func setNavigationBarColor(_ color: UIColor) -> Builder {
            self.navigationBarColor = color
            return self
        }
        
        /// The background color of the picker. Default is .white.
        public func setBackgroundColor(_ color: UIColor) -> Builder {
            self.backgroundColor = color
            return self
        }
        
        /// The background color of the assets collectionview. Default is .white.
        public func setCollectionViewBackgroundColor(_ color: UIColor) -> Builder {
            self.collectionViewBackgroundColor = color
            return self
        }
        
        /// The color of the title in the navigation bar. Default is .black.
        public func setTitleColor(_ color: UIColor) -> Builder {
            self.titleColor = color
            return self
        }
        
        /// The color of the cancel and done buttons in the navigation bar. Default is .black.
        public func setButtonColor(_ color: UIColor) -> Builder {
            self.buttonColor = color
            return self
        }
        
        /// The color to use for the source cells background. Default is .white.
        public func setSourceCellBackgroundColor(_ color: UIColor) -> Builder {
            self.sourceCellBackgroundColor = color
            return self
        }
        
        /// The tint color of the source icon. Default is .black.
        public func setSourceCellTintColor(_ color: UIColor) -> Builder {
            self.sourceCellTintColor = color
            return self
        }
        
        /// The tint color of the segmented control. Default is .black.
        public func setSegmentedControlTintColor(_ color: UIColor) -> Builder {
            self.segmentedControlTintColor = color
            return self
        }
        
        /// The color the picker should use on secondary text elements. Default is .black.
        public func setGeneralTextColor(_ color: UIColor) -> Builder {
            self.generalTextColor = color
            return self
        }
        
        /// The border color of selected assets. Default is .black.
        public func setAssetBorderColor(_ color: UIColor) -> Builder {
            self.assetBorderColor = color
            return self
        }
        
        /// The color of the count label on selected assets. Default is .white.
        public func setAssetCountLabelColor(_ color: UIColor) -> Builder {
            self.assetCountLabelColor = color
            return self
        }
        
        /// The font to use with all text. The size will be overridden by the *titleFontSize* and *buttonFontSize* properties.
        public func setTextFont(_ font: UIFont) -> Builder {
            self.textFont = font
            return self
        }
        
        /// The icon to use for the camera source. Default icon is *MAMediaCameraIcon*.
        public func setCameraSourceImageName(_ name: String) -> Builder {
            self.cameraSourceImageName = name
            return self
        }
        
        /// The icon to use for the video source. Default icon is *MAMediaVideoIcon*.
        public func setVideoSourceImageName(_ name: String) -> Builder {
            self.videoSourceImageName = name
            return self
        }
        
        /// The type of assets to be displayed by the controller. Default is .both.
        public func setAssetType(_ type: MediaPickerServiceAssetType) -> Builder {
            self.assetType = type
            return self
        }
        
        /// Defines if it should be possible for the user to take a photo or record a video. Default is .both.
        public func setSourceType(_ type: MediaPickerServiceSourceType) -> Builder {
            self.sourceType = type
            return self
        }
        
        public func build() -> MediaPickerServiceSettings {
            return MediaPickerServiceSettings(
                autoCloseOnSingleSelect: autoCloseOnSingleSelect,
                showsCancelButton: showsCancelButton,
                geoTagImages: geoTagImages,
                maxSelectableCount: maxSelectableCount,
                assetsPerRow: assetsPerRow,
                titleFontSize: titleFontSize,
                buttonFontSize: buttonFontSize,
                insets: insets,
                cornerRadius: cornerRadius,
                navigationBarTitle: navigationBarTitle,
                imagesSegmentTitle: imagesSegmentTitle,
                videosSegmentTitle: videosSegmentTitle,
                cancelButtonTitle: cancelButtonTitle,
                doneButtonTitle: doneButtonTitle,
                cameraSourceText: cameraSourceText,
                videoSourceText: videoSourceText,
                alertMaxSelectableAssetsTitle: alertMaxSelectableAssetsTitle,
                alertMaxSelectableAssetsMessage: alertMaxSelectableAssetsMessage,
                permissionDeniedAlertTitle: permissionDeniedAlertTitle,
                permissionDeniedCameraAlertMessage: permissionDeniedCameraAlertMessage,
                permissionDeniedPhotoLibraryAlertMessage: permissionDeniedPhotoLibraryAlertMessage,
                permissionDeniedMicrophoneAlertMessage: permissionDeniedMicrophoneAlertMessage,
                goToSettingsButtonText: goToSettingsButtonText,
                continueWithoutButtonText: continueWithoutButtonText,
                locationServicesNotEnabledTitle: locationServicesNotEnabledTitle,
                locationServicesNotEnabledMessage: locationServicesNotEnabledMessage,
                locationPermissionNotAcceptedTitle: locationPermissionNotAcceptedTitle,
                locationPermissionNotAcceptedMessage: locationPermissionNotAcceptedMessage,
                navigationBarColor: navigationBarColor,
                backgroundColor: backgroundColor,
                collectionViewBackgroundColor: collectionViewBackgroundColor,
                titleColor: titleColor,
                buttonColor: buttonColor,
                sourceCellBackgroundColor: sourceCellBackgroundColor,
                sourceCellTintColor: sourceCellTintColor,
                segmentedControlTintColor: segmentedControlTintColor,
                generalTextColor: generalTextColor,
                assetBorderColor: assetBorderColor,
                assetCountLabelColor: assetCountLabelColor,
                textFont: textFont,
                cameraSourceImageName: cameraSourceImageName,
                videoSourceImageName: videoSourceImageName,
                assetType: assetType,
                sourceType: sourceType)
        }
    }
}
