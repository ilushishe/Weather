//
//  Weather+CoreDataProperties.swift
//  Weather
//
//  Created by Ilya Kozlov on 2020-07-14.
//  Copyright © 2020 ilushishe. All rights reserved.
//
//

import Foundation
import CoreData


extension Weather {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Weather> {
        return NSFetchRequest<Weather>(entityName: "Weather")
    }

    @NSManaged public var index: Int16
    @NSManaged public var isCurrentLocation: Bool
    @NSManaged public var cityName: String?
    @NSManaged public var weatherDescription: String?
    @NSManaged public var descrtiptionCode: String?
    @NSManaged public var temp_c: Float
    @NSManaged public var temp_f: Float
    @NSManaged public var feels_c: Float
    @NSManaged public var feels_f: Float
    @NSManaged public var last_updated: Date?
    @NSManaged public var lat: Double
    @NSManaged public var lon: Double

}
