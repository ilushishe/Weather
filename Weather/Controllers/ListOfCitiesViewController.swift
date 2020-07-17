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
    
    var cities = [City]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: - Properties
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.frame)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CityCell.self, forCellReuseIdentifier: "CityCell")
        tableView.contentInset = UIEdgeInsets(top: 66, left: 0, bottom: 66, right: 0)
        return tableView
    }()
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = UISearchBar.Style.prominent
        searchBar.placeholder = " Search..."
        searchBar.sizeToFit()
        searchBar.isTranslucent = false
        searchBar.delegate = self
        return searchBar
    }()
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)
        view.addSubview(tableView)
        view.addSubview(searchBar)
    }
}

//MARK: UITableViewDataSource
extension ListOfCities: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // as! обойти бы как-нибудь
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath) as! CityCell
        cell.cityNameLabel.text = cities[indexPath.row].cityName
        cell.cityRegionLabel.text = cities[indexPath.row].cityRegion
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66    }
}

//MARK: UITableViewDelegate

extension ListOfCities: UITableViewDelegate {
    
}

//MARK: SearchBarDelegate
extension ListOfCities: UISearchBarDelegate {
   
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("text did change")
        //add delay
        if searchBar.text == "" {
            cities.removeAll()
        }
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(finishTyping), object: nil)
        self.perform(#selector(finishTyping), with: nil, afterDelay: 0.5)
    }
    
    @objc func finishTyping() {
        fetchCity(query: searchBar.text!)

    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {

    }
}

//MARK: Network services
extension ListOfCities {
    func fetchCity (query: String) {
        let apikey = "9d30d2d76ab040a1872223526201905"
        let session = URLSession.shared
        guard let url = URL(string: "https://api.weatherapi.com/v1/search.json?key=\(apikey)&q=\(query)") else { return }
        let task = session.dataTask(with: url) { [weak self]
            data, response, error in
            if error != nil {
                print("что-то пошло не так алет")
                return
            }
            
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                print("Server error! алерт")
                return
            }
            
            if let data = data {
                self?.parse(data: data)
            } else {
                print("Что-то пошло не так")
            }
        }
        task.resume()
        print("Данные загружены")
    }
    
    func parse(data: Data) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                cities.removeAll()
                print(json)
                for object in json {
                    if let cityName = object["name"] as? String, let country = object["country"] as? String {
                        cities.append(City(cityName: cityName, cityRegion: country))
                        print(cities)
                    }
                }
            }
        } catch let error as NSError {
            print("Error parsing weather: \(error)")
        }
    }
}


