//
//  Color.swift
//  Republik (iOS)
//
//  Created by Greg PFISTER on 02/03/2024.
//  Copyright © 2024 Greg PFISTER. All rights reserved.
//

import SwiftUI

extension Color {
    static var gpwPrimary: Color { Color(hex: "#5383ec" ) }
    static var gpwOnPrimary: Color { .white }
    
    static var gpwSecondary: Color { Color(hex: "#fd731e") }
    static var gpwOnSecondary: Color { .white }
    
    static var gpwPrimary50: Color { Color(hex: "#e5f2ff") }
    static var gpwPrimary100: Color { Color(hex: "#c1ddff") }
    static var gpwPrimary200: Color { Color(hex: "#9bc8ff") }
    static var gpwPrimary300: Color { Color(hex: "#77b3fe") }
    static var gpwPrimary400: Color { Color(hex: "#61a2fe") }
    static var gpwPrimary500: Color { Color(hex: "#5592fb") }
    static var gpwPrimary600: Color { Color(hex: "#5383ec") }
    static var gpwPrimary700: Color { Color(hex: "#4f71d8") }
    static var gpwPrimary800: Color { Color(hex: "#4a5fc5") }
    static var gpwPrimary900: Color { Color(hex: "#4340a4") }
    
    static var gpwSecondary50: Color { Color(hex: "#fff8e2") }
    static var gpwSecondary100: Color { Color(hex: "#ffecb6") }
    static var gpwSecondary200: Color { Color(hex: "#ffe188") }
    static var gpwSecondary300: Color { Color(hex: "#ffd659") }
    static var gpwSecondary400: Color { Color(hex: "#ffcb39") }
    static var gpwSecondary500: Color { Color(hex: "#ffc229") }
    static var gpwSecondary600: Color { Color(hex: "#ffb525") }
    static var gpwSecondary700: Color { Color(hex: "#ffa222") }
    static var gpwSecondary800: Color { Color(hex: "#ff9221") }
    static var gpwSecondary900: Color { Color(hex: "#fd731e") }
    
    static var gpwGray50: Color { Color(hex: "#ECEFF1") }
    static var gpwGray100: Color { Color(hex: "#CFD8DC") }
    static var gpwGray200: Color { Color(hex: "#B0BEC5") }
    static var gpwGray300: Color { Color(hex: "#90A4AE") }
    static var gpwGray400: Color { Color(hex: "#78909C") }
    static var gpwGray500: Color { Color(hex: "#607D8B") }
    static var gpwGray600: Color { Color(hex: "#546E7A") }
    static var gpwGray700: Color { Color(hex: "#455A64") }
    static var gpwGray800: Color { Color(hex: "#37474F") }
    static var gpwGray900: Color { Color(hex: "#263238") }
    
//    var gpwBackground: Color { Color("BackgroundColor") }
//    var gpwOnBackground: Color { Color("OnBackgroundColor") }
    
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
