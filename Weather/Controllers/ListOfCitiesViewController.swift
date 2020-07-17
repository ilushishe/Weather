//
//  ListOfCitiesViewController.swift
//  Weather
//
//  Created by Ilya Kozlov on 2020-07-16.
//  Copyright © 2020 ilushishe. All rights reserved.
//

import Foundation
import UIKit

class ListOfCities: UIViewController {
    
    //MARK: - Properties
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.frame)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CityCell.self, forCellReuseIdentifier: "CityCell")
        return tableView
    }()
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
    }
}

//MARK: UITableViewDataSource
extension ListOfCities: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // as! обойти бы как-нибудь
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath) as! CityCell
        cell.cityNameLabel.text = "City Name"
        cell.cityRegionLabel.text = "City Region"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
}

//MARK: UITableViewDelegate

extension ListOfCities: UITableViewDelegate {
    
}
