/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */


import UIKit

enum RingIndex : Int {
  case Inner  = 0
  case Middle = 1
  case Outer  = 2
}

public let RingCompletedNotification = "RingCompletedNotification"
public let AllRingsCompletedNotification = "AllRingsCompletedNotification"

@IBDesignable
public class ThreeRingView : UIView {
  
  private let rings : [RingIndex : RingLayer] = [.Inner : RingLayer(), .Middle : RingLayer(), .Outer : RingLayer()]
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    sharedInitialization()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    sharedInitialization()
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    drawLayers()
  }
  
  
  private func sharedInitialization() {
    backgroundColor = UIColor.blackColor()
    for (_, ring) in rings {
      layer.addSublayer(ring)
      ring.backgroundColor = UIColor.clearColor().CGColor
      ring.ringBackgroundColor = ringBackgroundColor.CGColor
      ring.ringWidth = ringWidth
    }
    
    // Set the default values
    for (color, (index, ring)) in zip([UIColor.hrPinkColor, UIColor.hrGreenColor, UIColor.hrBlueColor], rings) {
      setColorForRing(index, color: color)
      ring.value = 0.0
    }
  }
  
  private func drawLayers() {
    let size = min(bounds.width, bounds.height)
    let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
    for (index, ring) in rings {
      // Sort sizes
      let curSize = size - CGFloat(index.rawValue) * ( ringWidth + ringPadding ) * 2.0
      ring.bounds = CGRect(x: 0, y: 0, width: curSize, height: curSize)
      ring.position = center
    }
  }
  
  //: API Properties
  @IBInspectable
  public var ringWidth : CGFloat = 20.0 {
    didSet {
      drawLayers()
      for (_, ring) in rings {
        ring.ringWidth = ringWidth
      }
    }
  }
  @IBInspectable
  public var ringPadding : CGFloat = 1.0 {
    didSet {
      drawLayers()
    }
  }
  @IBInspectable
  public var ringBackgroundColor : UIColor = UIColor.darkGrayColor() {
    didSet {
      for (_, ring) in rings {
        ring.ringBackgroundColor = ringBackgroundColor.CGColor
      }
    }
  }
  
  var animationDuration : NSTimeInterval = 1.5
}

//: Values
extension ThreeRingView {
  @IBInspectable
  public var innerRingValue : CGFloat {
    get {
      return rings[.Inner]?.value ?? 0
    }
    set(newValue) {
      maybePostNotification(innerRingValue, new: newValue, current: .Inner)
      setValueOnRing(.Inner, value: newValue, animated: false)
    }
  }
  @IBInspectable
  public var middleRingValue : CGFloat {
    get {
      return rings[.Middle]?.value ?? 0
    }
    set(newValue) {
      maybePostNotification(middleRingValue, new: newValue, current: .Middle)
      setValueOnRing(.Middle, value: newValue, animated: false)
    }
  }
  @IBInspectable
  public var outerRingValue : CGFloat {
    get {
      return rings[.Outer]?.value ?? 0
    }
    set(newValue) {
      maybePostNotification(outerRingValue, new: newValue, current: .Outer)
      setValueOnRing(.Outer, value: newValue, animated: false)
    }
  }
  func setValueOnRing(ringIndex: RingIndex, value: CGFloat, animated: Bool = false) {
    CATransaction.begin()
    CATransaction.setAnimationDuration(animationDuration)
    rings[ringIndex]?.setValue(value, animated: animated)
    CATransaction.commit()
  }
  
  private func maybePostNotification(old: CGFloat, new: CGFloat, current: RingIndex) {
    if old < 1 && new >= 1 { //threshold crossed
      let allDone: Bool
      switch(current) {
      case .Inner:
        allDone = outerRingValue >= 1 && middleRingValue >= 1
      case .Middle:
        allDone = innerRingValue >= 1 && outerRingValue >= 1
      case .Outer:
        allDone = innerRingValue >= 1 && middleRingValue >= 1
      }
      if allDone {
        postAllRingsCompletedNotification()
      } else {
        postRingCompletedNotification()
      }
    }
  }
  
  private func postAllRingsCompletedNotification() {
    NSNotificationCenter.defaultCenter().postNotificationName(AllRingsCompletedNotification, object: self)
  }
  private func postRingCompletedNotification() {
    NSNotificationCenter.defaultCenter().postNotificationName(RingCompletedNotification, object: self)
  }
}

//: Colors
extension ThreeRingView {
  @IBInspectable
  public var innerRingColor : UIColor {
    get {
      return colorForRing(.Inner)
    }
    set(newColor) {
      setColorForRing(.Inner, color: newColor)
    }
  }
  @IBInspectable
  public var middleRingColor : UIColor {
    get {
      return UIColor.clearColor()
    }
    set(newColor) {
      setColorForRing(.Middle, color: newColor)
    }
  }
  @IBInspectable
  public var outerRingColor : UIColor {
    get {
      return UIColor.clearColor()
    }
    set(newColor) {
      setColorForRing(.Outer, color: newColor)
    }
  }
  
  private func colorForRing(index: RingIndex) -> UIColor {
    return UIColor(CGColor: rings[index]!.ringColors.0)
  }
  
  private func setColorForRing(index: RingIndex, color: UIColor) {
    rings[index]?.ringColors = (color.CGColor, color.darkerColor.CGColor)
  }
}
