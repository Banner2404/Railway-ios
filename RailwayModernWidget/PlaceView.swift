//
//  PlaceView.swift
//  RailwayModernWidgetExtension
//
//  Created by Евгений Соболь on 8/8/20.
//  Copyright © 2020 Евгений Соболь. All rights reserved.
//

import WidgetKit
import SwiftUI

struct VPlaceView: View {
    let carriage: String
    let seat: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            PlaceComponentView(image: "carriage", value: carriage)
            PlaceComponentView(image: "seat", value: seat)
        }
    }
}

struct PlaceView_Previews: PreviewProvider {
    static var previews: some View {
        VPlaceView(carriage: "4", seat: "54").previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
