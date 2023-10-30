//
//  FavoriteTableViewCell.swift
//  firstApp
//
//  Created by Paul James on 31.10.2023.
//

import UIKit

class FavoriteTableViewCell: UITableViewCell {

    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var soundOfImage: UIImageView!
    @IBOutlet weak var viewOfCell: UIView!
    @IBOutlet weak var viewSimple: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var speakerImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewOfCell.backgroundColor = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)
        viewOfCell.alpha = 0.2
        
        viewSimple.backgroundColor = .clear
        favoriteButton.backgroundColor = .clear
        
        titleLabel.font = UIFont(name: "Helvetica-bold", size: 20)
        titleLabel.textColor = .white
        
        speakerImageView.tintColor = .white
        
    }
    
    func logicFavoriteButton() {
        if favoriteButton.isSelected {
            favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
    }
    
    func setConfiguration(model: RealmModel) {
        soundOfImage.image = UIImage(named: model.image)
        soundOfImage.contentMode = .scaleAspectFill
        titleLabel.text = model.name
        favoriteButton.isSelected = model.isFavorite
    }
    
}
