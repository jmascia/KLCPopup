//
//  KeyboardHandling.swift
//  PopupKit
//
//  Created by Ryne Cheow on 13/1/17.
//
//

import Foundation

#if !os(tvOS)
    extension PopupView {
        func didChangeStatusBarOrientation(notification: Notification) {
            updateForInterfaceOrientation()
        }

        func keyboardDidShow(notification: Notification) {
            guard let rect = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect else {
                return
            }

            keyboardRect = convert(rect, from: nil)
        }

        func keyboardDidHide(notification: Notification) {
            keyboardRect = CGRect.zero
        }

    }

    extension PopupViewDelegate {
        func willStartShowing(popUpView: PopupView) {
            guard popUpView.shouldHandleKeyboard else {
                return
            }

            NotificationCenter.default.addObserver(popUpView, selector: #selector(PopupView.keyboardWillShowNotification(notification:)), name: .UIKeyboardWillShow, object: nil)

            NotificationCenter.default.addObserver(popUpView, selector: #selector(PopupView.keyboardWillHideNotification(notification:)), name: .UIKeyboardWillHide, object: nil)
        }

        func didFinishDismissing(popUpView: PopupView) {
            NotificationCenter.default.removeObserver(popUpView, name: .UIKeyboardWillShow, object: nil)
            NotificationCenter.default.removeObserver(popUpView, name: .UIKeyboardWillHide, object: nil)
        }
    }
    protocol KeyboardHandling {
        func keyboardWillShowNotification(notification: Notification)
        func keyboardWillHideNotification(notification: Notification)
    }

    extension PopupView: KeyboardHandling {
        //MARK: - Keyboard notification handlers
        func keyboardWillShowNotification(notification: Notification) {
            moveContainerViewForKeyboard(with: notification, isUp: true)
        }

        func keyboardWillHideNotification(notification: Notification) {
            moveContainerViewForKeyboard(with: notification, isUp: false)
        }

        func moveContainerViewForKeyboard(with notification: Notification, isUp: Bool) {
            guard let userInfo = notification.userInfo,
                let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval,
                let animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? UIViewAnimationCurve,
                let keyboardEndFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect,
                let containerSuperView = containerView.superview else {
                    return
            }

            containerView.center = CGPoint(x: containerSuperView.frame.width / 2, y: containerSuperView.superview!.frame.height / 2)

            var frame = containerView.frame
            if isUp {
                frame.origin.y -= keyboardEndFrame.height / 2
            }

            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(animationDuration)
            UIView.setAnimationCurve(animationCurve)
            containerView.frame = frame
            UIView.commitAnimations()
        }
    }
#endif
