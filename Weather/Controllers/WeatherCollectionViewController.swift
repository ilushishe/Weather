//
//  WeatherCollectionViewController.swift
//  Weather
//
//  Created by Ilya Kozlov on 2020-07-14.
//  Copyright © 2020 ilushishe. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation



class WeatherCollectionViewController: UIViewController {
    
    //MARK: TEMP Property
    var isCollectionView = true
    
    //MARK: - Properties
    lazy var  coreDataStack = CoreDataStack(modelName: "Weathers")
    var fetchedResultsController: NSFetchedResultsController<Weather> = NSFetchedResultsController()
    
    var locationManager: CLLocationManager?
    var currentLocation: CLLocation?
    
    //MARK: - UIControls
    //как-то надо переделать
    var collectionVIew: UICollectionView! = nil
    //var pageControl: UIPageControl! = nil
    var toolbar: UIToolbar! = nil
    var tableView: UITableView! = nil
    
    //MARK: - Actions
    @objc func openCitiesList() {
        let listOfCitiesVC = ListOfCities()
        listOfCitiesVC.delegate = self
        navigationController?.showDetailViewController(listOfCitiesVC, sender: self)
    }
    
    @objc func switchView() {
        isCollectionView = !isCollectionView
        setVisibility()
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        updManualLocations()
    }
}

// MARK: Private
private extension WeatherCollectionViewController {
    func configureView() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        fetchedResultsController = weatherListFetchedResultsController()
        setupLocationManager()
        setupCollectionView()
        setupTableView()
        setupToolbar()
        setVisibility()
    }
    
    func setupCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: view.frame.width, height: view.frame.height)
        layout.scrollDirection = .horizontal
        collectionVIew = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionVIew.backgroundColor = .white
        collectionVIew.delegate = self
        collectionVIew.dataSource = self
        collectionVIew.register(WeatherCollectionViewCell.self, forCellWithReuseIdentifier: "WeatherCell")
        collectionVIew.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(collectionVIew)
    }
    
    func setupTableView() {
        tableView = UITableView(frame: view.frame)
//        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CityCell.self, forCellReuseIdentifier: "WeatherTableViewCell")
        tableView.setEditing(true, animated: true)
        self.view.addSubview(tableView)
    }
    
    func setVisibility() {
        if let tv = tableView, let cv = collectionVIew {
            if isCollectionView {
                cv.alpha = 1
                tv.alpha = 0
            } else {
                cv.alpha = 0
                tv.alpha = 1
            }
        }
        
    }
    
    func setupToolbar() {
        toolbar = UIToolbar()
        view.addSubview(toolbar)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.heightAnchor.constraint(equalToConstant: 40).isActive = true
        toolbar.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: #selector(openCitiesList))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let listItem = UIBarButtonItem(barButtonSystemItem: .organize, target: nil, action: #selector(switchView))
        toolbar.setItems([addButton,space, listItem], animated: true)
    }
}


// MARK: NSFetchedResultsController
private extension WeatherCollectionViewController {
    
    func weatherListFetchedResultsController() -> NSFetchedResultsController<Weather> {
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: allWeathersFetchRequest(),
                                                                  managedObjectContext: coreDataStack.managedContext,
                                                                  sectionNameKeyPath: #keyPath(Weather.isCurrentLocation),
                                                                  cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            fatalError("Error: \(error.localizedDescription)")
        }
        
        return fetchedResultsController
    }
    
    func allWeathersFetchRequest() -> NSFetchRequest<Weather> {
        
        let fetchRequest: NSFetchRequest<Weather> = Weather.fetchRequest()
        let currentLocationSort = NSSortDescriptor(key: #keyPath(Weather.isCurrentLocation), ascending: false)
        let indexSort = NSSortDescriptor(key: #keyPath(Weather.index), ascending: true)
        fetchRequest.sortDescriptors = [currentLocationSort, indexSort]
        
        return fetchRequest
    }
    
    func currentLocationFetchRequest() -> NSFetchRequest<Weather> {
        let fetchRequest: NSFetchRequest<Weather> = Weather.fetchRequest()
        let predicate = NSPredicate(format: "isCurrentLocation == YES")
        fetchRequest.predicate = predicate
        return fetchRequest
    }
    
    func manualAddedWeatherFetchRequest() -> NSFetchRequest<Weather> {
        let fetchRequest: NSFetchRequest<Weather> = Weather.fetchRequest()
        let predicate = NSPredicate(format: "isCurrentLocation == NO")
        fetchRequest.predicate = predicate
        return fetchRequest
    }
}

// MARK: NSFetchedResultsControllerDelegate
extension WeatherCollectionViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // TODO: переделать ? или норм?
        collectionVIew.reloadData()
        tableView.reloadData()
    }
}

// MARK: UICollectionViewDataSource
extension WeatherCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else { return 0 }
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherCell", for: indexPath) as! WeatherCollectionViewCell
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    
    
    private func configureCell(_ cell: WeatherCollectionViewCell, indexPath: IndexPath) {
        let weather = fetchedResultsController.object(at: indexPath)
        if let name = weather.cityName {
            cell.cityNameLabel.text = name
            cell.tempLabel.text = String(weather.temp_c)
        }
      
    }
}

//MARK: TableViewDataSource
extension WeatherCollectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       guard let sectionInfo = fetchedResultsController.sections?[section] else { return 0 }
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherTableViewCell", for: indexPath)
        cell.textLabel?.text = fetchedResultsController.object(at: indexPath).cityName
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        var obj1Index = fetchedResultsController.object(at: sourceIndexPath).index
        var obj2Index = fetchedResultsController.object(at: destinationIndexPath).index
        swap(&obj1Index,&obj2Index)
        coreDataStack.saveContext()
    }
}

//MARK: Location services
extension WeatherCollectionViewController: CLLocationManagerDelegate {
    func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("LocationManager did update location")
        updCurrentLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("location manager authorization status changed")
        
        switch status {
        case .authorizedAlways:
            print("user allow app to get location data when app is active or in background")
        case .authorizedWhenInUse:
            print("user allow app to get location data only when app is active")
        case .denied:
            print("user tap 'disallow' on the permission dialog, cant get location data")
        case .restricted:
            print("parental control setting disallow location data")
        case .notDetermined:
            print("the location permission dialog haven't shown before, user haven't tap allow/disallow")
        @unknown default:
            print("new status found")
        }
    }
}



//ПОКА РАБОТАЕТ, НО ПОТОМ НАДО ПЕРЕПИСАТЬ
//MARK: Network services
extension WeatherCollectionViewController {
    
    func updCurrentLocation() {
        if let currentWeather = try? coreDataStack.managedContext.fetch(currentLocationFetchRequest()), let coordinates = locationManager?.location?.coordinate {
            //Так нельзя
            var weather: Weather?
            if currentWeather.count > 0 {
                weather = currentWeather[0]
            } else {
                weather = Weather(context: coreDataStack.managedContext)
            }
            
            if let weather = weather {
                weather.lat = Double(coordinates.latitude)
                weather.lon = Double(coordinates.longitude)
                weather.isCurrentLocation = true
                updWeatherFromServer(query: "\(weather.lat),\(weather.lon)", weather: weather)
            }
        }
    }
    
    func updManualLocations() {
        if let weathers = fetchedResultsController.fetchedObjects {
            for weather in weathers {
                if !weather.isCurrentLocation {
                    updWeatherFromServer(query: weather.cityName ?? "", weather: weather)
                }
            }
        }
    }
    
    func updWeatherFromServer (query: String, weather: Weather) {
        let apikey = "9d30d2d76ab040a1872223526201905"
        let session = URLSession.shared
        //let queryItems = [URLQueryItem(name: "key", value: apikey), URLQueryItem(name: "q", value: query)]
        //let q = query.replacingOccurrences(of: ", ", with: ",")

        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.weatherapi.com"
        urlComponents.path = "/v1/current.json"
        urlComponents.queryItems = [
           URLQueryItem(name: "q", value: query),
           URLQueryItem(name: "key", value: apikey)
        ]
        guard let url = URL(string: urlComponents.url?.absoluteString ?? "") else { return }
      

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
                if self?.parseWeatherData(data: data, weather: weather) ?? false {
                    self?.coreDataStack.saveContext()
                }
            } else {
                print("Что-то пошло не так")
            }
        }
        task.resume()
        print("Данные загружены")
    }
    
    func parseWeatherData(data: Data, weather: Weather) -> Bool {
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                if let locationObject = json["location"] as? [String: Any], let currentObject = json["current"] as? [String: Any] {
                    if let cityName = locationObject["name"] as? String{
                        print("Распарсили name")
                        weather.cityName = cityName
                    }
                    
                    if let temp = currentObject["temp_c"] as? Float {
                        weather.temp_c = temp
                        print("распарсили temp")
                    }
                    return true
                }
            }
        } catch let error as NSError {
            print("Error parsing weather: \(error)")
        }
        return false
    }
}

extension WeatherCollectionViewController: ListOfCitiesDelegate {
    func didSelect(viewController: ListOfCities, item: City) {
        let weather = Weather(context: coreDataStack.managedContext)
        weather.cityName = item.cityName
        weather.isCurrentLocation = false
        weather.index = Int16(fetchedResultsController.fetchedObjects?.count ?? 0 + 1)
        
        coreDataStack.saveContext()
    }
}






