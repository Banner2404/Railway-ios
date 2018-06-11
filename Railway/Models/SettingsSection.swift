//
//  SettingsSection.swift
//  Railway
//
//  Created by Евгений Соболь on 6/11/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import Foundation
import RxDataSources

struct SettingsSection {
    var items: [SettingsSection.CellType]
    
    init(items: [SettingsSection.CellType]) {
        self.items = items
    }
    
    enum CellType {
        case gmailConnect
        case gmailDisconnect
        
        var cellIdentifier: String {
            switch self {
            case .gmailConnect:
                return "GmailConnectCell"
            case .gmailDisconnect:
                return "GmailDisconnectCell"
            }
        }
    }
}

extension SettingsSection: SectionModelType {
    
    typealias Item = CellType
    
    init(original: SettingsSection, items: [SettingsSection.CellType]) {
        self = original
        self.items = items
    }
    
    
}
