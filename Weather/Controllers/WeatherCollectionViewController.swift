//
//  WeatherCollectionViewController.swift
//  Weather
//
//  Created by Ilya Kozlov on 2020-07-14.
//  Copyright © 2020 ilushishe. All rights reserved.
//

import UIKit
import CoreData

class WeatherCollectionViewController: UIViewController {
    
    //MARK: - Properties
    var coreDataStack: CoreDataStack!
    var fetchedResultsController: NSFetchedResultsController<Weather> = NSFetchedResultsController()
    
    //MARK: - UIControls
    
    //MARK: - Actions


    

    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: Private
private extension WeatherCollectionViewController {
    func configureView() {
        fetchedResultsController = weatherListFetchedResultsController()
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
}

// MARK: NSFetchedResultsControllerDelegate
extension WeatherCollectionViewController: NSFetchedResultsControllerDelegate {
    
}

// MARK: UICollectionViewDataSource
extension WeatherCollectionViewController: UICollectionViewDelegate {
    
}


