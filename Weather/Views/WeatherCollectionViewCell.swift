//
//  WeatherCell.swift
//  Weather
//
//  Created by Ilya Kozlov on 2020-07-14.
//  Copyright © 2020 ilushishe. All rights reserved.
//

import UIKit

class WeatherCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Properties
    var cityNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-UltraLight", size: 36)
        label.textColor = .black
        label.text = "-/-"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    var tempLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-UltraLight", size: 80)
        label.textColor = .black
        label.text = "-/-"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    var feelsTempLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-UltraLight", size: 18)
        label.textColor = .black
        label.text = "Feels like: -/-"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    var weatherIcon: UIImageView = {
        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFill
        icon.setContentHuggingPriority(.fittingSizeLevel, for: .vertical)
        return icon
    }()
    
    var weatherDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-UltraLight", size: 18)
        label.textColor = .black
        label.text = "-/-"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    
    //MARK: - Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViewsAndSetConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addViewsAndSetConstraints() {
    
        addSubview(cityNameLabel)
        cityNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 40).isActive = true
        cityNameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        cityNameLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        
        addSubview(tempLabel)
        tempLabel.topAnchor.constraint(equalTo: cityNameLabel.bottomAnchor, constant: 0).isActive = true
        tempLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        tempLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        
        addSubview(feelsTempLabel)
        feelsTempLabel.topAnchor.constraint(equalTo: tempLabel.bottomAnchor, constant: 0).isActive = true
        feelsTempLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        addSubview(weatherDescriptionLabel)
        weatherDescriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -80).isActive = true
        weatherDescriptionLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        addSubview(weatherIcon)
        weatherIcon.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        weatherIcon.topAnchor.constraint(equalTo: feelsTempLabel.bottomAnchor, constant: 10).isActive = true
        weatherIcon.bottomAnchor.constraint(equalTo: weatherDescriptionLabel.topAnchor, constant: -10).isActive = true

    }
}
