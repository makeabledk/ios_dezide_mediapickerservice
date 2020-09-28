//
//  MediaPickerService.swift
//
//  Created by Martin Lindhof Simonsen on 06/01/2019.
//  Copyright © 2019 makeable. All rights reserved.
//

import UIKit
import Photos
import AssetsLibrary
import MobileCoreServices

public typealias MediaPickerServiceAssetsCompletion = (_ assets: [PHAsset]) -> Void
public typealias MediaPickerServiceCancelCompletion = () -> Void

/// This service class will make it easy to implement interaction with photos or videos.
public class MediaPickerService {
    
    // MARK: - Private variables
    /// The owner of the service.
    public let owner: UIViewController
    
    // MARK: - Public variables
    /// The mediapicker currently presented if any.
    fileprivate var mediaPicker: MediaPickerServiceViewController?
    
    // The pod bundle
    fileprivate var mediaPickerServiceBundle: Bundle?
    
    /// Settings for the picker
    private var settings = MediaPickerServiceSettings.Builder().build()
    
    /// Gets called when the user press select in the picker
    private var didSelectAssets: MediaPickerServiceAssetsCompletion?
    
    /// Gets called when the user press cancel in the picker
    private var didCancel: MediaPickerServiceCancelCompletion?
    
    // MARK: - Init
    public init(owner: UIViewController) {
        self.owner = owner
        
        let podBundle = Bundle(for: MediaPickerService.self)
        if let url = podBundle.url(forResource: "MediaPickerService", withExtension: "bundle"), let mediaPickerServiceBundle = Bundle(url: url) {
            self.mediaPickerServiceBundle = mediaPickerServiceBundle
        }
    }
    
    public func setSettings(_ settings: MediaPickerServiceSettings) {
        self.settings = settings
    }
    
    /// Sets the callback for when the user finishes picking assets.
    public func setDidSelectAssetsCallback(completion: @escaping MediaPickerServiceAssetsCompletion) {
        self.didSelectAssets = completion
        if let mediaPicker = mediaPicker {
            mediaPicker.didSelectAssets = self.didSelectAssets
        }
    }
    
    /// Sets the callback for when the user cancels the picker.
    public func setDidCancelCallback(completion: @escaping MediaPickerServiceCancelCompletion) {
        self.didCancel = completion
        if let mediaPicker = mediaPicker {
            mediaPicker.didCancel = self.didCancel
        }
    }
    
    /// This function will present the asset picker with the settings from the MAAssetService settings object.
    /// - Parameter animated: If *animated* is set to true, the asset picker will be presented with an animation
    /// - Parameter completion: This will get called when the asset picker has finished being presented.
    public func presentPicker(animated: Bool, completion: (() -> Void)?) {
        let mediaPickerVC = MediaPickerServiceViewController(nibName: "MediaPickerServiceViewController", bundle: mediaPickerServiceBundle)
        mediaPickerVC.modalPresentationStyle = .fullScreen
        mediaPicker = mediaPickerVC
        mediaPicker!.owner = self
        mediaPicker!.settings = settings
        mediaPicker!.didSelectAssets = didSelectAssets
        mediaPicker!.didCancel = didCancel
        
        owner.present(mediaPicker!, animated: animated, completion: completion)
    }
    
    // MARK: - Helper functions
    /// Checks if the current device is an iPhone X
    /// - Returns: true if the device an iPhone X else false.
    static func isIphoneX() -> Bool {
        let heights: [CGFloat] = [2436, 1792, 2688]
        return UIDevice().userInterfaceIdiom == .phone && heights.contains(UIScreen.main.nativeBounds.height)
    }
    
    /// Rounds the specified *corners* of the *layer* with the specified *radius*.
    /// - Parameter layer: The layer to round.
    /// - Parameter corners: The corners to round. Used like this: [.topLeft, .topRight, .bottomLeft, .bottomRight]
    /// - Parameter radius: The radius of the rounded corners.
    static func roundCorners(layer: CALayer, corners: UIRectCorner, radius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: layer.bounds,
                                    byRoundingCorners: corners,
                                    cornerRadii: CGSize(width: radius, height: radius))
        
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        layer.mask = shape
    }
}

// MARK: - MediaPickerServiceViewController
/// This viewcontroller class controls the picker.
public class MediaPickerServiceViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var statusBarView: UIView!
    @IBOutlet weak var navigationBarView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var statusBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewTopConstraintToSegmentedControl: NSLayoutConstraint!
    
    // MARK: - Private variables
    private enum PermissionType {
        case photoLibrary, camera, microphone
    }
    
    var owner: MediaPickerService!
    
    private let imageManager = PHImageManager.default()
    private var imageOptions = PHImageRequestOptions()
    private var videoOptions = PHVideoRequestOptions()
    
    private var allAssets: PHFetchResult<PHAsset>?
    private var allPhotos = [PHAsset]()
    private var allVideos = [PHAsset]()
    
    private var didFetch = false
    private var didAskForLocation = false
    private var isLocationUpdating = false
    private var shouldAutoSelectFirstImageAsset = false
    private var shouldAutoSelectFirstVideoAsset = false
    
    private var locationManager: CLLocationManager!
    private var latestLocation: CLLocation?
    
    private var segmentedControlTimer: Timer?
    
    private var selectedImagesIndexPaths = [IndexPath]() {
        didSet {
            collectionView.reloadItems(at: selectedImagesIndexPaths)
        }
    }
    
    private var selectedVideosIndexPaths = [IndexPath]() {
        didSet {
            collectionView.reloadItems(at: selectedVideosIndexPaths)
        }
    }
    
    private var selectedAssets = [PHAsset]() {
        didSet {
            if selectedAssets.count > 0 {
                doneButton.setTitle(settings.doneButtonTitle + " (\(selectedAssets.count))", for: .normal)
                doneButton.isHidden = false
            } else {
                doneButton.isHidden = true
            }
        }
    }
    
    // MARK: - Public variables
    var settings: MediaPickerServiceSettings! {
        didSet {
            imageOptions.isNetworkAccessAllowed = true
            videoOptions.isNetworkAccessAllowed = true
        }
    }
    var didSelectAssets: ((_ assets: [PHAsset]) -> Void)?
    var didCancel: (() -> Void)?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        registerCells()
        setupUI()
        setupLocationManager()
        requestAuth { (status) in
            switch status {
            case .authorized:
                self.fetchAssets()
            case .denied, .restricted:
                self.handlePermissionDenied(type: .photoLibrary)
            default: // .notDetermined & .limited
                // This should never happen.
                break
            }
            
            if self.settings.geoTagImages {
                self.requestLocation()
            }
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent {
            locationManager.stopUpdatingLocation()
        }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocation()
    }
    
    private func requestLocation() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            if !CLLocationManager.locationServicesEnabled() {
                let alert = UIAlertController(title: settings.locationServicesNotEnabledTitle, message: settings.locationServicesNotEnabledMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else if CLLocationManager.authorizationStatus() == .denied {
                let alert = UIAlertController(title: settings.locationPermissionNotAcceptedTitle, message: settings.locationPermissionNotAcceptedMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: settings.goToSettingsButtonText, style: .default, handler: { (action) in
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }))
                alert.addAction(UIAlertAction(title: settings.continueWithoutButtonText, style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        didAskForLocation = true
    }
    
    private func checkLocation() {
        if didAskForLocation {
            if CLLocationManager.locationServicesEnabled() && CLLocationManager.authorizationStatus() == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
        }
    }
    
    private func registerCells() {
        collectionView.register(UINib(nibName: MediaPickerServiceSourceCollectionViewCell.nibName, bundle: owner.mediaPickerServiceBundle), forCellWithReuseIdentifier: MediaPickerServiceSourceCollectionViewCell.identifier)
        collectionView.register(UINib(nibName: MediaPickerServiceElementCollectionViewCell.nibName, bundle: owner.mediaPickerServiceBundle), forCellWithReuseIdentifier: MediaPickerServiceElementCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func setupUI() {
        setupViews()
        setupColors()
        setupText()
    }
    
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func setupViews() {
        if MediaPickerService.isIphoneX() {
            statusBarHeightConstraint.constant = 44
        }
        
        if settings.assetType != .both {
            self.segmentedControl.isHidden = true
            self.collectionViewTopConstraintToSegmentedControl.priority = UILayoutPriority(rawValue: 250)
        }
        
        self.cancelButton.isHidden = !settings.showsCancelButton
    }
    
    private func setupColors() {
        self.view.backgroundColor = .white
        self.navigationView.backgroundColor = settings.navigationBarColor
        self.collectionView.backgroundColor = settings.collectionViewBackgroundColor
        self.titleLabel.textColor = settings.titleColor
        self.cancelButton.setTitleColor(settings.buttonColor, for: .normal)
        self.doneButton.setTitleColor(settings.buttonColor, for: .normal)
        
        if #available(iOS 13.0, *) {
            self.segmentedControl.ensureiOS12Style(tintColor: settings.segmentedControlTintColor)
        } else {
            self.segmentedControl.tintColor = settings.segmentedControlTintColor
        }
        
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: settings.segmentedControlTintColor,
                                                 NSAttributedString.Key.font: settings.textFont.withSize(15)], for: .normal)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white,
                                                 NSAttributedString.Key.font: settings.textFont.withSize(15)], for: .selected)
    }
    
    private func setupText() {
        titleLabel.text = settings.navigationBarTitle
        cancelButton.setTitle(settings.cancelButtonTitle, for: .normal)
        doneButton.setTitle(settings.doneButtonTitle, for: .normal)
        segmentedControl.setTitle(settings.imagesSegmentTitle, forSegmentAt: 0)
        segmentedControl.setTitle(settings.videosSegmentTitle, forSegmentAt: 1)
        doneButton.isHidden = true
        titleLabel.font = settings.textFont.withSize(settings.titleFontSize)
        cancelButton.titleLabel?.font = settings.textFont.withSize(settings.buttonFontSize)
        doneButton.titleLabel?.font = settings.textFont.withSize(settings.buttonFontSize)
    }
    
    private func requestAuth(completion: @escaping (_ status: PHAuthorizationStatus) -> Void) {
        PHPhotoLibrary.requestAuthorization { (status) in
            completion(status)
        }
    }
    
    private func fetchAssets() {
        let fetchOptions = PHFetchOptions()
        let sortOrder = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.sortDescriptors = sortOrder
        if #available(iOS 9.0, *) {
            fetchOptions.includeAssetSourceTypes = [.typeUserLibrary, .typeCloudShared, .typeiTunesSynced]
        } else {
            // Fallback on earlier versions
        }
        
        switch settings.assetType {
        case .both:
            allAssets = PHAsset.fetchAssets(with: fetchOptions)
        case .photos:
            allAssets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        case .videos:
            allAssets = PHAsset.fetchAssets(with: .video, options: fetchOptions)
        }
        for i in 0..<allAssets!.count {
            let asset = allAssets![i]
            if asset.mediaType == .image {
                allPhotos.append(asset)
            } else if asset.mediaType == .video {
                allVideos.append(asset)
            }
        }
        didFetch = true
        
        PHPhotoLibrary.shared().register(self)
        
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.collectionView.reloadData()
        }
    }
    
    private func handlePermissionDenied(type: PermissionType) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let title = self.settings.permissionDeniedAlertTitle
            var message: String!
            switch type {
            case .camera:
                message = self.settings.permissionDeniedCameraAlertMessage
            case .photoLibrary:
                message = self.settings.permissionDeniedPhotoLibraryAlertMessage
            case .microphone:
                message = self.settings.permissionDeniedMicrophoneAlertMessage
            }
            
            let goToSettings = self.settings.goToSettingsButtonText
            let cancel = self.settings.cancelButtonTitle
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: cancel, style: .destructive, handler: { (action) in
                self.dismiss(animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: goToSettings, style: .default, handler: { (action) in
                let settingsUrl = URL(string: UIApplication.openSettingsURLString)!
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            self.dismiss(animated: true, completion: nil)
                        })
                    } else {
                        // Fallback on earlier versions
                    }
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: Any) {
        self.collectionView.reloadData()
    }
    
    @IBAction func cancelBtnPressed(_ sender: UIButton) {
        self.didCancel?()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneBtnPressed(_ sender: UIButton) {
        self.didSelectAssets?(self.selectedAssets)
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Extension UICollectionViewDataSource
extension MediaPickerServiceViewController: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return didFetch ? 1 : 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch settings.assetType {
        case .both:
            let selectedIndex = self.segmentedControl.selectedSegmentIndex
            if selectedIndex == 0 {
                if settings.sourceType == .camera || settings.sourceType == .both {
                    return allPhotos.count + 1
                }
                return allPhotos.count
            } else {
                if settings.sourceType == .video || settings.sourceType == .both {
                    return allVideos.count + 1
                }
                return allVideos.count
            }
        case .photos:
            if settings.sourceType == .camera || settings.sourceType == .both {
                return allPhotos.count + 1
            }
            return allPhotos.count
        case .videos:
            if settings.sourceType == .video || settings.sourceType == .both {
                return allVideos.count + 1
            }
            return allVideos.count
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let sourceCell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaPickerServiceSourceCollectionViewCell.identifier, for: indexPath) as! MediaPickerServiceSourceCollectionViewCell
            switch settings.assetType {
            case .photos:
                if settings.sourceType == .camera || settings.sourceType == .both {
                    sourceCell.sourceType = .camera
                    
                    if let image = UIImage(named: self.settings.cameraSourceImageName) {
                        sourceCell.cellImageView.image = image.withRenderingMode(.alwaysTemplate)
                    } else {
                        sourceCell.cellImageView.image =  UIImage(named: self.settings.cameraSourceImageName, in: owner.mediaPickerServiceBundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                    }
                    
                    sourceCell.cellLabel.text = settings.cameraSourceText
                }
            case .videos:
                if settings.sourceType == .video || settings.sourceType == .both {
                    sourceCell.sourceType = .video
                    
                    if let image = UIImage(named: self.settings.videoSourceImageName) {
                        sourceCell.cellImageView.image = image.withRenderingMode(.alwaysTemplate)
                    } else {
                        sourceCell.cellImageView.image =  UIImage(named: self.settings.videoSourceImageName, in: owner.mediaPickerServiceBundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                    }
                    
                    sourceCell.cellLabel.text = settings.videoSourceText
                }
            default: // .both
                let selectedIndex = self.segmentedControl.selectedSegmentIndex
                if selectedIndex == 0 {
                    if settings.sourceType == .camera || settings.sourceType == .both {
                        sourceCell.sourceType = .camera
                        
                        if let image = UIImage(named: self.settings.cameraSourceImageName) {
                            sourceCell.cellImageView.image = image.withRenderingMode(.alwaysTemplate)
                        } else {
                            sourceCell.cellImageView.image =  UIImage(named: self.settings.cameraSourceImageName, in: owner.mediaPickerServiceBundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                        }
                        
                        sourceCell.cellLabel.text = settings.cameraSourceText
                    }
                } else {
                    if settings.sourceType == .video || settings.sourceType == .both {
                        sourceCell.sourceType = .video
                        
                        if let image = UIImage(named: self.settings.videoSourceImageName) {
                            sourceCell.cellImageView.image = image.withRenderingMode(.alwaysTemplate)
                        } else {
                            sourceCell.cellImageView.image =  UIImage(named: self.settings.videoSourceImageName, in: owner.mediaPickerServiceBundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                        }
                        
                        sourceCell.cellLabel.text = settings.videoSourceText
                    }
                }
            }
            
            if sourceCell.sourceType != nil {
                sourceCell.containerView.backgroundColor = settings.sourceCellBackgroundColor
                sourceCell.cellImageView.tintColor = settings.sourceCellTintColor
                sourceCell.cellLabel.font = settings.textFont.withSize(15)
                sourceCell.cellLabel.textColor = settings.generalTextColor
                sourceCell.containerView.layer.cornerRadius = settings.cornerRadius
                return sourceCell
            }
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaPickerServiceElementCollectionViewCell.identifier, for: indexPath) as! MediaPickerServiceElementCollectionViewCell
        
        var asset: PHAsset
        switch settings.assetType {
        case .both:
            if segmentedControl.selectedSegmentIndex == 0 {
                if settings.sourceType == .camera || settings.sourceType == .both {
                    asset = allPhotos[indexPath.row - 1]
                } else {
                    asset = allPhotos[indexPath.row]
                }
                cell.imageOptions = imageOptions
            } else {
                if settings.sourceType == .video || settings.sourceType == .both {
                    asset = allVideos[indexPath.row - 1]
                } else {
                    asset = allVideos[indexPath.row]
                }
                cell.videoOptions = videoOptions
            }
        case .photos:
            if settings.sourceType == .camera || settings.sourceType == .both {
                asset = allPhotos[indexPath.row - 1]
            } else {
                asset = allPhotos[indexPath.row]
            }
            cell.imageOptions = imageOptions
        case .videos:
            if settings.sourceType == .video || settings.sourceType == .both {
                asset = allVideos[indexPath.row - 1]
            } else {
                asset = allVideos[indexPath.row]
            }
            cell.videoOptions = videoOptions
        }
        
        cell.containerView.layer.cornerRadius = settings.cornerRadius
        MediaPickerService.roundCorners(layer: cell.countView.layer, corners: .bottomLeft, radius: settings.cornerRadius)
        cell.asset = asset
        cell.countLabel.textColor = settings.assetCountLabelColor
        cell.selectionColor = settings.assetBorderColor
        
        if let index = selectedAssets.firstIndex(of: asset) {
            cell.count = index + 1
        } else {
            cell.count = nil
        }
        
        if self.shouldAutoSelectFirstImageAsset {
            if cell.asset.mediaType == .image {
                shouldAutoSelectFirstImageAsset = false
                self.selectedAssets.append(cell.asset)
                if let index = selectedAssets.firstIndex(of: cell.asset) {
                    cell.count = index + 1
                    selectedImagesIndexPaths.append(indexPath)
                    
                    for i in 0..<selectedImagesIndexPaths.count - 1 {
                        let currentIndexPath = selectedImagesIndexPaths[i]
                        let newIndexPath = IndexPath(row: currentIndexPath.row + 1, section: currentIndexPath.section)
                        selectedImagesIndexPaths[i] = newIndexPath
                    }
                }
                
                if settings.autoCloseOnSingleSelect {
                    doneBtnPressed(doneButton)
                }
            }
        } else if self.shouldAutoSelectFirstVideoAsset {
            if cell.asset.mediaType == .video {
                shouldAutoSelectFirstVideoAsset = false
                self.selectedAssets.append(cell.asset)
                if let index = selectedAssets.firstIndex(of: cell.asset) {
                    cell.count = index + 1
                    selectedVideosIndexPaths.append(indexPath)
                    
                    for i in 0..<selectedVideosIndexPaths.count - 1 {
                        let currentIndexPath = selectedVideosIndexPaths[i]
                        let newIndexPath = IndexPath(row: currentIndexPath.row + 1, section: currentIndexPath.section)
                        selectedVideosIndexPaths[i] = newIndexPath
                    }
                }
                if settings.autoCloseOnSingleSelect {
                    doneBtnPressed(doneButton)
                }
            }
        }
        
        cell.containerView.backgroundColor = settings.backgroundColor
        return cell
    }
}

// MARK: - Extension UICollectionViewDelegate
extension MediaPickerServiceViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? MediaPickerServiceSourceCollectionViewCell {
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                let alert = UIAlertController(title: "No camera", message: "The device you use, does not support camera.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            if settings.maxSelectableCount == 0 || self.selectedAssets.count < settings.maxSelectableCount {
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted: Bool) -> Void in
                    if granted == true {
                        DispatchQueue.main.async {
                            let imagePicker = UIImagePickerController()
                            imagePicker.delegate = self
                            imagePicker.sourceType = .camera
                            if cell.sourceType == .camera {
                                self.present(imagePicker, animated: true, completion: nil)
                            } else if cell.sourceType == .video {
                                imagePicker.videoQuality = .typeHigh
                                imagePicker.mediaTypes = [kUTTypeMovie as String]
                                imagePicker.allowsEditing = false
                                AVCaptureDevice.requestAccess(for: AVMediaType.audio, completionHandler: { (granted: Bool) -> Void in
                                    if granted == true {
                                        DispatchQueue.main.async {
                                            self.present(imagePicker, animated: true, completion: nil)
                                        }
                                    } else {
                                        self.handlePermissionDenied(type: .microphone)
                                    }
                                })
                            }
                        }
                    } else {
                        self.handlePermissionDenied(type: .camera)
                    }
                })
            } else {
                let title = self.settings.alertMaxSelectableAssetsTitle
                let message = self.settings.alertMaxSelectableAssetsMessage
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        } else if let cell = collectionView.cellForItem(at: indexPath) as? MediaPickerServiceElementCollectionViewCell {
            self.segmentedControl.isUserInteractionEnabled = false
            segmentedControlTimer?.invalidate()
            if #available(iOS 10.0, *) {
                segmentedControlTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { (timer) in
                    timer.invalidate()
                    self.segmentedControl.isUserInteractionEnabled = true
                }
            } else {
                // Fallback on earlier versions
            }
            if cell.count != nil {
                self.selectedAssets.removeAll { (asset) -> Bool in
                    return cell.asset == asset
                }
                cell.count = nil
                if cell.asset.mediaType == .image {
                    selectedImagesIndexPaths.removeAll { (selectedIndexPath) -> Bool in
                        return indexPath == selectedIndexPath
                    }
                } else {
                    selectedVideosIndexPaths.removeAll { (selectedIndexPath) -> Bool in
                        return indexPath == selectedIndexPath
                    }
                }
            } else {
                if settings.maxSelectableCount == 0 || self.selectedAssets.count < settings.maxSelectableCount {
                    self.selectedAssets.append(cell.asset)
                    if let index = selectedAssets.firstIndex(of: cell.asset) {
                        cell.count = index + 1
                    }
                    if cell.asset.mediaType == .image {
                        selectedImagesIndexPaths.append(indexPath)
                    } else {
                        selectedVideosIndexPaths.append(indexPath)
                    }
                    if settings.autoCloseOnSingleSelect {
                        doneBtnPressed(doneButton)
                    }
                } else {
                    let title = settings.alertMaxSelectableAssetsTitle
                    let message = settings.alertMaxSelectableAssetsMessage
                    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}

// MARK: - Extension UICollectionViewDelegateFlowLayout
extension MediaPickerServiceViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacingBetweenCells: CGFloat = settings.insets.left
        let paddingSpace = spacingBetweenCells * CGFloat(settings.assetsPerRow + 1)
        let availableWidth = collectionView.frame.width - paddingSpace
        let widthPerItem = availableWidth / CGFloat(settings.assetsPerRow)
        let heightPerItem = widthPerItem
        return CGSize(width: widthPerItem, height: heightPerItem)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return settings.insets
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return settings.insets.left
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return settings.insets.left
    }
}

// MARK: - Extension UIImagePickerControllerDelegate
extension MediaPickerServiceViewController: UIImagePickerControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String {
            if mediaType == (kUTTypeMovie as String) { // Video
                if let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL, UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path) {
                    UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, #selector(video(_:didFinishSavingWithError:contextInfo:)), nil)
                }
            } else { // Photo
                if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage, let meta = info[UIImagePickerController.InfoKey.mediaMetadata] as? NSDictionary {
                    let data = NSMutableData()
                    if let location = self.locationManager.location {
                        if let jpeg = image.jpegData(compressionQuality: 1.0),
                            let src = CGImageSourceCreateWithData(jpeg as CFData, nil),
                            let uti = CGImageSourceGetType(src),
                            let dest = CGImageDestinationCreateWithData(data as CFMutableData, uti, 1, nil) {
                            let meta2 = NSMutableDictionary.init(dictionary: meta as! [AnyHashable : Any])
                            
                            let gpsDictionary:[String : Any] = [kCGImagePropertyGPSLatitude as String: location.coordinate.latitude,
                                                                kCGImagePropertyGPSLongitude as String: location.coordinate.longitude,
                                                                kCGImagePropertyGPSAltitude as String: location.altitude,
                                                                kCGImagePropertyGPSDateStamp as String: location.timestamp,
                                                                kCGImagePropertyGPSSpeed as String: location.speed]
                            
                            meta2.setValue(gpsDictionary, forKey: kCGImagePropertyGPSDictionary as String)
                            
                            CGImageDestinationAddImageFromSource(dest, src, 0, meta2)
                            CGImageDestinationFinalize(dest)
                            PHPhotoLibrary.shared().performChanges({
                                if #available(iOS 9.0, *) {
                                    let request = PHAssetCreationRequest.forAsset()
                                    request.addResource(with: PHAssetResourceType.photo, data: data as Data, options: nil)
                                    request.location = location
                                }
                            }, completionHandler: { (success, error) in
                                guard error == nil && success else {
                                    let ac = UIAlertController(title: "Save error", message: error!.localizedDescription, preferredStyle: .alert)
                                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                                    return self.present(ac, animated: true)
                                }
                                self.shouldAutoSelectFirstImageAsset = true
                            })
                        }
                    } else {
                        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
                    }
                }
            }
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            shouldAutoSelectFirstImageAsset = true
        }
    }
    
    @objc func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            shouldAutoSelectFirstVideoAsset = true
        }
    }
}

extension MediaPickerServiceViewController: UINavigationControllerDelegate {}

extension MediaPickerServiceViewController: PHPhotoLibraryChangeObserver {
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            let fetchResultChangeDetails = changeInstance.changeDetails(for: self.allAssets!)
            
            guard (fetchResultChangeDetails) != nil else { return }
            
            self.allAssets = (fetchResultChangeDetails?.fetchResultAfterChanges)!
            
            self.allPhotos = [PHAsset]()
            self.allVideos = [PHAsset]()
            
            for i in 0..<self.allAssets!.count {
                let asset = self.allAssets![i]
                if asset.mediaType == .image {
                    self.allPhotos.append(asset)
                } else if asset.mediaType == .video {
                    self.allVideos.append(asset)
                }
            }
            
            if self.settings.autoCloseOnSingleSelect && (self.shouldAutoSelectFirstImageAsset || self.shouldAutoSelectFirstVideoAsset) {
                if let asset = fetchResultChangeDetails?.changedObjects.first {
                    self.selectedAssets.append(asset)
                    self.doneBtnPressed(self.doneButton)
                }
            } else {
                self.collectionView.reloadData()
            }
        }
    }
}

extension MediaPickerServiceViewController: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            self.locationManager.startUpdatingLocation()
        default:
            self.locationManager.stopUpdatingLocation()
        }
    }
}

extension UISegmentedControl {
    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor);
        context!.fill(rect);
        let theImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return theImage ?? UIImage()
    }
    
    func ensureiOS12Style(tintColor: UIColor) {
        if #available(iOS 13, *) {
            self.tintColor = tintColor
            let tintColorImage = imageWithColor(color: tintColor)
            // Must set the background image for normal to something (even clear) else the rest won't work
            setBackgroundImage(imageWithColor(color: backgroundColor ?? .clear), for: .normal, barMetrics: .default)
            setBackgroundImage(tintColorImage, for: .selected, barMetrics: .default)
            setBackgroundImage(imageWithColor(color: tintColor.withAlphaComponent(0.2)), for: .highlighted, barMetrics: .default)
            setBackgroundImage(tintColorImage, for: [.highlighted, .selected], barMetrics: .default)
            setDividerImage(tintColorImage, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
            layer.borderWidth = 1
            layer.borderColor = tintColor.cgColor
        }
    }
}
