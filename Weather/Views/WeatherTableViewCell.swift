//
//  WeatherTableViewCell.swift
//  Weather
//
//  Created by Ilya Kozlov on 2020-07-20.
//  Copyright © 2020 ilushishe. All rights reserved.
//

import Foundation
import UIKit

class WeatherTableViewCell: UITableViewCell {
    
    //MARK: - Properties
    var cityNameLabel: UILabel = {
          let label = UILabel()
          label.font = UIFont(name: "HelveticaNeue-UltraLight", size: 24)
          label.textColor = .black
          label.text = "-/-"
          label.translatesAutoresizingMaskIntoConstraints = false
          label.numberOfLines = 0
          label.textAlignment = .left
          return label
      }()
    
    var tempLabel: UILabel = {
          let label = UILabel()
          label.font = UIFont(name: "HelveticaNeue-UltraLight", size: 38)
          label.textColor = .black
          label.text = "-/-"
          label.translatesAutoresizingMaskIntoConstraints = false
          label.textAlignment = .right
          return label
      }()
    
    var weatherDescriptionLabel: UILabel = {
         let label = UILabel()
         label.font = UIFont(name: "HelveticaNeue-UltraLight", size: 16)
         label.textColor = .black
         label.text = "-/-"
         label.translatesAutoresizingMaskIntoConstraints = false
         label.numberOfLines = 0
         label.textAlignment = .left
         return label
     }()
    
    //MARK: - Methods
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addViewsAndSetConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addViewsAndSetConstraints() {
        addSubview(cityNameLabel)
        addSubview(weatherDescriptionLabel)
        addSubview(tempLabel)

        cityNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 4).isActive = true
        cityNameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 4).isActive = true
        cityNameLabel.rightAnchor.constraint(equalTo: tempLabel.leftAnchor, constant: -4).isActive = true

        weatherDescriptionLabel.topAnchor.constraint(equalTo: cityNameLabel.bottomAnchor, constant: 0).isActive = true
        weatherDescriptionLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 4).isActive = true
        weatherDescriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true
        weatherDescriptionLabel.rightAnchor.constraint(equalTo: tempLabel.leftAnchor, constant: -4).isActive = true


        tempLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -4).isActive = true
        tempLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
    }
}
