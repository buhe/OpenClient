//
//  mac.swift
//  gpt
//
//  Created by 顾艳华 on 2023/3/27.
//

import Foundation

//
//  macOS.swift
//  EmojiArt
//
//  Created by CS193p Instructor on 5/26/21.
//

import SwiftUI

// L16 macOS-specific code

// L16 shared code is written in terms of UIImage
// L16 NSImage is very similar
// L16 so typealias UIImage to NSImage on macOS only
// L16 in cases where they are not the same
// L16 further code is required (see below)
typealias UIImage = NSImage
//typealias UIViewRepresentableContext = NSViewRepresentableContext
typealias UIColor = NSColor

extension Image {
    // L16 on macOS, there is no init(uiImage:)
    // L16 instead, it is init(nsImage:)
    // L16 since we typealias above, we can provide that init
    init(uiImage: UIImage) {
        self.init(nsImage: uiImage)
    }
}

extension UIImage {
    // L16 convenience var to turn a UIImage into a Data
    // L16 on macOS, it converts it to tiff
    var imageData: Data? { tiffRepresentation }
}
