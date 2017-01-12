//
//  PopupView.swift
//  PopupKit
//
//  Created by Alvin Choo on 9/1/17.
//

import UIKit

//MARK: - Protocol

public protocol PopupViewDelegate: class {
    func willStartShowing(popUpView: PopupView)

    func didFinishShowing(popUpView: PopupView)

    func willStartDismissing(popUpView: PopupView)

    func didFinishDismissing(popUpView: PopupView)
}

//MARK: - Constants

fileprivate let kAnimationOptionCurveUndocumented = UIViewAnimationOptions(rawValue: (7 << 16))
fileprivate let animationDurationStandard: TimeInterval = 0.15
fileprivate let animationDurationLong: TimeInterval = 0.30
fileprivate let animationBounceConstant: CGFloat = 40.0
fileprivate let bounce1Duration: TimeInterval = 0.13
fileprivate let bounce2Duration: TimeInterval = 0.13 * 2.0

open class PopupView: UIView {
    //MARK: - Enums

    /// Controls how the popup will be presented.

    public enum ShowType {
        case none
        case fadeIn
        case growIn
        case shrinkIn
        case slideInFromTop
        case slideInFromBottom
        case slideInFromLeft
        case slideInFromRight
        case bounceIn
        case bounceInFromTop
        case bounceInFromBottom
        case bounceInFromLeft
        case bounceInFromRight
    }

    /// Controls how the popup will be dismissed.

    public enum DismissType {
        case none
        case fadeOut
        case growOut
        case shrinkOut
        case slideOutToTop
        case slideOutToBottom
        case slideOutToLeft
        case slideOutToRight
        case bounceOut
        case bounceOutToTop
        case bounceOutToBottom
        case bounceOutToLeft
        case bounceOutToRight

        var animationDuration: TimeInterval {
            switch self {
            case .fadeOut, .growOut, .shrinkOut:
                return animationDurationStandard
            case .slideOutToTop, .slideOutToBottom, .slideOutToLeft, .slideOutToRight:
                return animationDurationLong
            case .bounceOut, .bounceOutToTop, .bounceOutToBottom, .bounceOutToLeft, .bounceOutToRight:
                return bounce1Duration
            case .none:
                return 0
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
                    var finalFrame = popUpView.frame
                    finalFrame.origin.y = -1 * finalFrame.height
                    popUpView.containerView.frame = finalFrame
                }
            case .slideOutToBottom:
                return {
                    var finalFrame = popUpView.frame
                    finalFrame.origin.y = popUpView.bounds.height
                    popUpView.containerView.frame = finalFrame
                }
            case .slideOutToLeft:
                return {
                    var finalFrame = popUpView.frame
                    finalFrame.origin.x = -1 * finalFrame.width
                    popUpView.containerView.frame = finalFrame
                }
            case .slideOutToRight:
                return {
                    var finalFrame = popUpView.frame
                    finalFrame.origin.x = popUpView.bounds.width
                    popUpView.containerView.frame = finalFrame
                }
            case .bounceOut:
                return {
                    popUpView.containerView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                }
            case .bounceOutToTop:
                return {
                    var finalFrame = popUpView.frame
                    finalFrame.origin.y += animationBounceConstant
                    popUpView.containerView.frame = finalFrame
                }
            case .bounceOutToLeft:
                return {
                    var finalFrame = popUpView.frame
                    finalFrame.origin.x += animationBounceConstant
                    popUpView.containerView.frame = finalFrame
                }
            case .bounceOutToRight:
                return {
                    var finalFrame = popUpView.frame
                    finalFrame.origin.x -= animationBounceConstant
                    popUpView.containerView.frame = finalFrame
                }
            case .bounceOutToBottom:
                return {
                    var finalFrame = popUpView.frame
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
                        popUpView.frame = finalFrame

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

    /// Controls where the popup will come to rest horizontally.

    public enum HorizontalLayout {
        case custom
        case left
        case leftOfCenter
        case center
        case rightOfCenter
        case right
    }

    /// Controls where the popup will come to rest vertically.

    public enum VerticalLayout {
        case custom
        case top
        case aboveCenter
        case center
        case belowCenter
        case bottom
    }

    public enum MaskType {
        /// Allow interaction with underlying views.
        case none
        /// Don't allow interaction with underlying views.
        case clear
        /// Don't allow interaction with underlying views, dim background.
        case dimmed
        /// Don't allow interaction with underlying views, blurs background.
        case lightBlur
        /// Don't allow interaction with underlying views, blurs background.
        case darkBlur
    }

    public enum Layout {
        case center
        case custom(horizontal: HorizontalLayout, vertical: VerticalLayout)

        public var horizontal: HorizontalLayout {
            get {
                switch self {
                case .center:
                    return .center
                case .custom(let horizontal, _):
                    return horizontal
                }
            }
        }

        public var vertical: VerticalLayout {
            get {
                switch self {
                case .center:
                    return .center
                case .custom(_, let vertical):
                    return vertical
                }
            }
        }
    }

    //MARK: - Properties

    /// This is the view that you want to appear in Popup.
    /// - Must provide contentView before or in willStartShowing.
    /// - Must set desired size of contentView before or in willStartShowing.
    public private(set) var contentView: UIView

    /// Animation transition for presenting contentView. default = shrink in
    public var showType: ShowType = .shrinkIn

    /// Animation transition for dismissing contentView. default = shrink out
    public var dismissType: DismissType = .shrinkOut

    /// Mask prevents background touches from passing to underlying views. default = dimmed.
    public var maskType: MaskType = .dimmed

    /// Overrides alpha value for dimmed background mask. default = 0.5
    public var dimmedMaskAlpha: CGFloat = 0.5

    /// If YES, then popup will get dismissed when background is touched. default = YES.
    public var shouldDismissOnBackgroundTouch = true

    /// If YES, then popup will get dismissed when content view is touched. default = NO.
    public var shouldDismissOnContentTouch = false

    /// If YES, then popup will move up or down when keyboard is on or off screen. default = NO.
    public var shouldHandleKeyboard = false

    public weak var delegate: PopupViewDelegate?

    private let backgroundView: UIView
    private let containerView: UIView
    private var isBeingShown = false
    private var isShowing = false
    private var isBeingDismissed = false
    private var keyboardRect = CGRect.zero

    //MARK: - Closure
    /// Block gets called after show animation finishes. Be sure to use weak reference for popup within the block to avoid retain cycle.
    public var didFinishShowingCompletion: (() -> ())?


    /// Block gets called when dismiss animation starts. Be sure to use weak reference for popup within the block to avoid retain cycle.
    public var willStartDismissingCompletion: (() -> ())?

    /// Block gets called after dismiss animation finishes. Be sure to use weak reference for popup within the block to avoid retain cycle.
    public var didFinishDismissingCompletion: (() -> ())?

    //MARK: - Initializer

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Designated method for creating popup with default values (mimics UIAlertView).
    public init(contentView: UIView) {
        self.contentView = contentView
        backgroundView = UIView()
        containerView = UIView()

        super.init(frame: UIScreen.main.bounds)
        isUserInteractionEnabled = true
        backgroundColor = UIColor.clear
        alpha = 0
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        autoresizesSubviews = true

        backgroundView.backgroundColor = UIColor.clear
        backgroundView.isUserInteractionEnabled = false
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.frame = self.bounds

        containerView.autoresizesSubviews = false
        containerView.isUserInteractionEnabled = true
        containerView.backgroundColor = UIColor.clear

        addSubview(backgroundView)
        addSubview(containerView)

#if !os(tvOS)
        // Register for Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(PopupView.didChangeStatusBarOrientation(notification:)), name: .UIApplicationDidChangeStatusBarFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PopupView.keyboardDidShow(notification:)), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PopupView.keyboardDidHide(notification:)), name: .UIKeyboardDidHide, object: nil)
#endif
    }

    // Convenience method for creating popup with custom values.
    public convenience init(contentView: UIView, showType: ShowType, dismissType: DismissType, maskType: MaskType, shouldDismissOnBackgroundTouch: Bool, shouldDismissOnContentTouch: Bool) {
        self.init(contentView: contentView)
        self.showType = showType
        self.dismissType = dismissType
        self.maskType = maskType
        self.shouldDismissOnBackgroundTouch = shouldDismissOnBackgroundTouch
        self.shouldDismissOnContentTouch = shouldDismissOnContentTouch
    }

    deinit {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        // stop listening to notifications
        NotificationCenter.default.removeObserver(self)
    }


    //MARK: - UIView
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

        guard !keyboardRect.contains(point) else {
            return nil
        }

        let hitView = super.hitTest(point, with: event)

        guard let safeHitView = hitView else {
            return nil
        }

        let hitViewClassName = NSStringFromClass(type(of: safeHitView))

        if safeHitView == self || hitViewClassName == "_UIVisualEffectContentView" {

            // Try to dismiss if backgroundTouch flag set.
            if shouldDismissOnBackgroundTouch {
                self.dismiss(animated: true)
            }

            // If no mask, then return nil so touch passes through to underlying views.
            guard maskType != .none else {
                return nil
            }

        } else {
            // If view is within containerView and contentTouch flag set, then try to hide.
            if safeHitView.isDescendant(of: containerView) && shouldDismissOnContentTouch {
                self.dismiss(animated: true)
            }
        }

        return hitView
    }

    //MARK: - Public methods

    /// Dismisses all the popups in the app. Use as a fail-safe for cleaning up.
    public class func dismissAllPopups() {
        UIApplication.shared.windows.forEach { window in
            window.forEachPopupDoBlock { popup in
                popup.dismiss(animated: false)
            }
        }
    }


    /// Show popup with center layout. Animation determined by showType.
    open func show() {
        show(with: Layout.center)
    }


    /// Show with specified layout.
    open func show(with layout: Layout) {
        show(with: layout, duration: 0.0)
    }


    /// Show with specified layout in specific view.
    open func show(with layout: Layout, in view: UIView) {
        let parameters: [String: Any] = [
                "layout": layout,
                "view": view
        ]

        show(with: parameters)
    }


    /// Show and then dismiss after duration. 0.0 or less will be considered infinity.
    open func show(with duration: TimeInterval) {
        show(with: Layout.center, duration: duration)
    }


    /// Show with layout and dismiss after duration.
    open func show(with layout: PopupView.Layout, duration: TimeInterval) {
        let parameters: [String: Any] = [
                "layout": layout,
                "duration": duration
        ]

        show(show(with: parameters))
    }


    /// Show centered at point in view's coordinate system. If view is nil use screen base coordinates.
    open func show(at center: CGPoint, in view: UIView) {
        show(at: center, in: view, with: 0.0)
    }


    /// Show centered at point in view's coordinate system, then dismiss after duration.
    open func show(at center: CGPoint, in view: UIView, with duration: TimeInterval) {
        let parameters: [String: Any] = [
                "center": center,
                "duration": duration,
                "view": view
        ]

        show(with: parameters)
    }

    open func dismiss(animated: Bool = true) {

        guard isShowing && !isBeingDismissed else {
            return
        }

        isBeingShown = false
        isShowing = false
        isBeingDismissed = true

        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(PopupView.dismiss(animated:)), object: nil)

        delegate?.willStartDismissing(popUpView: self)

        if let willStartDismissingCompletion = willStartDismissingCompletion {
            willStartDismissingCompletion()
        }

        DispatchQueue.main.async {
            let backgroundAnimation = {
                self.backgroundView.alpha = 0.0
            }

            if animated && self.showType != .none {
                // Make fade happen faster than motion. Use linear for fades.

                UIView.animate(withDuration: animationDurationStandard, delay: 0, options: [.curveLinear],
                        animations: backgroundAnimation,
                        completion: nil)
            } else {
                backgroundAnimation()
            }

            // Setup completion block
            let completionClosure: (Bool) -> () = {
                finished in
                self.removeFromSuperview()
                self.isBeingShown = false
                self.isShowing = false
                self.isBeingDismissed = false

                self.delegate?.didFinishDismissing(popUpView: self)

                if let didFinishDismissingCompletion = self.didFinishDismissingCompletion {
                    didFinishDismissingCompletion()
                }
            }

            guard animated && self.dismissType != .none else {
                self.containerView.alpha = 0.0
                completionClosure(true)
                return
            }

            UIView.animate(withDuration: self.dismissType.animationDuration, delay: 0, options: self.dismissType.animationOptions, animations: self.dismissType.animationClosure(with: self), completion: self.dismissType.animationCompletion(with: self, completionClosure: completionClosure))

        }

    }

    //MARK: - Private Methods
    private func show(with parameters: [String: Any]) {
        guard !isBeingShown && !isShowing && !isBeingDismissed else {
            return
        }

        isBeingShown = true
        isShowing = false
        isBeingDismissed = false

        self.delegate?.willStartShowing(popUpView: self)

        DispatchQueue.main.async {
            // Prepare by adding to the top window.
            var destView: UIView?
            if self.superview == nil {
                destView = parameters["view"] as? UIView
                destView = destView ?? UIApplication.shared.windows.reversed()
                        .first {
                            $0.windowLevel == UIWindowLevelNormal
                        }

                if let destView = destView {
                    destView.addSubview(self)
                    destView.bringSubview(toFront: self)
                }

            }

            // Before we calculate layout for containerView, make sure we are transformed for current orientation.
            self.updateForInterfaceOrientation()

            // Make sure we're not hidden
            self.isHidden = false
            self.alpha = 1.0

            // Setup background view
            self.backgroundView.alpha = 0.0
            self.backgroundView.alpha = 0.0

            let backgroundAnimationBlock = {
                self.backgroundView.alpha = 1.0
            }

            switch self.maskType {
            case .dimmed:
                self.backgroundView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: self.dimmedMaskAlpha)
                backgroundAnimationBlock()
                break
            case .none:
                UIView.animate(withDuration: animationDurationStandard, delay: 0.0, options: [.curveLinear], animations: backgroundAnimationBlock, completion: nil)
                break
            case .clear:
                self.backgroundView.backgroundColor = UIColor.clear
                break
            case .lightBlur:
                let blurEffect = UIBlurEffect(style: .light)
                let visualBlur = UIVisualEffectView(effect: blurEffect)
                visualBlur.frame = self.backgroundView.frame
                visualBlur.contentView.addSubview(self.backgroundView)
                self.insertSubview(visualBlur, belowSubview: self.containerView)
                break
            case .darkBlur:
                let blurEffect = UIBlurEffect(style: .dark)
                let visualBlur = UIVisualEffectView(effect: blurEffect)
                visualBlur.frame = self.backgroundView.frame
                visualBlur.contentView.addSubview(self.backgroundView)
                self.insertSubview(visualBlur, belowSubview: self.containerView)
                break
            }

            // Determine duration. Default to 0 if none provided.
            let duration = parameters["duration"] as? TimeInterval ?? 0.0

            // Setup completion block
            let completionBlock: (Bool) -> () = {
                finished in
                self.isBeingShown = false
                self.isShowing = true
                self.isBeingDismissed = false

                self.delegate?.didFinishShowing(popUpView: self)

                if let didFinishShowingCompletion = self.didFinishShowingCompletion {
                    didFinishShowingCompletion()
                }

                // Set to hide after duration if greater than zero.
                if duration > 0.0 {
                    self.perform(#selector(PopupView.dismiss(animated:)), with: nil, afterDelay: duration)
                }
            }

            // Add contentView to container
            if let contentSuperView = self.contentView.superview,
               contentSuperView != self.contentView {
                self.containerView.addSubview(self.contentView)
            }

            // Re-layout (this is needed if the contentView is using autoLayout)
            self.contentView.layoutIfNeeded()

            // Size container to match contentView
            var containerFrame = self.containerView.frame
            containerFrame.size = self.containerView.frame.size
            self.containerView.frame = containerFrame
            // Position contentView to fill it
            var contentViewFrame = self.contentView.frame
            contentViewFrame.origin = CGPoint.zero
            self.contentView.frame = contentViewFrame

            // Reset containerView's constraints in case contentView is uaing autolayout.
            let contentView = self.contentView
            let views = ["contentView": contentView]

            self.containerView.removeConstraints(self.containerView.constraints)
            let contentViewVerticalConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|[contentView]|",
                    options: [],
                    metrics: nil,
                    views: views)
            self.containerView.addConstraints(contentViewVerticalConstraint)
            let contentViewHorizontalConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|[contentView]|",
                    options: [],
                    metrics: nil,
                    views: views)
            self.containerView.addConstraints(contentViewHorizontalConstraint)

            // Determine final position and necessary autoresizingMask for container.
            var finalContainerFrame = containerFrame
            var containerAutoresizingMask: UIViewAutoresizing = []

            // Use explicit center coordinates if provided.
            let centerValue = parameters["center"] as? CGPoint
            if let centerValue = centerValue {

                var centerInSelf = centerValue

                if let destView = destView {
                    centerInSelf = self.convert(centerValue, from: destView)
                }

                finalContainerFrame.origin.x = centerInSelf.x - finalContainerFrame.width / 2.0
                finalContainerFrame.origin.y = centerInSelf.y - finalContainerFrame.height / 2.0
                containerAutoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleTopMargin]
            } else {
                // Otherwise use relative layout. Default to center if none provided.
                let layoutValue = parameters["layout"] as? Layout

                let layout = layoutValue ?? .center

                // Horizontal
                switch layout.horizontal {
                case .left:
                    finalContainerFrame.origin.x = 0.0
                    containerAutoresizingMask = [containerAutoresizingMask, .flexibleRightMargin]
                    break
                case .leftOfCenter:
                    finalContainerFrame.origin.x = floor(self.bounds.width / 3.0 - containerFrame.width / 2.0)
                    containerAutoresizingMask = [containerAutoresizingMask, .flexibleRightMargin, .flexibleRightMargin]
                    break
                case .center:
                    finalContainerFrame.origin.x = floor(self.bounds.width - containerFrame.width / 2.0)
                    containerAutoresizingMask = [containerAutoresizingMask, .flexibleLeftMargin, .flexibleRightMargin]
                    break
                case .rightOfCenter:
                    finalContainerFrame.origin.x = floor((self.bounds.width * 2.0 / 3.0) - (containerFrame.width / 2.0))
                    containerAutoresizingMask = [containerAutoresizingMask, .flexibleLeftMargin, .flexibleRightMargin]
                    break
                case .right:
                    finalContainerFrame.origin.x = self.bounds.width - containerFrame.width
                    containerAutoresizingMask = [containerAutoresizingMask, .flexibleLeftMargin]
                    break
                default:
                    break
                }

                // Vertical
                switch layout.vertical {
                case .top:
                    finalContainerFrame.origin.y = 0
                    containerAutoresizingMask = [containerAutoresizingMask, .flexibleBottomMargin]
                    break
                case .aboveCenter:
                    finalContainerFrame.origin.y = floor(self.bounds.width / 3.0 - containerFrame.height / 2.0)
                    containerAutoresizingMask = [containerAutoresizingMask, .flexibleTopMargin, .flexibleBottomMargin]
                    break
                case .center:
                    finalContainerFrame.origin.y = floor(self.bounds.height - containerFrame.height / 2.0)
                    containerAutoresizingMask = [containerAutoresizingMask, .flexibleTopMargin, .flexibleBottomMargin]
                    break
                case .belowCenter:
                    finalContainerFrame.origin.y = floor((self.bounds.height * 2.0 / 3.0) - (containerFrame.height / 2.0))
                    containerAutoresizingMask = [containerAutoresizingMask, .flexibleTopMargin, .flexibleBottomMargin]
                    break
                case .bottom:
                    finalContainerFrame.origin.y = self.bounds.height - containerFrame.height
                    containerAutoresizingMask = [containerAutoresizingMask, .flexibleTopMargin]
                    break
                default:
                    break
                }

                self.containerView.autoresizingMask = containerAutoresizingMask

                guard self.showType != .none else {
                    self.containerView.alpha = 1.0
                    self.containerView.transform = CGAffineTransform.identity
                    self.containerView.frame = finalContainerFrame
                    completionBlock(true)
                    return
                }

                // Animate content if needed
                switch self.showType {
                case .fadeIn:
                    self.containerView.alpha = 0.0
                    self.containerView.transform = CGAffineTransform.identity
                    self.containerView.frame = finalContainerFrame

                    UIView.animate(withDuration: animationDurationStandard, delay: 0, options: [.curveLinear], animations: {
                        self.containerView.alpha = 1.0
                    }, completion: completionBlock)
                    break
                case .growIn:
                    self.containerView.alpha = 0.0
                    // set frame before transform here...
                    self.containerView.frame = finalContainerFrame
                    self.containerView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)

                    UIView.animate(withDuration: animationDurationStandard, delay: 0, options: kAnimationOptionCurveUndocumented, animations: {
                        self.containerView.alpha = 1.0
                        self.containerView.transform = CGAffineTransform.identity
                        self.containerView.frame = finalContainerFrame

                    }, completion: completionBlock)
                    break
                case .shrinkIn:
                    self.containerView.alpha = 0.0
                    // set frame before transform here
                    self.containerView.frame = finalContainerFrame
                    self.containerView.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)

                    UIView.animate(withDuration: animationDurationStandard, delay: 0, options: kAnimationOptionCurveUndocumented, animations: {
                        self.containerView.alpha = 1.0
                        self.containerView.transform = CGAffineTransform.identity
                        self.containerView.frame = finalContainerFrame

                    }, completion: completionBlock)
                    break
                case .slideInFromTop:
                    self.containerView.alpha = 1.0
                    self.containerView.transform = CGAffineTransform.identity
                    var startFrame = finalContainerFrame
                    startFrame.origin.y = -1 * finalContainerFrame.height
                    self.containerView.frame = startFrame

                    UIView.animate(withDuration: animationDurationLong, delay: 0, options: kAnimationOptionCurveUndocumented, animations: {
                        self.containerView.frame = finalContainerFrame

                    }, completion: completionBlock)
                    break
                case .slideInFromBottom:
                    self.containerView.alpha = 1.0
                    self.containerView.transform = CGAffineTransform.identity
                    var startFrame = finalContainerFrame
                    startFrame.origin.y = self.bounds.height
                    self.containerView.frame = startFrame

                    UIView.animate(withDuration: animationDurationLong, delay: 0, options: kAnimationOptionCurveUndocumented, animations: {
                        self.containerView.frame = finalContainerFrame

                    }, completion: completionBlock)
                    break
                case .slideInFromLeft:
                    self.containerView.alpha = 1.0
                    self.containerView.transform = CGAffineTransform.identity
                    var startFrame = finalContainerFrame
                    startFrame.origin.x = -1 * finalContainerFrame.width
                    self.containerView.frame = startFrame

                    UIView.animate(withDuration: animationDurationLong, delay: 0, options: kAnimationOptionCurveUndocumented, animations: {
                        self.containerView.frame = finalContainerFrame

                    }, completion: completionBlock)
                    break
                case .slideInFromRight:
                    self.containerView.alpha = 1.0
                    self.containerView.transform = CGAffineTransform.identity
                    var startFrame = finalContainerFrame
                    startFrame.origin.x = self.bounds.width
                    self.containerView.frame = startFrame

                    UIView.animate(withDuration: animationDurationLong, delay: 0, options: kAnimationOptionCurveUndocumented, animations: {
                        self.containerView.frame = finalContainerFrame

                    }, completion: completionBlock)
                    break
                case .bounceIn:
                    self.containerView.alpha = 0.0
                    self.containerView.frame = finalContainerFrame
                    self.containerView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)

                    UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 15.0, options: [], animations: {
                        self.containerView.alpha = 1.0
                        self.containerView.transform = CGAffineTransform.identity
                    }, completion: completionBlock)
                    break
                case .bounceInFromTop:
                    self.containerView.alpha = 1.0
                    self.containerView.transform = CGAffineTransform.identity
                    var startFrame = finalContainerFrame
                    startFrame.origin.y = -1 * finalContainerFrame.height
                    self.containerView.frame = startFrame

                    UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10.0, options: [], animations: {
                        self.containerView.frame = finalContainerFrame
                    }, completion: completionBlock)
                    break
                case .bounceInFromBottom:
                    self.containerView.alpha = 1.0
                    self.containerView.transform = CGAffineTransform.identity
                    var startFrame = finalContainerFrame
                    startFrame.origin.y = self.bounds.height
                    self.containerView.frame = startFrame

                    UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10.0, options: [], animations: {
                        self.containerView.frame = finalContainerFrame
                    }, completion: completionBlock)
                    break
                case .bounceInFromLeft:
                    self.containerView.alpha = 1.0
                    self.containerView.transform = CGAffineTransform.identity
                    var startFrame = finalContainerFrame
                    startFrame.origin.x = -1 * finalContainerFrame.width
                    self.containerView.frame = startFrame

                    UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10.0, options: [], animations: {
                        self.containerView.frame = finalContainerFrame
                    }, completion: completionBlock)
                    break
                case .bounceInFromRight:
                    self.containerView.alpha = 1.0
                    self.containerView.transform = CGAffineTransform.identity
                    var startFrame = finalContainerFrame
                    startFrame.origin.x = self.bounds.width
                    self.containerView.frame = startFrame

                    UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10.0, options: [], animations: {
                        self.containerView.frame = finalContainerFrame
                    }, completion: completionBlock)
                    break
                default:
                    break
                }
            }
        }
    }

    private func updateForInterfaceOrientation() {
#if !os(tvOS)
        let orientation = UIApplication.shared.statusBarOrientation

        var angle: CGFloat = 0.0
        switch orientation {
        case .portraitUpsideDown:
            angle = CGFloat(M_PI)
        case .landscapeLeft:
            angle = CGFloat(-M_PI / 2.0)
            break
        case .landscapeRight:
            angle = CGFloat(M_PI / 2.0)
            break
        default:
            // Portrait and unknown
            angle = CGFloat(0.0)
        }

        transform = CGAffineTransform(rotationAngle: angle)
        frame = window!.bounds
#endif
    }

    //MARK: - Notification Handler
#if !os(tvOS)

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

#endif

    //MARK: - Keyboard notification handlers
#if !os(tvOS)

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

#endif
}

//MARK: - Extension

extension UIView {
    func forEachPopupDoBlock(block: @escaping (PopupView) -> ()) {
        self.subviews.forEach { subview in
            if let popupView = subview as? PopupView {
                block(popupView)
            } else {
                subview.forEachPopupDoBlock(block: block)
            }
        }
    }

    func dismissPresentingPopupView() {
        // Iterate over superviews until you find a PopupView and dismiss it, then gtfo
        var view: UIView? = self
        while let v = view {
            if let v = v as? PopupView {
                v.dismiss(animated: true)
                break
            }
            view = v.superview
        }
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
