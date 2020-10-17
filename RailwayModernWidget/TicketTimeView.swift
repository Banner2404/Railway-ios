//
//  TicketTimeView.swift
//  RailwayModernWidgetExtension
//
//  Created by Евгений Соболь on 10/17/20.
//  Copyright © 2020 Евгений Соболь. All rights reserved.
//

import SwiftUI
import WidgetKit

struct TicketTimeView: View {

    let departureDate: Date
    let arrivalDate: Date

    var body: some View {
        HStack(spacing: 5) {
            Text(departureDate, formatter: DateFormatters.shortTime)
                .font(.system(size: 30, weight: .medium))
                .foregroundColor(Color(.text))
            Text("-")
                .font(.system(size: 30, weight: .medium))
                .foregroundColor(Color(.text))
            Text(arrivalDate, formatter: DateFormatters.shortTime)
                .font(.system(size: 30, weight: .regular))
                .foregroundColor(Color(.text))
            Spacer()
        }
    }
}

struct TicketTimeView_Previews: PreviewProvider {
    static var previews: some View {
        TicketTimeView(
            departureDate: Date(),
            arrivalDate: Date().addingTimeInterval(60 * 16)
        )
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
