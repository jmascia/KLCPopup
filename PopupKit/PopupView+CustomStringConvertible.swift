//
//  PopupView+CustomStringConvertible.swift
//  Pods
//
//  Created by Ryne Cheow on 13/1/17.
//
//

import Foundation

extension PopupView.HorizontalLayout: CustomStringConvertible {
    public var description: String {
        switch self {
        case .center:
            return "Center"
        case .left:
            return "Left"
        case .leftOfCenter:
            return "Left of center"
        case .right:
            return "Right"
        case .rightOfCenter:
            return "Right of center"
        }
    }
}

extension PopupView.VerticalLayout: CustomStringConvertible {
    public var description: String {
        switch self {
        case .center:
            return "Center"
        case .top:
            return "Top"
        case .aboveCenter:
            return "Above center"
        case .bottom:
            return "Bottom"
        case .belowCenter:
            return "Below center"
        }
    }
}


extension PopupView.ShowType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .bounceIn:
            return "Bounce in"
        case .bounceInFromTop:
            return "Bounce in from top"
        case .bounceInFromBottom:
            return "Bounce in from bottom"
        case .bounceInFromLeft:
            return "Bounce in from left"
        case .bounceInFromRight:
            return "Bounce in from right"
        case .fadeIn:
            return "Fade in"
        case .growIn:
            return "Grow in"
        case .shrinkIn:
            return "Shrink in"
        case .slideInFromTop:
            return "Slide in from top"
        case .slideInFromLeft:
            return "Slide in from left"
        case .slideInFromRight:
            return "Slide in from right"
        case .slideInFromBottom:
            return "Slide in from bottom"
        case .none:
            return "None"
        }
    }
}

extension PopupView.DismissType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .bounceOut:
            return "Bounce out"
        case .bounceOutToTop:
            return "Bounce out to top"
        case .bounceOutToBottom:
            return "Bounce out to bottom"
        case .bounceOutToLeft:
            return "Bounce out to left"
        case .bounceOutToRight:
            return "Bounce out to right"
        case .fadeOut:
            return "Fade out"
        case .growOut:
            return "Grow out"
        case .shrinkOut:
            return "Shrink out"
        case .slideOutToTop:
            return "Slide out to top"
        case .slideOutToLeft:
            return "Slide out to left"
        case .slideOutToRight:
            return "Slide out to right"
        case .slideOutToBottom:
            return "Slide out to bottom"
        case .none:
            return "None"
        }
    }
}

extension PopupView.MaskType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .none:
            return "None"
        case .clear:
            return "Clear"
        case .dimmed:
            return "Dimmed"
        case .lightBlur:
            return "Light blur"
        case .darkBlur:
            return "Dark blur"
        }
    }
}
