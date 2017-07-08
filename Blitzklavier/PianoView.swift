//
//  PianoView.swift
//  Blitzklavier
//
//  Created by Jože Ws on 8/29/16.
//  Copyright © 2016 JožeWs. All rights reserved.
//

import UIKit

let firstWhiteKey = 7*3 // C3
let lastWhiteKey = 7*8 + 1 // C8

class PianoView: UIView {
    
    // MARK:- LETS
    
    let maxWhiteKeysCount = lastWhiteKey - firstWhiteKey
    let minWhiteKeysCount = 10
    let defaultWhiteOriginKey = 7*3
    
    let fontName = "HelveticaNeue"
    let lineWidth: CGFloat = 1.0
    
    // MARK:- VARS
    
    var whiteKeysCount = 15 // visible white keys
    var whiteOriginKey = 7*3 // C3
    
    var whiteKeyWidth: CGFloat {
        return frame.width/CGFloat(whiteKeysCount)
    }
    
    var whiteKeyHeight: CGFloat {
        return whiteKeyWidth*5
    }
    
    var blackKeyWidth: CGFloat {
        return whiteKeyWidth*0.58
    }
    
    var blackKeyHeight: CGFloat {
        return whiteKeyHeight*2/3
    }
    
    // MARK:- MODEL
    
    var touchedKeys = [UITouch : Key]()
    
    // MARK:- GESTURES
    
    var panGesture: UIPanGestureRecognizer?
    var pinchGesture: UIPinchGestureRecognizer?
    
    // MARK:- INIT
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        backgroundColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1.0)
        isMultipleTouchEnabled = true
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(panHandler(panGesture:)))
        addGestureRecognizer(panGesture!)
        
        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchHandler(pinchGesture:)))
        addGestureRecognizer(pinchGesture!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- VIEW DRAW

    override func draw(_ rect: CGRect) {
        
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
         // TODO: set proportional to zoom value
        
        ctx.setLineWidth(lineWidth)
        ctx.setStrokeColor(UIColor.black.cgColor)
        ctx.setFillColor(UIColor.black.cgColor)
        ctx.setBlendMode(.normal)
        
        var x: CGFloat = 0
        var key = whiteOriginKey
        
        while x < frame.width {
            
            let whiteKeyIdx = key % 7
            
            // draw leftmost black key if applies
            if x == 0 && (whiteKeyIdx == 1 || whiteKeyIdx == 2 || whiteKeyIdx == 4 || whiteKeyIdx == 5 || whiteKeyIdx == 6) {
                let blackKeyRect = CGRect(x: x - blackKeyWidth/2, y: frame.height - whiteKeyHeight, width: blackKeyWidth, height: blackKeyHeight)
                ctx.fill(blackKeyRect)
            }
            
            // draw white key
            let whiteKeyRect =  CGRect(x: x, y: frame.height - whiteKeyHeight, width: whiteKeyWidth, height: whiteKeyHeight)
            ctx.stroke(whiteKeyRect)
            
            // draw C print
            if key % 7 == 0 {
                let label = NSString(string: "C\(Int(key/7))")
                let fontSize: CGFloat = whiteKeyWidth/3
                let bottomMargin: CGFloat = whiteKeyWidth/4
                let labelRect = CGRect(x: x, y: frame.height - fontSize - bottomMargin, width: whiteKeyWidth, height: fontSize)
                let style = NSMutableParagraphStyle()
                style.alignment = .center
                label.draw(in: labelRect, withAttributes: [NSAttributedStringKey.font : UIFont(name: fontName, size: fontSize)!, NSAttributedStringKey.paragraphStyle : style])
            }
            
            // draw black key if next note isn't E or B
            if whiteKeyIdx != 2 && whiteKeyIdx != 6 {
                let blackKeyRect = CGRect(x: x + whiteKeyWidth - blackKeyWidth/2, y: frame.height - whiteKeyHeight, width: blackKeyWidth, height: blackKeyHeight)
                ctx.fill(blackKeyRect)
            }
            
            // update values: key, x
            key += 1
            x += whiteKeyWidth
        }
        
        for touchedKey in touchedKeys {
            ctx.setFillColor(UIColor.lightGray.cgColor)
            let key = touchedKey.value
            let frame = frameOfKey(key)
            // fill entire black frame
            guard !touchedKey.value.isBlack else {
                ctx.fill(frame)
                continue
            }
            // fill frame by removing black overlapping
            let lowerFrame = CGRect(x: frame.origin.x, y: frame.origin.y + blackKeyHeight, width: frame.width, height: frame.height - blackKeyHeight)
            ctx.fill(lowerFrame)
            if key.hasBlackKeyOnRight && key.hasBlackKeyOnLeft {
                let upperFrame = CGRect(x: frame.origin.x + blackKeyWidth/2 - lineWidth, y: frame.origin.y, width: frame.width - blackKeyWidth + lineWidth*2, height: blackKeyHeight + 1)
                ctx.fill(upperFrame)
            }
            else if key.hasBlackKeyOnRight {
                let upperFrame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width - blackKeyWidth/2 + lineWidth, height: blackKeyHeight + 1)
                ctx.fill(upperFrame)
            }
            else if key.hasBlackKeyOnLeft {
                let upperFrame = CGRect(x: frame.origin.x + blackKeyWidth/2 - lineWidth, y: frame.origin.y, width: frame.width - blackKeyWidth/2 + lineWidth, height: blackKeyHeight + 1)
                ctx.fill(upperFrame)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            guard let touchedKey = keyAtPosition(touch.location(in: self)) else { continue }
            touchedKeys[touch] = touchedKey
        }
        setNeedsDisplay() // redraws
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            guard let newTouchedKey = keyAtPosition(touch.location(in: self)) else {
                touchedKeys.removeValue(forKey: touch)
                continue
            }
            guard let previousTouchedKey = touchedKeys[touch] else {
                continue
            }
            if newTouchedKey != previousTouchedKey {
                touchedKeys[touch] = newTouchedKey
                setNeedsDisplay() // redraws
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            touchedKeys.removeValue(forKey: touch)
        }
        setNeedsDisplay() // redraws
    }
    
    // MARK:- GESTURE HANDLERS (PINCH & PAN)
    
    @objc func panHandler(panGesture: UIPanGestureRecognizer) {
        
        let xTrans = panGesture.translation(in: self).x
        
        // return if lower or upper limit has been reached
        
        if (xTrans > 0 && whiteOriginKey == firstWhiteKey) || (xTrans < 0 && whiteOriginKey + whiteKeysCount == lastWhiteKey) {
            return
        }
        
        // not enough translation
        if abs(xTrans) < whiteKeyWidth {
            return
        }
        
        whiteOriginKey += xTrans < 0 ? 1 : -1 // updates origin
        panGesture.setTranslation(CGPoint.zero, in: self)
        setNeedsDisplay() // redraws
    }
    
    @objc func pinchHandler(pinchGesture: UIPinchGestureRecognizer) {
        
        let scale = pinchGesture.scale
        let normalizedScale = 1.0 + (scale - 1.0)/4 // reduces effect of pinch
        
        let newKeysCount = Int(CGFloat(whiteKeysCount)*normalizedScale)
        let newOriginKey = whiteOriginKey + (whiteKeysCount - newKeysCount)/3
        
        if newKeysCount >= lastWhiteKey - firstWhiteKey {
            whiteOriginKey = firstWhiteKey
            whiteKeysCount = maxWhiteKeysCount
        }
        else if newKeysCount <= minWhiteKeysCount {
            whiteOriginKey = whiteOriginKey + (whiteKeysCount - minWhiteKeysCount)/2
            whiteKeysCount = minWhiteKeysCount
        }
        else {
            whiteOriginKey = newOriginKey // updates origin before keysCount
            whiteKeysCount = newKeysCount // scales
        }
        setNeedsDisplay() // redraws
    }
    
    // MARK:- UTILITIES
    
    func frameOfKey(_ key: Key) -> CGRect {
        
        let originKey = Key(whiteKey: whiteOriginKey)
        let distance = CGFloat(Key.whiteDistance(key0: originKey, key1: key))
        
        let x = distance*whiteKeyWidth + (key.isBlack ? (whiteKeyWidth - blackKeyWidth/2) : lineWidth)
        let y = frame.height - whiteKeyHeight
        
        let width = key.isBlack ? blackKeyWidth : (whiteKeyWidth - lineWidth*2)
        let height = key.isBlack ? blackKeyHeight : whiteKeyHeight
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    /// Predicts key user aimed to touch
    ///
    /// - Parameter position: Position of touch
    /// - Returns: Key touched or nil
    func keyAtPosition(_ position: CGPoint) -> Key? {
        
        let touchedPiano = position.y > (frame.height - whiteKeyHeight)
        
        guard touchedPiano else { return nil }
        
        // upper part of the piano is intended for black keys
        let touchedBottom = position.y > (frame.height - whiteKeyHeight + blackKeyHeight)
        let whiteKeyPosition = Int(position.x/whiteKeyWidth)
        
        if touchedBottom {
            return Key(whiteKey: whiteOriginKey + whiteKeyPosition)
        }
        
        // check if black key was aimed
        let blackKeyPosition = Int(round(position.x/whiteKeyWidth))
        let whiteKeyIdx = (whiteOriginKey + blackKeyPosition - 1) % 7
        
        // no black key in this position
        if whiteKeyIdx == 2 || whiteKeyIdx == 6 {
            return Key(whiteKey: whiteOriginKey + whiteKeyPosition)
        }
        
        return Key(whiteKey: whiteOriginKey + blackKeyPosition - 1, sharp: true)
    }
}






