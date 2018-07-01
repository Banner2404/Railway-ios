//
//  NotificationSettingsCoreDataModel+CoreDataProperties.swift
//  
//
//  Created by Евгений Соболь on 7/1/18.
//
//

import Foundation
import CoreData


extension NotificationSettingsCoreDataModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NotificationSettingsCoreDataModel> {
        return NSFetchRequest<NotificationSettingsCoreDataModel>(entityName: "NotificationSettingsCoreDataModel")
    }

    @NSManaged public var isEnabled: Bool
    @NSManaged public var rawValue: Int64

}
