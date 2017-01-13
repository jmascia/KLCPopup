//
//  Layoutable.swift
//  Pods
//
//  Created by Alvin Choo on 13/1/17.
//
//

protocol Layoutable {
    func originValue(with popUpView: PopupView, rect: CGRect) -> CGFloat
    func autoresizingMask(with origin: UIViewAutoresizing) -> UIViewAutoresizing
}

extension PopupView.HorizontalLayout: Layoutable {
    func originValue(with popUpView: PopupView, rect: CGRect) -> CGFloat {
        switch self {
        case .left:
            return 0.0
        case .leftOfCenter:
            return floor(popUpView.bounds.width / 3.0 - rect.width / 2.0)
        case .center:
            return floor((popUpView.bounds.width - rect.width) / 2.0)
        case .rightOfCenter:
            return floor((popUpView.bounds.width * 2.0 / 3.0) - (rect.width / 2.0))
        case .right:
            return popUpView.bounds.width - rect.width
        default:
            return 0.0
        }
    }
    
    func autoresizingMask(with origin: UIViewAutoresizing) -> UIViewAutoresizing {
        switch self {
        case .left:
            return [origin, .flexibleRightMargin]
        case .leftOfCenter:
            return [origin, .flexibleLeftMargin, .flexibleRightMargin]
        case .center:
            return [origin, .flexibleLeftMargin, .flexibleRightMargin]
        case .rightOfCenter:
            return [origin, .flexibleLeftMargin, .flexibleRightMargin]
        case .right:
            return [origin, .flexibleLeftMargin]
        default:
            return []
        }
    }
}

extension PopupView.VerticalLayout: Layoutable {
    func originValue(with popUpView: PopupView, rect: CGRect) -> CGFloat {
        switch self {
        case .top:
            return 0.0
        case .aboveCenter:
            return floor(popUpView.bounds.width / 3.0 - rect.height / 2.0)
        case .center:
            return floor((popUpView.bounds.height - rect.height) / 2.0)
        case .belowCenter:
            return floor((popUpView.bounds.height * 2.0 / 3.0) - (rect.height / 2.0))
        case .bottom:
            return popUpView.bounds.height - rect.height
        default:
            return 0.0
        }
    }
    
    func autoresizingMask(with origin: UIViewAutoresizing) -> UIViewAutoresizing {
        switch self {
        case .top:
            return [origin, .flexibleBottomMargin]
        case .aboveCenter:
            return [origin, .flexibleTopMargin, .flexibleBottomMargin]
        case .center:
            return [origin, .flexibleTopMargin, .flexibleBottomMargin]
        case .belowCenter:
            return [origin, .flexibleTopMargin, .flexibleBottomMargin]
        case .bottom:
            return [origin, .flexibleTopMargin]
        default:
            return []
        }
    }
}
