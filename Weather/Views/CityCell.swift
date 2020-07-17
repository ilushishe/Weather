//
//  CityCell.swift
//  Weather
//
//  Created by Ilya Kozlov on 2020-07-16.
//  Copyright © 2020 ilushishe. All rights reserved.
//

import Foundation
import UIKit

class CityCell: UITableViewCell {
    //MARK: - Properties
    
    var cityNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-UltraLight", size: 20)
        label.textColor = .black
        label.text = "-/-"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    var cityRegionLabel: UILabel = {
           let label = UILabel()
           label.font = UIFont(name: "HelveticaNeue-UltraLight", size: 14)
           label.textColor = .black
           label.text = "-/-"
           label.translatesAutoresizingMaskIntoConstraints = false
           label.numberOfLines = 0
           label.textAlignment = .left
           return label
       }()
    
    //MARK:_ Methods
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addViewsAndSetConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addViewsAndSetConstraints() {
        
        addSubview(cityNameLabel)
        cityNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        cityNameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        
        addSubview(cityRegionLabel)
        cityRegionLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        cityRegionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
    }
}
