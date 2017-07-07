//
//  PianoView.swift
//  Blitzklavier
//
//  Created by Jože Ws on 8/29/16.
//  Copyright © 2016 JožeWs. All rights reserved.
//

import UIKit

let firstKey = 5*1 // C1
let lastKey = 7*8 + 1 // C8

let maxKeysCount = lastKey - firstKey
let minKeysCount = 15
let defaultOriginKey = 7*3

let fontName = "HelveticaNeue-Thin"

class PianoView: UIView {
    
    var keysCount = 15 // visible white keys
    var originKey = 7*3 // C3
    
    var whiteKeyWidth: CGFloat {
        return frame.width/CGFloat(keysCount)
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
    
    // MARK:- INIT
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        
        let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(self.panHandler(panGesture:)))
        addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer.init(target: self, action: #selector(self.pinchHandler(pinchGesture:)))
        addGestureRecognizer(pinchGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- GESTURE HANDLERS
    
    func tapHander(tapGesture: UITapGestureRecognizer) {
        
    }
    
    @objc func panHandler(panGesture: UIPanGestureRecognizer) {
        
        let xTrans = panGesture.translation(in: self).x
        
        // return if lower or upper limit has been reached
        
        if (xTrans > 0 && originKey == firstKey) || (xTrans < 0 && originKey + keysCount == lastKey) {
            return
        }

        // not enough translation
        if abs(xTrans) < whiteKeyWidth*2 {
            return
        }
        
        originKey += xTrans < 0 ? 1 : -1 // updates origin
        panGesture.setTranslation(CGPoint.zero, in: self)
        setNeedsDisplay() // redraws
    }

    @objc func pinchHandler(pinchGesture: UIPinchGestureRecognizer) {
    
        let scale = pinchGesture.scale
        let normalizedScale = 1.0 + (scale - 1.0)/2 // reduces effect of pinch
        
        let newKeysCount = Int(CGFloat(keysCount)*normalizedScale)
        let newOriginKey = originKey + (keysCount - newKeysCount)/3
        
        if newKeysCount >= lastKey - firstKey {
            originKey = firstKey
            keysCount = maxKeysCount
        }
        else if newKeysCount <= minKeysCount {
            originKey = originKey + (keysCount - minKeysCount)/2
            keysCount = minKeysCount
        }
        else {
            originKey = newOriginKey // updates origin before keysCount
            keysCount = newKeysCount // scales
        }
        setNeedsDisplay() // redraws
    }
    
    // MARK:- VIEW

    override func draw(_ rect: CGRect) {
        
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        ctx.setLineWidth(0.25)
        ctx.setStrokeColor(UIColor.black.cgColor)
        ctx.setFillColor(UIColor.black.cgColor)
        
        var x: CGFloat = 0
        var key = originKey
        
        while x < frame.width {
            
            let mod = key % 7

            // draw leftmost black key if applies
            if x == 0 && (mod == 1 || mod == 2 || mod == 4 || mod == 5 || mod == 6) {
                let blackKeyRect = CGRect.init(x: x - blackKeyWidth/2, y: frame.height - whiteKeyHeight, width: blackKeyWidth, height: blackKeyHeight)
                ctx.fill(blackKeyRect)
            }
            
            // draw white key
            let whiteKeyRect =  CGRect.init(x: x, y: frame.height - whiteKeyHeight, width: whiteKeyWidth, height: whiteKeyHeight)
            ctx.stroke(whiteKeyRect)
            
            // draw c4
            if key % 7 == 0 {
                
                let label = NSString.init(string: "C\(Int(key/7))")
                let fontSize: CGFloat = whiteKeyWidth/2
                let bottomMargin: CGFloat = whiteKeyWidth/4
                let labelRect = CGRect.init(x: x, y: frame.height - fontSize - bottomMargin, width: whiteKeyWidth, height: fontSize)
                let style = NSMutableParagraphStyle.init()
                style.alignment = .center
                label.draw(in: labelRect, withAttributes: [NSAttributedStringKey.font : UIFont.init(name: fontName, size: fontSize)!, NSAttributedStringKey.paragraphStyle : style])
            }
            
            // draw black key if next note isn't E or B
            if mod != 2 && mod != 6 {
                let blackKeyRect = CGRect.init(x: x + whiteKeyWidth*3/4, y: frame.height - whiteKeyHeight, width: blackKeyWidth, height: blackKeyHeight)
                ctx.fill(blackKeyRect)
            }
            
            // update values: key, x
            key += 1
            x += whiteKeyWidth
        }
    }
}

