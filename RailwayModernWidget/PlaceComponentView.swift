//
//  PlaceComponentView.swift
//  RailwayModernWidgetExtension
//
//  Created by Евгений Соболь on 8/8/20.
//  Copyright © 2020 Евгений Соболь. All rights reserved.
//

import WidgetKit
import SwiftUI

struct PlaceComponentView: View {

    let image: String
    let value: String

    var body: some View {
        HStack {
            Image(image)
                .foregroundColor(Color(.navigationBarTint))
            Text(value)
                .font(Font.system(size: 30, weight: .medium))
                .foregroundColor(Color(.text))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .layoutPriority(1)
        }
    }
}

struct PlaceComponentView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceComponentView(image: "seat", value: "1")
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
