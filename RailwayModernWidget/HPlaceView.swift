//
//  HPlaceView.swift
//  RailwayModernWidgetExtension
//
//  Created by Евгений Соболь on 10/17/20.
//  Copyright © 2020 Евгений Соболь. All rights reserved.
//

import WidgetKit
import SwiftUI

struct HPlaceView: View {
    let carriage: String
    let seat: String

    var body: some View {
        HStack() {
            Spacer()
            PlaceComponentView(image: "carriage", value: carriage)
            Spacer()
            PlaceComponentView(image: "seat", value: seat)
            Spacer()
        }
    }
}

struct HPlaceView_Previews: PreviewProvider {
    static var previews: some View {
        HPlaceView(carriage: "4", seat: "54").previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
