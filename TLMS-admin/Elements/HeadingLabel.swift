//
//  HeadingLabel.swift
//  TLMS-admin
//
//  Created by Abcom on 06/07/24.
//

import SwiftUI
import Foundation

// Custom TitleLabel struct
struct HeadingLabel: View {
    var text: String
    var fontSize: CGFloat = 24 // Default font size

    var body: some View {
        Text(text)
            .font(.system(size: fontSize, weight: .bold))
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading) // Optional: Full width alignment
            .background(Color.clear) // Optional: Background color
            .padding(.leading, 0)
    }
}
