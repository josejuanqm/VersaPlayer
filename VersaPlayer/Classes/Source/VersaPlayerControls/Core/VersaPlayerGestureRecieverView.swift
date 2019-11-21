//
//  VersaPlayerGestureRecieverView.swift
//  VersaPlayerView Demo
//
//  Created by Jose Quintero on 10/11/18.
//  Copyright © 2018 Quasar. All rights reserved.
//

#if os(macOS)
import Cocoa
#else
import UIKit
#endif

#if os(macOS)

open class VersaPlayerGestureRecieverView: View {
    
    /// VersaPlayerGestureRecieverViewDelegate instance
    public weak var delegate: VersaPlayerGestureRecieverViewDelegate? = nil
    
    /// Single tap UITapGestureRecognizer
    public var tapGesture: NSClickGestureRecognizer? = nil
    
    /// Double tap UITapGestureRecognizer
    public var doubleTapGesture: NSClickGestureRecognizer? = nil
    
    /// UIPanGestureRecognizer
    public var panGesture: NSPanGestureRecognizer? = nil
    
    /// UIPinchGestureRecognizer
    public var pinchGesture: NSMagnificationGestureRecognizer? = nil
    
    /// Whether or not reciever view is ready
    public var ready: Bool = false
    
    /// Pan gesture initial point
    public var panGestureInitialPoint: CGPoint = CGPoint.zero
    
    open override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        translatesAutoresizingMaskIntoConstraints = false
        if let parent = superview {
            topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
            leftAnchor.constraint(equalTo: parent.leftAnchor).isActive = true
            rightAnchor.constraint(equalTo: parent.rightAnchor).isActive = true
            bottomAnchor.constraint(equalTo: parent.bottomAnchor).isActive = true
        }
        if !ready {
            prepare()
        }
    }
    
    /// Prepare the view gesture recognizers
    open func prepare() {
        ready = true
        tapGesture = NSClickGestureRecognizer(target: self, action: #selector(tapHandler(with:)))
        tapGesture?.numberOfClicksRequired = 1
        
        doubleTapGesture = NSClickGestureRecognizer(target: self, action: #selector(doubleTapHandler(with:)))
        doubleTapGesture?.numberOfClicksRequired = 2
        
        tapGesture?.shouldBeRequiredToFail(by: tapGesture!)
        
        pinchGesture = NSMagnificationGestureRecognizer(target: self, action: #selector(pinchHandler(with:)))
        panGesture = NSPanGestureRecognizer(target: self, action: #selector(panHandler(with:)))
        panGesture?.numberOfTouchesRequired = 1
        
        addGestureRecognizer(tapGesture!)
        addGestureRecognizer(doubleTapGesture!)
        addGestureRecognizer(panGesture!)
        addGestureRecognizer(pinchGesture!)
    }
    
    
    @objc open func tapHandler(with sender: NSClickGestureRecognizer) {
        delegate?.didTap(at: sender.location(in: self))
    }
    
    @objc open func doubleTapHandler(with sender: NSClickGestureRecognizer) {
        delegate?.didDoubleTap(at: sender.location(in: self))
    }
    
    @objc open func pinchHandler(with sender: NSMagnificationGestureRecognizer) {
        if sender.state == .ended {
            delegate?.didPinch(with: sender.magnification)
        }
    }
    
    @objc open func panHandler(with sender: NSPanGestureRecognizer) {
        if sender.state == .began {
            panGestureInitialPoint = sender.location(in: self)
        }
        delegate?.didPan(with: sender.translation(in: self), initially: panGestureInitialPoint)
    }
    
}

#elseif os(iOS)

open class VersaPlayerGestureRecieverView: UIView {
    
    /// VersaPlayerGestureRecieverViewDelegate instance
    public weak var delegate: VersaPlayerGestureRecieverViewDelegate? = nil
    
    /// Single tap UITapGestureRecognizer
    public var tapGesture: UITapGestureRecognizer? = nil
    
    /// Double tap UITapGestureRecognizer
    public var doubleTapGesture: UITapGestureRecognizer? = nil
    
    /// UIPanGestureRecognizer
    public var panGesture: UIPanGestureRecognizer? = nil
    
    /// UIPinchGestureRecognizer
    public var pinchGesture: UIPinchGestureRecognizer? = nil
    
    /// Whether or not reciever view is ready
    public var ready: Bool = false
    
    /// Pan gesture initial point
    public var panGestureInitialPoint: CGPoint = CGPoint.zero

    deinit {
      
    }

    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        translatesAutoresizingMaskIntoConstraints = false
        if let parent = superview {
            topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
            leftAnchor.constraint(equalTo: parent.leftAnchor).isActive = true
            rightAnchor.constraint(equalTo: parent.rightAnchor).isActive = true
            bottomAnchor.constraint(equalTo: parent.bottomAnchor).isActive = true
        }
        if !ready {
            prepare()
        }
    }
    
    /// Prepare the view gesture recognizers
    open func prepare() {
        ready = true
        isUserInteractionEnabled = true
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler(with:)))
        tapGesture?.numberOfTapsRequired = 1
        
        doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapHandler(with:)))
        doubleTapGesture?.numberOfTapsRequired = 2
        
        tapGesture?.require(toFail: doubleTapGesture!)
        
        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchHandler(with:)))
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(panHandler(with:)))
        panGesture?.minimumNumberOfTouches = 1
        
        addGestureRecognizer(tapGesture!)
        addGestureRecognizer(doubleTapGesture!)
        addGestureRecognizer(panGesture!)
        addGestureRecognizer(pinchGesture!)
    }
    
    
    @objc open func tapHandler(with sender: UITapGestureRecognizer) {
        delegate?.didTap(at: sender.location(in: self))
    }
    
    @objc open func doubleTapHandler(with sender: UITapGestureRecognizer) {
        delegate?.didDoubleTap(at: sender.location(in: self))
    }
    
    @objc open func pinchHandler(with sender: UIPinchGestureRecognizer) {
        if sender.state == .ended {
            delegate?.didPinch(with: sender.scale)
        }
    }
    
    @objc open func panHandler(with sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            panGestureInitialPoint = sender.location(in: self)
        }
        delegate?.didPan(with: sender.translation(in: self), initially: panGestureInitialPoint)
    }
    
}

#else

open class VersaPlayerGestureRecieverView: UIView {
    
    internal var handler: VersaPlayerView!
    
    /// VersaPlayerGestureRecieverViewDelegate instance
    public weak var delegate: VersaPlayerGestureRecieverViewDelegate? = nil
    
    /// UITapGestureRecognizer
    public var tapGesture: UITapGestureRecognizer? = nil
    
    /// UIPanGestureRecognizer
    public var swipeGestureUp: UISwipeGestureRecognizer? = nil
    public var swipeGestureDown: UISwipeGestureRecognizer? = nil
    public var swipeGestureLeft: UISwipeGestureRecognizer? = nil
    public var swipeGestureRight: UISwipeGestureRecognizer? = nil
    
    /// Whether or not reciever view is ready
    public var ready: Bool = false
    
    /// Should become focused
    public var shouldBecomeFocused: Bool = true
    
    private var initialSwipeLocation: CGPoint = .zero
    
    open override var canBecomeFocused: Bool {
        return shouldBecomeFocused
    }
    
    open override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        initialSwipeLocation = touches.first?.location(in: self) ?? .zero
    }
    
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        translatesAutoresizingMaskIntoConstraints = false
        if let parent = superview {
            topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
            leftAnchor.constraint(equalTo: parent.leftAnchor).isActive = true
            rightAnchor.constraint(equalTo: parent.rightAnchor).isActive = true
            bottomAnchor.constraint(equalTo: parent.bottomAnchor).isActive = true
        }
        if !ready {
            prepare()
        }
    }
    
    /// Prepare the view gesture recognizers
    public func prepare() {
        ready = true
        isUserInteractionEnabled = true
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler(with:)))
        tapGesture?.allowedPressTypes = [NSNumber(value: UIPress.PressType.menu.rawValue), NSNumber(value: UIPress.PressType.select.rawValue)]
        tapGesture?.numberOfTapsRequired = 1
        
        let playPause = UITapGestureRecognizer(target: self, action: #selector(togglePlayback))
        playPause.allowedPressTypes = [NSNumber(value: UIPress.PressType.playPause.rawValue)]
        playPause.numberOfTapsRequired = 1
        
        swipeGestureUp = UISwipeGestureRecognizer(target: self, action: #selector(swipeHandler(with:)))
        swipeGestureUp?.direction = UISwipeGestureRecognizer.Direction.up
        
        swipeGestureDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeHandler(with:)))
        swipeGestureDown?.direction = UISwipeGestureRecognizer.Direction.down
        
        swipeGestureLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeHandler(with:)))
        swipeGestureLeft?.direction = UISwipeGestureRecognizer.Direction.left
        
        swipeGestureRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeHandler(with:)))
        swipeGestureRight?.direction = UISwipeGestureRecognizer.Direction.right
        
        addGestureRecognizer(tapGesture!)
        addGestureRecognizer(playPause)
        addGestureRecognizer(swipeGestureUp!)
        addGestureRecognizer(swipeGestureDown!)
        addGestureRecognizer(swipeGestureLeft!)
        addGestureRecognizer(swipeGestureRight!)
    }
    
    @objc private func togglePlayback() {
        self.handler.togglePlayback()
    }
    
    @objc public func tapHandler(with sender: UITapGestureRecognizer) {
        delegate?.didTap(at: sender.location(in: self))
    }
    
    @objc public func swipeHandler(with sender: UISwipeGestureRecognizer) {
        let direction: UISwipeGestureRecognizer.Direction = sender.direction
        delegate?.didSwipe(with: direction)
    }
    
}

#endif
