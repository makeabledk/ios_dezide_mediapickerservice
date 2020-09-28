//
//  MediaPickerServiceSourceCollectionViewCell.swift
//
//  Created by Martin Lindhof Simonsen on 06/01/2019.
//  Copyright © 2019 makeable. All rights reserved.
//

import UIKit

class MediaPickerServiceSourceCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var cellLabel: UILabel!
    
    static let identifier = "MediaPickerServiceSourceCollectionViewCellIdentifier"
    static let nibName = "MediaPickerServiceSourceCollectionViewCell"

    var sourceType: MediaPickerServiceSourceType!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.sourceType = nil
    }
}
