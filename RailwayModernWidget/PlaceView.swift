//
//  PlaceView.swift
//  RailwayModernWidgetExtension
//
//  Created by Евгений Соболь on 8/8/20.
//  Copyright © 2020 Евгений Соболь. All rights reserved.
//

import WidgetKit
import SwiftUI

struct PlaceView: View {
    let carriage: String
    let seat: String

    var body: some View {
        HStack(spacing: 0) {
            PlaceComponentView(image: "carriage", value: carriage)
            PlaceComponentView(image: "seat", value: seat)
        }
    }
}

struct PlaceView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceView(carriage: "1", seat: "55")
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        PlaceView(carriage: "4", seat: "54").previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
