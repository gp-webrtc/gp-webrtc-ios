//
// gp-webrtc/ios
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

public struct GPWBnWPlainButtonStyle: ButtonStyle {
    struct GPWButton: View {
        let configuration: ButtonStyle.Configuration

        @Environment(\.colorScheme) private var colorScheme
        @Environment(\.isEnabled) private var isEnabled: Bool

        var foregroundColor: Color {
            if let role = configuration.role {
                switch role {
                    case .destructive:
                        Color.white
                    case .cancel:
                        colorScheme == .dark ? Color.black : Color.white
                    default:
                        colorScheme == .dark ? Color.black : Color.white
                }
            } else { colorScheme == .dark ? Color.black : Color.white }
        }

        var backgroundColor: some View {
            if isEnabled {
                if let role = configuration.role {
                    switch role {
                        case .destructive:
                            Color.red
                        case .cancel:
                            colorScheme == .dark ? Color.white : Color.black
                        default:
                            colorScheme == .dark ? Color.white : Color.black
                    }
                } else { colorScheme == .dark ? Color.white : Color.black }
            } else { Color.gray }
        }

        func button(configuration: ButtonStyle.Configuration) -> some View {
            configuration.label
                .font(.body.weight(.semibold))
                .foregroundColor(foregroundColor)
                .padding(.horizontal, 32)
                .padding(.vertical)
                .background(backgroundColor)
                .cornerRadius(8)
        }

        var body: some View {
            button(configuration: configuration)
        }
    }

    public func makeBody(configuration: Configuration) -> some View {
        GPWButton(configuration: configuration)
    }
}
