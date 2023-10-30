//
//  CustomTableViewCell.swift
//  firstApp
//
//  Created by Paul James on 31.10.2023.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var soundImageView: UIImageView!
    @IBOutlet weak var viewOfCell: UIView!
    @IBOutlet weak var viewSimple: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var speakerImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // тут я настраивал цвет для вью ячейки
        viewOfCell.backgroundColor = .clear
//        viewOfCell.alpha = 0.2
        
        viewSimple.backgroundColor = .clear
        
        titleLabel.font = UIFont(name: "Helvetica-bold", size: 20)
        titleLabel.textColor = .white
        
        favoriteButton.backgroundColor = .clear
        
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
        soundImageView.image = UIImage(named: model.image)
        soundImageView.contentMode = .scaleAspectFill
        titleLabel.text = model.name
        favoriteButton.isSelected = model.isFavorite
    }
    
    func setSpectialConfig(text: String) {
        titleLabel.text = text
        titleLabel.textAlignment = .center
        titleLabel.textColor = .gray
        favoriteButton.isHidden = true
        speakerImageView.isHidden = true
    }
    
}
