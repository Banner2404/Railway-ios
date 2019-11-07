//
//  UIColor.swift
//  Railway
//
//  Created by Евгений Соболь on 6/12/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import UIKit

extension UIColor {

    static func dynamicColor(light: UIColor, dark: UIColor) -> UIColor {
        let color: UIColor
        #if os(iOS)
        if #available(iOS 13.0, *) {
            color = UIColor(dynamicProvider: { traits in
                switch traits.userInterfaceStyle {
                case .dark:
                    return dark
                default:
                    return light
                }
            })
        } else {
            color = light
        }
        #else
        color = light
        #endif
        return color
    }

    static var tableBackgroundLight: UIColor {
        return UIColor(red: 39.0 / 255, green: 106.0 / 255, blue: 115.0 / 255, alpha: 1.0)
    }
    
    static var tableBackground: UIColor {
        return .dynamicColor(
            light: tableBackgroundLight,
            dark: .black)
    }

    static var navigationBarBackground: UIColor {
        return .dynamicColor(
            light: .white,
            dark: .tableBackgroundLight)
    }

    static var navigationBarTint: UIColor {
        return .dynamicColor(
            light: .tableBackgroundLight,
            dark: .white)
    }

    static var cardBackgroundLight: UIColor {
        return UIColor(red: 242.0 / 255, green: 242.0 / 255, blue: 240.0 / 255, alpha: 1.0)
    }

    static var cardBackground: UIColor {
        return .dynamicColor(
            light: .cardBackgroundLight,
            dark: .tableBackgroundLight)
    }

    static var complicationAccent: UIColor {
        return UIColor(red: 48.0 / 255, green: 132.0 / 255, blue: 144.0 / 255, alpha: 1.0)
    }

    static var textLight: UIColor {
        return UIColor(red: 4.0 / 255, green: 59.0 / 255, blue: 64.0 / 255, alpha: 1.0)
    }

    static var text: UIColor {
        return .dynamicColor(
            light: .textLight,
            dark: .white)
    }

    static var switchTint: UIColor {
        return .dynamicColor(
            light: .tableBackground,
            dark: .black)
    }

    static var timeline: UIColor {
        return .dynamicColor(
            light: .tableBackground,
            dark: .white)
    }
    
}
