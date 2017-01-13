//
//  Animatable.swift
//  PopupKit
//
//  Created by Ryne Cheow on 12/1/17.
//

import Foundation


//MARK: - Constants

internal let kAnimationOptionCurveUndocumented = UIViewAnimationOptions(rawValue: (7 << 16))
internal let animationDurationStandard: TimeInterval = 0.15
internal let animationDurationLong: TimeInterval = 0.30
internal let animationBounceConstant: CGFloat = 40.0
internal let bounce1Duration: TimeInterval = 0.13
internal let bounce2Duration: TimeInterval = 0.13 * 2.0
internal let bounce3Duration: TimeInterval = 0.6

protocol Animatable {
    var animationDuration: TimeInterval { get }
    var animationOptions: UIViewAnimationOptions { get }
    var springVelocity: CGFloat { get }
    func animationClosure(with popUpView: PopupView, rect:CGRect?) -> () -> ()

    func animationCompletion(with popUpView: PopupView, completionClosure: @escaping (Bool) -> ()) -> ((Bool) -> ())?
    
    func animate(with popUpView: PopupView, containerFrame:CGRect?, completionClosure: @escaping (Bool) -> ())
}

extension PopupView.DismissType: Animatable {

    var animationDuration: TimeInterval {
        switch self {
        case .fadeOut, .growOut, .shrinkOut:
            return animationDurationStandard
        case .slideOutToTop, .slideOutToBottom, .slideOutToLeft, .slideOutToRight:
            return animationDurationLong
        case .bounceOut, .bounceOutToTop, .bounceOutToBottom, .bounceOutToLeft, .bounceOutToRight:
            return bounce1Duration
        case .none:
            return 0.0
        }
    }

    var animationOptions: UIViewAnimationOptions {
        switch self {
        case .fadeOut:
            return [.curveLinear]
        case .growOut, .shrinkOut, .slideOutToTop, .slideOutToBottom, .slideOutToLeft, .slideOutToRight:
            return kAnimationOptionCurveUndocumented
        case .bounceOut, .bounceOutToTop, .bounceOutToLeft, .bounceOutToRight, .bounceOutToBottom:
            return [.curveEaseOut]
        case .none:
            return []
        }
    }
    
    var springVelocity: CGFloat {
        return 0.0
    }

    func animationClosure(with popUpView: PopupView, rect:CGRect?) -> () -> () {
        switch self {
        case .fadeOut:
            return {
                popUpView.containerView.alpha = 0.0
            }
        case .growOut:
            return {
                popUpView.containerView.alpha = 0.0
                popUpView.containerView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }
        case .shrinkOut:
            return {
                popUpView.containerView.alpha = 0.0
                popUpView.containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }
        case .slideOutToTop:
            return {
                var finalFrame = popUpView.containerView.frame
                finalFrame.origin.y = -1 * finalFrame.height
                popUpView.containerView.frame = finalFrame
            }
        case .slideOutToBottom:
            return {
                var finalFrame = popUpView.containerView.frame
                finalFrame.origin.y = popUpView.bounds.height
                popUpView.containerView.frame = finalFrame
            }
        case .slideOutToLeft:
            return {
                var finalFrame = popUpView.containerView.frame
                finalFrame.origin.x = -1 * finalFrame.width
                popUpView.containerView.frame = finalFrame
            }
        case .slideOutToRight:
            return {
                var finalFrame = popUpView.containerView.frame
                finalFrame.origin.x = popUpView.bounds.width
                popUpView.containerView.frame = finalFrame
            }
        case .bounceOut:
            return {
                popUpView.containerView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }
        case .bounceOutToTop:
            return {
                var finalFrame = popUpView.containerView.frame
                finalFrame.origin.y += animationBounceConstant
                popUpView.containerView.frame = finalFrame
            }
        case .bounceOutToLeft:
            return {
                var finalFrame = popUpView.containerView.frame
                finalFrame.origin.x += animationBounceConstant
                popUpView.containerView.frame = finalFrame
            }
        case .bounceOutToRight:
            return {
                var finalFrame = popUpView.containerView.frame
                finalFrame.origin.x -= animationBounceConstant
                popUpView.containerView.frame = finalFrame
            }
        case .bounceOutToBottom:
            return {
                var finalFrame = popUpView.containerView.frame
                finalFrame.origin.y -= animationBounceConstant
                popUpView.containerView.frame = finalFrame
            }
        case .none:
            return {
            }
        }
    }

    func animationCompletion(with popUpView: PopupView, completionClosure: @escaping (Bool) -> ()) -> ((Bool) -> ())? {
        switch self {
        case .fadeOut, .growOut, .shrinkOut, .slideOutToTop, .slideOutToBottom, .slideOutToLeft, .slideOutToRight:
            return completionClosure
        case .bounceOut:
            return {
                finished in
                UIView.animate(withDuration: bounce2Duration, delay: 0, options: [.curveEaseIn], animations: {
                    popUpView.containerView.alpha = 0.0
                    popUpView.containerView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)

                }, completion: completionClosure)
            }
        case .bounceOutToTop:
            return {
                finished in
                UIView.animate(withDuration: bounce2Duration, delay: 0, options: [.curveEaseIn], animations: {
                    var finalFrame = popUpView.containerView.frame
                    finalFrame.origin.y = -1 * finalFrame.height
                    popUpView.containerView.frame = finalFrame

                }, completion: completionClosure)
            }
        case .bounceOutToBottom:
            return {
                finished in
                UIView.animate(withDuration: bounce2Duration, delay: 0, options: [.curveEaseIn], animations: {
                    var finalFrame = popUpView.containerView.frame
                    finalFrame.origin.y = popUpView.bounds.height
                    popUpView.containerView.frame = finalFrame

                }, completion: completionClosure)
            }
        case .bounceOutToLeft:
            return {
                finished in
                UIView.animate(withDuration: bounce2Duration, delay: 0, options: [.curveEaseIn], animations: {
                    var finalFrame = popUpView.containerView.frame
                    finalFrame.origin.x = -1 * finalFrame.width
                    popUpView.containerView.frame = finalFrame

                }, completion: completionClosure)
            }
        case .bounceOutToRight:
            return {
                finished in
                UIView.animate(withDuration: bounce2Duration, delay: 0, options: [.curveEaseIn], animations: {
                    var finalFrame = popUpView.containerView.frame
                    finalFrame.origin.x = popUpView.bounds.width
                    popUpView.containerView.frame = finalFrame

                }, completion: completionClosure)
            }
        case .none:
            return nil
        }
    }
    
    func animate(with popUpView:PopupView, containerFrame:CGRect?, completionClosure: @escaping (Bool) -> ()) {
        UIView.animate(withDuration: animationDuration, delay: 0, options: animationOptions, animations: animationClosure(with: popUpView, rect:containerFrame), completion: animationCompletion(with: popUpView, completionClosure: completionClosure))
    }
}

extension PopupView.ShowType: Animatable {
    var animationDuration: TimeInterval {
        switch self {
        case .fadeIn, .growIn, .shrinkIn:
            return animationDurationStandard
        case .slideInFromTop, .slideInFromBottom, .slideInFromLeft, .slideInFromRight:
            return animationDurationLong
        case .bounceIn, .bounceInFromTop, .bounceInFromBottom, .bounceInFromLeft, .bounceInFromRight:
            return bounce3Duration
        case .none:
            return 0.0
        }
    }
    
    var animationOptions: UIViewAnimationOptions {
        switch self {
        case .fadeIn:
            return [.curveLinear]
        case .growIn, .shrinkIn, .slideInFromTop, .slideInFromBottom, .slideInFromLeft, .slideInFromRight:
            return kAnimationOptionCurveUndocumented
        default:
            return []
        }
    }
    
    var springVelocity: CGFloat {
        switch self {
        case .bounceIn:
            return 15
        case .bounceInFromBottom, .bounceInFromLeft, .bounceInFromRight, .bounceInFromTop:
            return 10.0
        default:
            return 0.0
        }
    }
    
    func animationClosure(with popUpView: PopupView, rect:CGRect?) -> () -> () {
        switch self {
        case .fadeIn:
            return {
                popUpView.containerView.alpha = 1.0
            }
        case .growIn, .shrinkIn:
            return {
                popUpView.containerView.alpha = 1.0
                popUpView.containerView.transform = CGAffineTransform.identity
                popUpView.containerView.frame = rect ?? popUpView.containerView.frame
            }
        case .slideInFromTop, .slideInFromBottom, .slideInFromLeft, .slideInFromRight, .bounceInFromTop, .bounceInFromBottom, .bounceInFromLeft, .bounceInFromRight:
            return {
                popUpView.containerView.frame = rect ?? popUpView.containerView.frame
            }
        case .bounceIn:
            return {
                popUpView.containerView.alpha = 1.0
                popUpView.transform = CGAffineTransform.identity
            }
        default:
            return {}
        }
    }
    func animationCompletion(with popUpView: PopupView, completionClosure: @escaping (Bool) -> ()) -> ((Bool) -> ())? {
        return self == .none ? nil : completionClosure
    }

    func animate(with popUpView: PopupView, containerFrame:CGRect?, completionClosure: @escaping (Bool) -> ()) {
        guard self != .none else {
            return
        }
        
        guard let containerFrame = containerFrame else {
            return
        }
        
        // Set frame before transform
        switch self {
        case .fadeIn:
            popUpView.containerView.alpha = 0.0
            popUpView.containerView.transform = CGAffineTransform.identity
            popUpView.containerView.frame = containerFrame
        case .growIn:
            popUpView.containerView.alpha = 0.0
            popUpView.containerView.frame = containerFrame
            popUpView.containerView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        case .shrinkIn:
            popUpView.containerView.alpha = 0.0
            popUpView.containerView.frame = containerFrame
            popUpView.containerView.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        case .slideInFromTop, .bounceInFromTop:
            popUpView.containerView.alpha = 1.0
            popUpView.containerView.transform = CGAffineTransform.identity
            var startFrame = containerFrame
            startFrame.origin.y = -1 * containerFrame.height
            popUpView.containerView.frame = startFrame
        case .slideInFromBottom, .bounceInFromBottom:
            popUpView.containerView.alpha = 1.0
            popUpView.containerView.transform = CGAffineTransform.identity
            var startFrame = containerFrame
            startFrame.origin.y = popUpView.bounds.height
            popUpView.containerView.frame = startFrame
        case .slideInFromLeft, .bounceInFromLeft:
            popUpView.containerView.alpha = 1.0
            popUpView.containerView.transform = CGAffineTransform.identity
            var startFrame = containerFrame
            startFrame.origin.x = -1 * containerFrame.width
            popUpView.containerView.frame = startFrame
        case .slideInFromRight, .bounceInFromRight:
            popUpView.containerView.alpha = 1.0
            popUpView.containerView.transform = CGAffineTransform.identity
            var startFrame = containerFrame
            startFrame.origin.x = popUpView.bounds.width
            popUpView.containerView.frame = startFrame
        case .bounceIn:
            popUpView.containerView.alpha = 0.0
            popUpView.containerView.frame = containerFrame
            popUpView.containerView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        case .none:
            break
        }
        
        // Animate content
        switch self {
        case .fadeIn, .growIn, .shrinkIn, .slideInFromTop, .slideInFromLeft, .slideInFromBottom, .slideInFromRight:
            UIView.animate(withDuration: animationDuration, delay: 0, options: animationOptions, animations: animationClosure(with: popUpView, rect: containerFrame), completion: completionClosure)
        case .bounceIn, .bounceInFromTop, .bounceInFromBottom, .bounceInFromLeft, .bounceInFromRight:
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: springVelocity, options: [], animations:animationClosure(with: popUpView, rect: containerFrame), completion: completionClosure)
        case .none:
            break
        }
        
    }

}
