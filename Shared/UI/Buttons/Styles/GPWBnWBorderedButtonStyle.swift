//
// gp-webrtc-ios
// Copyright (c) 2024, Greg PFISTER. MIT License
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the “Software”), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import SwiftUI

public struct GPWBnWBorderedButtonStyle: ButtonStyle {
    struct GPWButton: View {
        let configuration: ButtonStyle.Configuration

        @ScaledMetric(relativeTo: .body) private var scaledButtonHPadding = 32
        @ScaledMetric(relativeTo: .body) private var scaledButtonVPadding = 16

        @Environment(\.colorScheme) private var colorScheme
        @Environment(\.isEnabled) private var isEnabled

        var foregroundColor: Color {
            if isEnabled {
                if let role = configuration.role {
                    switch role {
                        case ButtonRole.destructive:
                            Color.red
                        case ButtonRole.cancel:
                            colorScheme == .dark ? Color.gpwOnPrimary : Color.gpwPrimary
                        default:
                            colorScheme == .dark ? Color.gpwOnPrimary : Color.gpwPrimary
                    }
                } else { colorScheme == .dark ? Color.gpwOnPrimary : Color.gpwPrimary }
            } else { Color.gray }
        }

        var borderColor: Color {
            if isEnabled {
                if let role = configuration.role {
                    switch role {
                        case ButtonRole.destructive:
                            Color.red
                        case ButtonRole.cancel:
                            colorScheme == .dark ? Color.gpwOnPrimary : Color.gpwPrimary
                        default:
                            colorScheme == .dark ? Color.gpwOnPrimary : Color.gpwPrimary
                    }
                } else { colorScheme == .dark ? Color.gpwOnPrimary : Color.gpwPrimary }
            } else { Color.gray }
        }

        func button(configuration: ButtonStyle.Configuration) -> some View {
            configuration.label
                .font(.gpwBody.weight(.semibold))
                .foregroundColor(foregroundColor)
                .padding(.horizontal, scaledButtonHPadding)
                .padding(.vertical, scaledButtonVPadding)
                .background(Color.clear)
                .cornerRadius(8)
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(borderColor, lineWidth: 1)
                }
        }

        var body: some View {
            button(configuration: configuration)
        }
    }

    public func makeBody(configuration: Configuration) -> some View {
        GPWButton(configuration: configuration)
    }
}
