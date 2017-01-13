//
//  PopupView.swift
//  PopupKit
//
//  Created by Ryne Cheow on 11/1/17.
//
//

import UIKit

//MARK: - Protocol

public protocol PopupViewDelegate: class {
    func willStartShowing(popUpView: PopupView)

    func didFinishShowing(popUpView: PopupView)

    func willStartDismissing(popUpView: PopupView)

    func didFinishDismissing(popUpView: PopupView)
}

open class PopupView: UIView {
    //MARK: - Enums

    /// Controls how the popup will be presented.

    @objc(PopupViewShowType)
    public enum ShowType: Int {
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

    @objc(PopupViewDismissType)
    public enum DismissType: Int {
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

    }

    /// Controls where the popup will come to rest horizontally.

    @objc(PopupViewHorizontalLayout)
    public enum HorizontalLayout: Int {
        case left
        case leftOfCenter
        case center
        case rightOfCenter
        case right
    }

    /// Controls where the popup will come to rest vertically.

    @objc(PopupViewVerticalLayout)
    public enum VerticalLayout: Int {
        case top
        case aboveCenter
        case center
        case belowCenter
        case bottom
    }

    @objc(PopupViewMaskType)
    public enum MaskType: Int {
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

    private struct PresentParameter {
        var view: UIView?
        var duration: TimeInterval
        var animationCenter: CGPoint?
        var layout: Layout

        init(view: UIView? = nil, duration: TimeInterval = 0.0, animationCenter: CGPoint? = nil, layout: Layout = .center) {
            self.view = view
            self.duration = duration
            self.animationCenter = animationCenter
            self.layout = layout
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

    internal let containerView: UIView

    internal var keyboardRect:CGRect = .zero

    private let backgroundView: UIView

    private var isBeingPresented = false

    private var isPresenting = false

    private var isBeingDismissed = false

    private var task: DispatchWorkItem?

    private var canPresentPopup: Bool {
        return !(isBeingPresented || isBeingDismissed || isPresenting)
    }

    private var canDismissPopup: Bool {
        return isPresenting && !isBeingDismissed
    }

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
        backgroundColor = .clear
        alpha = 0
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        autoresizesSubviews = true

        backgroundView.backgroundColor = .clear
        backgroundView.isUserInteractionEnabled = false
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.frame = bounds

        containerView.autoresizesSubviews = false
        containerView.isUserInteractionEnabled = true
        containerView.backgroundColor = .clear

        addSubview(backgroundView)
        addSubview(containerView)

#if !os(tvOS)
        // Register for Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(PopupView.didChangeStatusBarOrientation(notification:)), name: .UIDeviceOrientationDidChange, object: nil)
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
        task?.cancel()
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
                dismiss(animated: true)
            }

            // If no mask, then return nil so touch passes through to underlying views.
            guard maskType != .none else {
                return nil
            }

        } else {
            // If view is within containerView and contentTouch flag set, then try to hide.
            if safeHitView.isDescendant(of: containerView) && shouldDismissOnContentTouch {
                dismiss(animated: true)
            }
        }

        return hitView
    }

    //MARK: - Public methods

    /// Dismisses all the popups in the app. Use as a fail-safe for cleaning up.
    public static func dismissAll() {
        func recursivelyDismiss(view: UIView) {
            for subview in view.subviews {
                if subview is PopupView {
                    (subview as! PopupView).dismiss(animated: false)
                    break
                }
                recursivelyDismiss(view: subview)
            }
        }

        for window in UIApplication.shared.windows {
            recursivelyDismiss(view: window)
        }

    }

    @objc(presentWithHorizontalLayout: verticalLayout:inView:duration:)
    public func present(withHorizontalLayout horizontal: HorizontalLayout, verticalLayout: VerticalLayout, in view: UIView? = nil, duration: TimeInterval = 0.0) {
        present(with: Layout.custom(horizontal: horizontal, vertical: verticalLayout), in: view, duration: duration)
    }

    /// Show with specified layout, optionally in specific view, and dismiss after duration.
    public func present(with layout: Layout = .center, in view: UIView? = nil, duration: TimeInterval = 0.0) {
        var parameter = PresentParameter(duration: duration, layout: layout)

        if let view = view {
            parameter.view = view
        }

        present(with: parameter)
    }

    /// Show centered at point in view's coordinate system, then dismiss after duration.
    public func present(at center: CGPoint, in view: UIView, with duration: TimeInterval = 0.0) {
        let parameter = PresentParameter(view: view, duration: duration, animationCenter: center)

        present(with: parameter)
    }

    public func dismiss(animated: Bool = true) {

        guard canDismissPopup else {
            return
        }

        isBeingPresented = false
        isPresenting = false
        isBeingDismissed = true

        task?.cancel()

        delegate?.willStartDismissing(popUpView: self)

        DispatchQueue.main.async {
            [weak self] in
            guard let `self` = self else {
                return
            }
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
                self.isBeingPresented = false
                self.isPresenting = false
                self.isBeingDismissed = false

                self.delegate?.didFinishDismissing(popUpView: self)
            }

            guard animated && self.dismissType != .none else {
                self.containerView.alpha = 0.0
                completionClosure(true)
                return
            }
            
            self.dismissType.animate(with: self, containerFrame: nil, completionClosure: completionClosure)
        }

    }
    
    private func present(with parameter: PresentParameter) {
        guard canPresentPopup else {
            return
        }

        isBeingPresented = true
        isPresenting = false
        isBeingDismissed = false

        delegate?.willStartShowing(popUpView: self)

        DispatchQueue.main.async {
            // Prepare by adding to the top window.
            var destView: UIView?
            if self.superview == nil {
                destView = parameter.view
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
            case .none:
                UIView.animate(withDuration: animationDurationStandard, delay: 0.0, options: [.curveLinear], animations: backgroundAnimationBlock, completion: nil)
            case .clear:
                self.backgroundView.backgroundColor = .clear
            case .lightBlur:
                let blurEffect = UIBlurEffect(style: .light)
                let visualBlur = UIVisualEffectView(effect: blurEffect)
                visualBlur.frame = self.backgroundView.frame
                visualBlur.contentView.addSubview(self.backgroundView)
                self.insertSubview(visualBlur, belowSubview: self.containerView)
            case .darkBlur:
                let blurEffect = UIBlurEffect(style: .dark)
                let visualBlur = UIVisualEffectView(effect: blurEffect)
                visualBlur.frame = self.backgroundView.frame
                visualBlur.contentView.addSubview(self.backgroundView)
                self.insertSubview(visualBlur, belowSubview: self.containerView)
            }

            // Determine duration. Default to 0 if none provided.
            let duration = parameter.duration

            // Setup completion block
            let completionBlock: (Bool) -> () = {
                [weak self] finished in
                guard let `self` = self else {
                    return
                }
                self.isBeingPresented = false
                self.isPresenting = true
                self.isBeingDismissed = false

                self.delegate?.didFinishShowing(popUpView: self)

                // Set to hide after duration if greater than zero.
                if duration > 0.0 {
                    self.task = DispatchWorkItem { [weak self] in self?.dismiss() }
                    guard let task = self.task else {
                        return
                    }
                    // execute task in 2 seconds
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration, execute: task)
                }
            }

            // Add contentView to container
            if self.containerView != self.contentView.superview {
                self.containerView.addSubview(self.contentView)
            }

            // Re-layout (this is needed if the contentView is using autoLayout)
            self.contentView.layoutIfNeeded()

            // Size container to match contentView
            var containerFrame = self.containerView.frame
            containerFrame.size = self.contentView.frame.size
            self.containerView.frame = containerFrame
            // Position contentView to fill it
            var contentViewFrame = self.contentView.frame
            contentViewFrame.origin = .zero
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
            let centerValue = parameter.animationCenter
            if let centerValue = centerValue {

                var centerInSelf = centerValue

                if let destView = destView {
                    centerInSelf = self.convert(centerValue, from: destView)
                }

                finalContainerFrame.origin.x = centerInSelf.x - finalContainerFrame.width / 2.0
                finalContainerFrame.origin.y = centerInSelf.y - finalContainerFrame.height / 2.0
                containerAutoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleTopMargin]
            } else {
                let layout = parameter.layout

                // Horizontal
                
                finalContainerFrame.origin.x = layout.horizontal.originValue(with: self, rect: containerFrame)
                
                containerAutoresizingMask = layout.horizontal.autoresizingMask(with: containerAutoresizingMask)

                // Vertical
                
                finalContainerFrame.origin.y = layout.vertical.originValue(with: self, rect: containerFrame)
                
                containerAutoresizingMask = layout.vertical.autoresizingMask(with: containerAutoresizingMask)

                self.containerView.autoresizingMask = containerAutoresizingMask

                guard self.showType != .none else {
                    self.containerView.alpha = 1.0
                    self.containerView.transform = CGAffineTransform.identity
                    self.containerView.frame = finalContainerFrame
                    completionBlock(true)
                    return
                }

                // Animate content if needed
                self.showType.animate(with: self, containerFrame: finalContainerFrame, completionClosure: completionBlock)
            }
        }
    }

    internal func updateForInterfaceOrientation() {
#if !os(tvOS)
        let orientation = UIDevice.current.orientation

        var angle: CGFloat = 0.0
        switch orientation {
        case .portraitUpsideDown:
            angle = .pi
        case .landscapeLeft:
            angle = .pi / -2
        case .landscapeRight:
            angle = .pi / 2
        default:
            // Portrait and unknown
            angle = 0.0
        }

        transform = CGAffineTransform(rotationAngle: angle)
        frame = window!.bounds
#endif
    }


}

//MARK: - Extension

public extension UIView {
    @objc(forEachPopupDoBlock:)
    func forEachPopup(perform closure: @escaping (PopupView) -> ()) {
        self.subviews.forEach { subview in
            if let popupView = subview as? PopupView {
                closure(popupView)
            } else {
                subview.forEachPopup(perform: closure)
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
