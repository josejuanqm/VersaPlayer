//
//  CaptionStyle.swift
//  VersaPlayer
//
//  Created by Jose Quintero on 10/28/26.
//

import AVFoundation
import CoreMedia

/// Caption appearance. `nil` leaves the system setting.
public struct CaptionStyle: Sendable, Equatable {
    public struct Color: Sendable, Equatable {
        public var red, green, blue, alpha: Double
        public init(red: Double, green: Double, blue: Double, alpha: Double = 1) {
            self.red = red; self.green = green; self.blue = blue; self.alpha = alpha
        }
        public static let white = Color(red: 1, green: 1, blue: 1)
        public static let black = Color(red: 0, green: 0, blue: 0)
        public static let clear = Color(red: 0, green: 0, blue: 0, alpha: 0)

        var argb: [NSNumber] { [alpha, red, green, blue].map { NSNumber(value: $0) } }
    }

    public enum Alignment: Sendable { case start, middle, end, left, right }
    public enum EdgeStyle: Sendable { case none, raised, depressed, uniform, dropShadow }
    public enum GenericFont: Sendable { case serif, sansSerif, monospace, casual, cursive, smallCapital }

    public var foregroundColor: Color?
    public var backgroundColor: Color?
    public var characterBackgroundColor: Color?
    public var fontFamily: String?
    public var genericFont: GenericFont?
    /// Percent of the default size.
    public var relativeFontSize: Double?
    /// Percent of video height.
    public var baseFontSizePercentOfVideoHeight: Double?
    public var bold: Bool?
    public var italic: Bool?
    public var underline: Bool?
    public var edgeStyle: EdgeStyle?
    public var alignment: Alignment?
    /// Line position, percent of the frame.
    public var linePositionPercent: Double?
    /// Cue box width, percent of the frame.
    public var widthPercent: Double?

    public init() {}

    public var markupAttributes: [String: Any] {
        var attributes: [CFString: Any] = [:]
        attributes[kCMTextMarkupAttribute_ForegroundColorARGB] = foregroundColor?.argb
        attributes[kCMTextMarkupAttribute_BackgroundColorARGB] = backgroundColor?.argb
        attributes[kCMTextMarkupAttribute_CharacterBackgroundColorARGB] = characterBackgroundColor?.argb
        attributes[kCMTextMarkupAttribute_FontFamilyName] = fontFamily
        attributes[kCMTextMarkupAttribute_GenericFontFamilyName] = genericFont.map(Self.cfString)
        attributes[kCMTextMarkupAttribute_RelativeFontSize] = relativeFontSize.map { NSNumber(value: $0) }
        attributes[kCMTextMarkupAttribute_BaseFontSizePercentageRelativeToVideoHeight] = baseFontSizePercentOfVideoHeight.map { NSNumber(value: $0) }
        attributes[kCMTextMarkupAttribute_BoldStyle] = bold.map { NSNumber(value: $0) }
        attributes[kCMTextMarkupAttribute_ItalicStyle] = italic.map { NSNumber(value: $0) }
        attributes[kCMTextMarkupAttribute_UnderlineStyle] = underline.map { NSNumber(value: $0) }
        attributes[kCMTextMarkupAttribute_CharacterEdgeStyle] = edgeStyle.map(Self.cfString)
        attributes[kCMTextMarkupAttribute_Alignment] = alignment.map(Self.cfString)
        attributes[kCMTextMarkupAttribute_OrthogonalLinePositionPercentageRelativeToWritingDirection] = linePositionPercent.map { NSNumber(value: $0) }
        attributes[kCMTextMarkupAttribute_WritingDirectionSizePercentage] = widthPercent.map { NSNumber(value: $0) }
        return Dictionary(uniqueKeysWithValues: attributes.map { ($0.key as String, $0.value) })
    }

    var textStyleRules: [AVTextStyleRule] {
        let attributes = markupAttributes
        guard !attributes.isEmpty, let rule = AVTextStyleRule(textMarkupAttributes: attributes) else { return [] }
        return [rule]
    }

    private static func cfString(_ value: GenericFont) -> CFString {
        switch value {
        case .serif: kCMTextMarkupGenericFontName_Serif
        case .sansSerif: kCMTextMarkupGenericFontName_SansSerif
        case .monospace: kCMTextMarkupGenericFontName_Monospace
        case .casual: kCMTextMarkupGenericFontName_Casual
        case .cursive: kCMTextMarkupGenericFontName_Cursive
        case .smallCapital: kCMTextMarkupGenericFontName_SmallCapital
        }
    }

    private static func cfString(_ value: EdgeStyle) -> CFString {
        switch value {
        case .none: kCMTextMarkupCharacterEdgeStyle_None
        case .raised: kCMTextMarkupCharacterEdgeStyle_Raised
        case .depressed: kCMTextMarkupCharacterEdgeStyle_Depressed
        case .uniform: kCMTextMarkupCharacterEdgeStyle_Uniform
        case .dropShadow: kCMTextMarkupCharacterEdgeStyle_DropShadow
        }
    }

    private static func cfString(_ value: Alignment) -> CFString {
        switch value {
        case .start: kCMTextMarkupAlignmentType_Start
        case .middle: kCMTextMarkupAlignmentType_Middle
        case .end: kCMTextMarkupAlignmentType_End
        case .left: kCMTextMarkupAlignmentType_Left
        case .right: kCMTextMarkupAlignmentType_Right
        }
    }
}
