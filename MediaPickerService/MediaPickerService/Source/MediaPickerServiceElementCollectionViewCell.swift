//
//  MediaPickerServiceElementCollectionViewCell.swift
//
//  Created by Martin Lindhof Simonsen on 06/01/2019.
//  Copyright © 2019 makeable. All rights reserved.
//

import UIKit
import Photos

public class MediaPickerServiceElementCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var videoLabel: UILabel!
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var countView: UIView!
    @IBOutlet weak var countLabel: UILabel!
    
    static let identifier = "MediaPickerServiceElementCollectionViewCellIdentifier"
    static let nibName = "MediaPickerServiceElementCollectionViewCell"
    
    private let imageManager = PHImageManager.default()
    public var imageOptions: PHImageRequestOptions!
    public var videoOptions: PHVideoRequestOptions!
    
    public var selectionColor: UIColor = .black {
        didSet {
            self.containerView.layer.borderColor = selectionColor.cgColor
            self.countView.backgroundColor = selectionColor
        }
    }
    
    public var count: Int! {
        didSet {
            if let count = count {
                self.countLabel.text = "\(count)"
                self.containerView.layer.borderWidth = 4
                self.countView.isHidden = false
            } else {
                self.countView.isHidden = true
                self.countLabel.text = ""
                self.containerView.layer.borderWidth = 0
            }
        }
    }
    
    public var asset: PHAsset! {
        didSet {
            if asset != nil {
                let size = CGSize(width: 200, height: 200)
                imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: imageOptions) { (image, info) in
                    self.cellImageView.image = image
                }
                if asset.mediaType == .video {
                    let duration = Int(asset!.duration.rounded())
                    let minutes = duration / 60 % 60
                    let seconds = duration % 60
                    self.videoLabel.text = String.init(format: "%i:%02d", minutes, seconds)
                    self.videoView.isHidden = false
                } else {
                    self.videoView.isHidden = true
                }
            }
        }
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override public func prepareForReuse() {
        cellImageView.image = nil
        self.containerView.layer.borderWidth = 0
        self.containerView.layer.borderColor = selectionColor.cgColor
    }
    
    private func setupUI() {
        self.videoImageView.image = UIImage(named: "MAMediaVideoIcon")?.withRenderingMode(.alwaysTemplate)
        self.videoImageView.tintColor = .white
        self.containerView.layer.borderWidth = 0
        self.containerView.layer.borderColor = selectionColor.cgColor
        self.countView.backgroundColor = selectionColor
    }
}
