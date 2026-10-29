//
//  CaptionStyleTests.swift
//  VersaPlayer
//
//  Created by Jose Quintero on 10/28/26.
//

import CoreMedia
import Foundation
import Testing
@testable import VersaPlayerCore

struct CaptionStyleTests {
    @Test func emptyStyleProducesNoRules() {
        #expect(CaptionStyle().markupAttributes.isEmpty)
        #expect(CaptionStyle().textStyleRules.isEmpty)
    }

    @Test func mapsPropertiesToMarkupAttributes() throws {
        var style = CaptionStyle()
        style.foregroundColor = .init(red: 1, green: 0.5, blue: 0, alpha: 0.25)
        style.relativeFontSize = 120
        style.bold = true
        style.edgeStyle = .dropShadow
        style.alignment = .left
        style.genericFont = .monospace

        let attributes = style.markupAttributes
        let color = try #require(attributes[kCMTextMarkupAttribute_ForegroundColorARGB as String] as? [NSNumber])
        #expect(color.map(\.doubleValue) == [0.25, 1, 0.5, 0])
        #expect((attributes[kCMTextMarkupAttribute_RelativeFontSize as String] as? NSNumber)?.doubleValue == 120)
        #expect((attributes[kCMTextMarkupAttribute_BoldStyle as String] as? NSNumber)?.boolValue == true)
        #expect(attributes[kCMTextMarkupAttribute_CharacterEdgeStyle as String] as? String == kCMTextMarkupCharacterEdgeStyle_DropShadow as String)
        #expect(attributes[kCMTextMarkupAttribute_Alignment as String] as? String == kCMTextMarkupAlignmentType_Left as String)
        #expect(attributes[kCMTextMarkupAttribute_GenericFontFamilyName as String] as? String == kCMTextMarkupGenericFontName_Monospace as String)
        #expect(attributes.count == 6)
        #expect(style.textStyleRules.count == 1)
    }
}
