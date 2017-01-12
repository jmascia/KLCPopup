//
//  Animatable.swift
//  PopupKit
//
//  Created by Ryne Cheow on 12/1/17.
//  Copyright © 2017 Kullect Inc. All rights reserved.
//

import Foundation


//MARK: - Constants

internal let kAnimationOptionCurveUndocumented = UIViewAnimationOptions(rawValue: (7 << 16))
internal let animationDurationStandard: TimeInterval = 0.15
internal let animationDurationLong: TimeInterval = 0.30
internal let animationBounceConstant: CGFloat = 40.0
internal let bounce1Duration: TimeInterval = 0.13
internal let bounce2Duration: TimeInterval = 0.13 * 2.0

protocol Animatable {
    var animationDuration: TimeInterval { get }
    var animationOptions: UIViewAnimationOptions { get }
    func animationClosure(with popUpView: PopupView) -> () -> ()

    func animationCompletion(with popUpView: PopupView, completionClosure: @escaping (Bool) -> ()) -> ((Bool) -> ())?
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

    func animationClosure(with popUpView: PopupView) -> () -> () {
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
}
