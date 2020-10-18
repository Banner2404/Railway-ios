//
//  PrimaryText.swift
//  RailwayModernWidgetExtension
//
//  Created by Евгений Соболь on 10/17/20.
//  Copyright © 2020 Евгений Соболь. All rights reserved.
//

import SwiftUI

struct LeftAlignedText: ViewModifier {
    
    func body(content: Content) -> some View {
        HStack {
            content
            Spacer()
        }
    }
}

struct PrimaryText: ViewModifier {

    func body(content: Content) -> some View {
        content
            .font(.system(size: 20))
            .foregroundColor(Color(.text))
    }
}


extension View {

    func leftAligned() -> some View {
        self.modifier(LeftAlignedText())
    }

    func primaryText() -> some View {
        self.modifier(PrimaryText())
    }

    @ViewBuilder
    func `if`<Transform: View>(
        _ condition: Bool,
        transform: (Self) -> Transform
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
