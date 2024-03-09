//
//  Color.swift
//  Republik (iOS)
//
//  Created by Greg PFISTER on 02/03/2024.
//  Copyright © 2024 Greg PFISTER. All rights reserved.
//

import SwiftUI

extension Color {
    static var gpwPrimary: Color { Color(hex: "#f63943" ) }
    static var gpwOnPrimary: Color { Color(hex: "#f4eff0") }
    
//    static var gpwSecondary: Color { Color(hex: "#f4eff0") }
//    static var gpwOnSecondary: Color { Color(hex: "#060203") }
    
    static var gpwPrimary50: Color { Color(hex: "#ffe9ed") }
    static var gpwPrimary100: Color { Color(hex: "#ffc8cf") }
    static var gpwPrimary200: Color { Color(hex: "#f59193") }
    static var gpwPrimary300: Color { Color(hex: "#ec6469") }
    static var gpwPrimary400: Color { Color(hex: "#f63942") } // Primary
    static var gpwPrimary500: Color { Color(hex: "#fb1523") }
    static var gpwPrimary600: Color { Color(hex: "#ec0024") }
    static var gpwPrimary700: Color { Color(hex: "#da001f") }
    static var gpwPrimary800: Color { Color(hex: "#ce0017") }
    static var gpwPrimary900: Color { Color(hex: "#be0008") }
    
//    static var gpwSecondary50: Color { Color(hex: "#fff8e2") }
//    static var gpwSecondary100: Color { Color(hex: "#ffecb6") }
//    static var gpwSecondary200: Color { Color(hex: "#ffe188") }
//    static var gpwSecondary300: Color { Color(hex: "#ffd659") }
//    static var gpwSecondary400: Color { Color(hex: "#ffcb39") }
//    static var gpwSecondary500: Color { Color(hex: "#ffc229") }
//    static var gpwSecondary600: Color { Color(hex: "#ffb525") }
//    static var gpwSecondary700: Color { Color(hex: "#ffa222") }
//    static var gpwSecondary800: Color { Color(hex: "#ff9221") }
//    static var gpwSecondary900: Color { Color(hex: "#fd731e") }
    
    static var gpwGray50: Color { Color(hex: "#fbf6f8") }
    static var gpwGray100: Color { Color(hex: "#f3eeef") }
    static var gpwGray200: Color { Color(hex: "#e7e2e4") }
    static var gpwGray300: Color { Color(hex: "#d6d1d2") }
    static var gpwGray400: Color { Color(hex: "#b1acad") }
    static var gpwGray500: Color { Color(hex: "#908c8d") }
    static var gpwGray600: Color { Color(hex: "#686465") }
    static var gpwGray700: Color { Color(hex: "#555152") }
    static var gpwGray800: Color { Color(hex: "#373334") }
    static var gpwGray900: Color { Color(hex: "#171314") }
    
    var gpwBackground: Color { Color("BackgroundColor") }
    var gpwOnBackground: Color { Color("OnBackgroundColor") }
    
    static var gpwCardBackground: Color { Color("CardBackgroundColor") }
    static var gpwOnCardBackground: Color { Color("OnCardBackgroundColor") }
    
    init(colorSpace: Color.RGBColorSpace = .sRGB, hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            colorSpace,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
