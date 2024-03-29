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
    var currentPage = 0
    var isCelsius = true
    
    var attributedString: NSMutableAttributedString {
        let blackAttr = [NSAttributedString.Key.foregroundColor: UIColor.black]
        let greyAttr = [NSAttributedString.Key.foregroundColor: UIColor.gray]
        let attrString = NSMutableAttributedString()
        if isCelsius {
            attrString.append(NSAttributedString(string: "℃", attributes: blackAttr))
            attrString.append(NSAttributedString(string: " / "))
            attrString.append(NSAttributedString(string: "℉", attributes: greyAttr))
        } else {
            attrString.append(NSAttributedString(string: "℃", attributes: greyAttr))
            attrString.append(NSAttributedString(string: " / "))
            attrString.append(NSAttributedString(string: "℉", attributes: blackAttr))
        }
            
        return attrString
    }
    
    var locationManager: CLLocationManager?
    var currentLocation: CLLocation?
    
    //MARK: - UIControls
    //как-то надо переделать
    var collectionVIew: UICollectionView! = nil
    var pageControl: UIPageControl! = nil
    var toolbar: UIToolbar! = nil
    var tableView: UITableView! = nil
    let button = UIButton(type: .custom)

    
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
    
    @objc func switchDegree() {
        isCelsius = !isCelsius
        button.setAttributedTitle(attributedString, for: .normal)
        collectionVIew.reloadData()
        tableView.reloadData()
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
        setupPageControl()
        setVisibility()
    }
    
    func setupCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: view.frame.width, height: view.frame.height)
        layout.minimumLineSpacing = CGFloat(0)
        layout.scrollDirection = .horizontal
        collectionVIew = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionVIew.backgroundColor = .white
        collectionVIew.delegate = self
        collectionVIew.dataSource = self
        collectionVIew.register(WeatherCollectionViewCell.self, forCellWithReuseIdentifier: "WeatherCell")
        collectionVIew.translatesAutoresizingMaskIntoConstraints = false
        collectionVIew.isPagingEnabled = true
        self.view.addSubview(collectionVIew)
    }
    
    func setupTableView() {
        tableView = UITableView(frame: view.frame)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        tableView.register(WeatherTableViewCell.self, forCellReuseIdentifier: "WeatherTableViewCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 88
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.view.addSubview(tableView)
    }
    
    func setVisibility() {
        if let tv = tableView, let cv = collectionVIew, let pc = pageControl {
            if isCollectionView {
                cv.alpha = 1
                pc.alpha = 1
                tv.alpha = 0
            } else {
                cv.alpha = 0
                pc.alpha = 0
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
        toolbar.setBackgroundImage(UIImage(),
                                        forToolbarPosition: .any,
                                        barMetrics: .default)
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: #selector(openCitiesList))
        addButton.tintColor = .black
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let listItem = UIBarButtonItem(barButtonSystemItem: .organize, target: nil, action: #selector(switchView))
        listItem.tintColor = .black
        button.setAttributedTitle(attributedString, for: .normal)
        button.addTarget(self, action: #selector(switchDegree), for: .touchUpInside)
        let degreeSwitcher = UIBarButtonItem(customView: button)
        toolbar.setItems([addButton,space,degreeSwitcher,space, listItem], animated: true)
    }
    
    func setupPageControl() {
        pageControl = UIPageControl()
        view.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pageControl.bottomAnchor.constraint(equalTo: toolbar.topAnchor, constant: 8).isActive = true
        pageControl.pageIndicatorTintColor = .gray
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.numberOfPages = fetchedResultsController.fetchedObjects?.count ?? 0
        
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
        pageControl.numberOfPages = fetchedResultsController.fetchedObjects?.count ?? 0
    }
}

// MARK: UICollectionViewDataSource
extension WeatherCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else { return 0 }
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //TODO: - Fix !
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherCell", for: indexPath) as! WeatherCollectionViewCell
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    
    //TODO: - Сделать один метод?
    private func configureCell(_ cell: WeatherCollectionViewCell, indexPath: IndexPath) {
        let weather = fetchedResultsController.object(at: indexPath)
        if let name = weather.cityName {
            cell.cityNameLabel.text = name
            cell.weatherDescriptionLabel.text = weather.weatherDescription
            if let code = weather.descrtiptionCode {
                cell.weatherIcon.image = UIImage(named: code)
            }
            
            if isCelsius {
                cell.tempLabel.text = "\(weather.temp_c)℃"
                cell.feelsTempLabel.text = "feels like: \(weather.feels_c)"
            } else {
                cell.tempLabel.text = "\(weather.temp_f)℉"
                cell.feelsTempLabel.text = "feels like: \(weather.feels_f)"
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentPage = Int(scrollView.contentOffset.x / collectionVIew.frame.size.width)
        pageControl.currentPage = currentPage
        
    }
}

//MARK: TableViewDataSource and Delegate
extension WeatherCollectionViewController: UITableViewDataSource, UITableViewDelegate, UITableViewDragDelegate, UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       guard let sectionInfo = fetchedResultsController.sections?[section] else { return 0 }
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //TODO: - Fix !
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherTableViewCell", for: indexPath) as! WeatherTableViewCell
        let weather = fetchedResultsController.object(at: indexPath)
        cell.cityNameLabel.text = weather.cityName
        cell.weatherDescriptionLabel.text = weather.weatherDescription
        if isCelsius {
            cell.tempLabel.text = "\(weather.temp_c) ℃"
        } else {
            cell.tempLabel.text = "\(weather.temp_f) ℉"
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let obj1 = fetchedResultsController.object(at: sourceIndexPath)
        let obj2 = fetchedResultsController.object(at: destinationIndexPath)
        swap(&obj1.index,&obj2.index)
        coreDataStack.saveContext()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let object = fetchedResultsController.object(at: indexPath)
            coreDataStack.managedContext.delete(object)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if fetchedResultsController.object(at: indexPath).isCurrentLocation {
            return false
        } else {
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if fetchedResultsController.object(at: indexPath).isCurrentLocation {
            return false
        } else {
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        return [UIDragItem(itemProvider: NSItemProvider())]
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        
        if tableView.numberOfSections > 1 {
            if destinationIndexPath?.section == 0 {
                return UITableViewDropProposal(operation: .cancel, intent: .unspecified)
            }
        }
        
        if tableView.numberOfSections == 1 && fetchedResultsController.fetchedObjects?.count == 1 {
            return UITableViewDropProposal(operation: .cancel, intent: .unspecified)
        }
        
        if session.localDragSession != nil {
            print("dest \(destinationIndexPath)")
            return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UITableViewDropProposal(operation: .cancel, intent: .unspecified)
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        
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
                        weather.cityName = cityName
                    }
                    
                    if let tempC = currentObject["temp_c"] as? Double {
                        weather.temp_c = tempC
                    }
                    
                    if let tempF = currentObject["temp_f"] as? Double {
                        weather.temp_f = tempF
                    }
                    
                    if let feelslikeC = currentObject["feelslike_c"] as? Double {
                        weather.feels_c = feelslikeC
                    }
                    if let feelslikeF = currentObject["feelslike_f"] as? Double {
                        weather.feels_f = feelslikeF
                    }
                    
                    if let conditionObject = currentObject["condition"] as? [String: Any] {
                        if let description = conditionObject["text"] as? String {
                            weather.weatherDescription = description
                        }
                        if let icon = conditionObject["icon"] as? String {
                            if let iconUrl = URL(string: icon) {
                                if icon.contains("day") {
                                    weather.descrtiptionCode = "d" + iconUrl.lastPathComponent
                                } else if icon.contains("night") {
                                    weather.descrtiptionCode = "n" + iconUrl.lastPathComponent 
                                }
                            }
                        }
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
        print("index \(weather.index)")
        updWeatherFromServer(query: weather.cityName ?? "", weather: weather)
        coreDataStack.saveContext()
        if let index = fetchedResultsController.indexPath(forObject: weather) {
             collectionVIew.scrollToItem(at: index, at: .right, animated: true)
         }
    }
}






