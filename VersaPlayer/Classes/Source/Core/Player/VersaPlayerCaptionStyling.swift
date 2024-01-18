//
//  VersaPlayerCaptionStyling.swift
//  VersaPlayer
//
//  Created by Jose Quintero on 10/31/18.
//

import Foundation
import AVFoundation

public class VersaPlayerCaptionStyling {
    
    weak var player: VersaPlayer!
    var rules: [AVTextStyleRule] = []
    
    init(with player: VersaPlayer) {
        self.player = player
    }

    deinit {
      
    }

    /// Set attribute
    public func set(attribute: CFString, value: Any, selector: String? = nil) {
        guard let style = AVTextStyleRule.init(textMarkupAttributes: [attribute as String : value], textSelector: selector) else {
            return
        }
        rules.append(style)
        player.currentItem?.textStyleRules = rules
    }
    
    /// Remove all previously set attribute
    public func clearAttributes() {
        rules = []
        player.currentItem?.textStyleRules = rules
    }
    
    /// Remove any previously set attribute
    public func remove(attribute: CFString) {
        player.currentItem?.textStyleRules?.removeAll(where: { (rule) -> Bool in
            return rule.textMarkupAttributes.contains(where: { (key, value) -> Bool in
                return key == attribute as String
            })
        })
    }
    
    /// Value must be one of the CFString constants in Alignment Type Constants indicating the alignment in the writing direction of the first line of text of the cue. The writing direction is indicated by the value (or absence) of the kCMTextMarkupAttribute_VerticalLayout attribute. The default value of this attribute is kCMTextMarkupAlignmentType_Middle.
    /// If used, this attribute must be applied to the entire attributed string.
    public func set(alignment value: Any) {
        let attribute: CFString = kCMTextMarkupAttribute_Alignment
        set(attribute: attribute, value: value)
    }
    
    /// Value must be a CFBoolean. The default is kCFBooleanFalse. If this attribute is kCFBooleanTrue, the text will be drawn with a bold style. Other styles such as italic may or may not be used as well.
    public func set(boldStyle value: Any) {
        let attribute: CFString = kCMTextMarkupAttribute_BoldStyle
        set(attribute: attribute, value: value)
    }
    
    /// Value must be a CFBoolean. The default is kCFBooleanFalse. If this attribute is kCFBooleanTrue, the text will be rendered with an italic style. Other styles such as bold may or may not be used as well.
    public func set(italicStyle value: Any) {
        let attribute: CFString = kCMTextMarkupAttribute_ItalicStyle
        set(attribute: attribute, value: value)
    }
    
    /// Value must be a CFString holding the family name of an installed font (for example, "Helvetica") that is used to render and/or measure text.
    /// When vended by legible output, an attributed string will have at most one of kCMTextMarkupAttribute_FontFamilyName or kCMTextMarkupAttribute_GenericFontFamilyName associated with each character.
    public func set(fontFamilyName value: Any) {
        let attribute: CFString = kCMTextMarkupAttribute_FontFamilyName
        set(attribute: attribute, value: value)
    }
    
    /// Value must be a CFBoolean. The default is kCFBooleanFalse. If this attribute is kCFBooleanTrue, the text will be rendered with an underline. Other styles such as bold may or may not be used as well.
    public func set(underlineStyle value: Any) {
        let attribute: CFString = kCMTextMarkupAttribute_UnderlineStyle
        set(attribute: attribute, value: value)
    }
    
    /// Value must be one of the CFString constants in Vertical Layout Constants indicating the progression direction for new vertical lines of text. If this attribute is present, it indicates the writing direction is vertical. The attribute value indicates whether new vertical text lines are added from left to right or from right to left. If this attribute is missing, the writing direction is horizontal.
    /// If used, this attribute must be applied to the entire attributed string.
    public func set(verticalLayout value: Any) {
        let attribute: CFString = kCMTextMarkupAttribute_VerticalLayout
        set(attribute: attribute, value: value)
    }
    
    /// Value must be a non-negative CFNumber. This is a number holding a percentage of the size of the calculated default font size. A value of 120 indicates 20% larger than the default font size. A value of 80 indicates 80% of the default font size. The default value of 100 indicates no size difference.
    public func set(relativeFontSize value: Any) {
        let attribute: CFString = kCMTextMarkupAttribute_RelativeFontSize
        set(attribute: attribute, value: value)
    }
    
    /// Value must be one of the CFString constants in Character Edge Style Constants that control the shape of the edges of drawn characters. The default value is kCMTextMarkupCharacterEdgeStyle_None.
    public func set(characterEdgeStyle value: Any) {
        let attribute: CFString = kCMTextMarkupAttribute_CharacterEdgeStyle
        set(attribute: attribute, value: value)
    }
    
    /// Value must be a CFArray of 4 CFNumbers representing alpha, red, green, and blue fields with values between 0.0 and 1.0. The red, green and blue components are interpreted in the sRGB color space. The alpha indicates the opacity from 0.0 for transparent to 1.0 for 100% opaque.
    /// The color applies to the geometry (for example, a box) containing the text. The container's background color may have an alpha of 0 so it is not displayed even though the text is displayed. The color behind individual characters is optionally controllable with the kCMTextMarkupAttribute_CharacterBackgroundColorARGB attribute.
    /// If used, this attribute must be applied to the entire attributed string.
    public func set(backgroundColorARGB value: Any) {
        let attribute: CFString = kCMTextMarkupAttribute_BackgroundColorARGB
        set(attribute: attribute, value: value)
    }
    
    /// Value must be a CFArray of 4 CFNumbers representing alpha, red, green, and blue fields with values between 0.0 and 1.0. The red, green and blue components are interpreted in the sRGB color space. The alpha indicates the opacity from 0.0 for transparent to 1.0 for 100% opaque.
    public func set(foregroundColorARGB value: Any) {
        let attribute: CFString = kCMTextMarkupAttribute_ForegroundColorARGB
        set(attribute: attribute, value: value)
    }
    
    /// Value must be one of the CFString constants in Generic Font Names. Generic fonts must be mapped to the family name of an installed font before rendering and/or measuring text (see Media Accessibility Function).
    /// When vended by legible output, an attributed string will have at most one of kCMTextMarkupAttribute_FontFamilyName or kCMTextMarkupAttribute_GenericFontFamilyName associated with each character.
    public func set(genericFontFamilyName value: Any) {
        let attribute: CFString = kCMTextMarkupAttribute_GenericFontFamilyName
        set(attribute: attribute, value: value)
    }
    
    /// Value must be a CFArray of 4 CFNumbers representing alpha, red, green, and blue fields with values between 0.0 and 1.0. The red, green and blue components are interpreted in the sRGB color space. The alpha indicates the opacity from 0.0 for transparent to 1.0 for 100% opaque.
    public func set(characterBackgroundColorARGB value: Any) {
        let attribute: CFString = kCMTextMarkupAttribute_CharacterBackgroundColorARGB
        set(attribute: attribute, value: value)
    }
    
    /// Value must be a non-negative CFNumber. This is a number expressing the width of the bounding box for text layout as a percentage of the video frame's dimension in the writing direction. For a horizontal writing direction, it is the width. For a vertical writing direction, it is the height.
    /// If used, this attribute must be applied to the entire attributed string.
    public func set(writingDirectionSizePercentage value: Any) {
        let attribute: CFString = kCMTextMarkupAttribute_WritingDirectionSizePercentage
        set(attribute: attribute, value: value)
    }
    
    /// Value must be a non-negative CFNumber. This is a number holding a percentage of the height of the video frame. For example, a value of 5 indicates that the base font size should be 5% of the height of the video.
    public func set(baseFontSizePercentageRelativeToVideoHeight value: Any) {
        let attribute: CFString = kCMTextMarkupAttribute_BaseFontSizePercentageRelativeToVideoHeight
        set(attribute: attribute, value: value)
    }
    
    /// Value must be a non-negative CFNumber. This is a number expressing the position of the center of the cue relative to the writing direction. The line position is orthogonal (or perpendicular) to the writing direction (that is, for a horizontal writing direction, it is vertical and for a vertical writing direction, is is horizontal). This attribute expresses the line position as a percentage of the dimensions of the video frame in the relevant direction. For example, 0% is the top of the video frame and 100% is the bottom of the video frame for horizontal writing layout.
    /// If used, this attribute must be applied to the entire attributed string.
    public func set(orthogonalLinePositionPercentageRelativeToWritingDirection value: Any) {
        let attribute: CFString = kCMTextMarkupAttribute_OrthogonalLinePositionPercentageRelativeToWritingDirection
        set(attribute: attribute, value: value)
    }
    
}
