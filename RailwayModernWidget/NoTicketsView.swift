//
//  NoTicketsView.swift
//  RailwayModernWidgetExtension
//
//  Created by Евгений Соболь on 10/17/20.
//  Copyright © 2020 Евгений Соболь. All rights reserved.
//

import SwiftUI
import WidgetKit

struct NoTicketsView: View {
    var body: some View {
        VStack {
            HStack {
                Text("No tickets")
                    .font(.system(size: 18))
                    .foregroundColor(Color(.text))
                Spacer()
            }
            Spacer()
        }
    }
}

struct NoTicketsView_Previews: PreviewProvider {
    static var previews: some View {
        NoTicketsView()
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
