//
//  Created by Anastasiya Gorban on 4/14/15.
//  Copyright (c) 2015 Yalantis. All rights reserved.
//
//  Licensed under the MIT license: http://opensource.org/licenses/MIT
//  Latest version can be found at https://github.com/Yalantis/PullToMakeSoup
//

import Foundation
import UIKit
import PullToRefresh

open class PullToKickster: PullToRefresh {
  
  public convenience init(at position: Position = .top) {
    let refreshView = Bundle(for: type(of: self)).loadNibNamed("KicksterLogoView", owner: nil, options: nil)!.first as! KicksterLogoView
    let extensionView = UIView()
    let animator =  KicksterLogoAnimator(refreshView: refreshView, extensionView: extensionView)
    //Removes big ass logo bug on app launch
    refreshView.alpha = 0
    self.init(refreshView: refreshView, animator: animator, height: refreshView.frame.size.height, position : position)
  }
}

class KicksterLogoView: UIView {
  @IBOutlet weak var extensionView: UIView!
  @IBOutlet weak var kicksterLogoImageView: UIImageView!
}

class KicksterLogoAnimator: NSObject, RefreshViewAnimator {
  
  let refreshView: KicksterLogoView
  let extensionView: UIView!
  let refreshViewHeight: CGFloat
  let animationDuration = 0.3
  
  var refreshViewConstraints: [NSLayoutConstraint] = []
  var kicksterLogoImageViewConstraints: [NSLayoutConstraint] = []
  
  var feedbackGenerator : UIImpactFeedbackGenerator? = nil
  var feedbackDidNotOccur: Bool!
  
  init(refreshView: KicksterLogoView, extensionView: UIView) {
    self.refreshView = refreshView
    self.extensionView = extensionView
    self.refreshViewHeight = refreshView.frame.size.height
  }
  
  public func animate(_ state: State) {
    switch state {
    case .initial:
      configureConstraints()
      initalLayout()
      
      feedbackGenerator = UIImpactFeedbackGenerator()
      feedbackDidNotOccur = true
      print("INITIALIZED")
    case .releasing(let progress):
      releasingAnimation(progress)
      
      if progress == 1.0  && feedbackDidNotOccur {
      feedbackGenerator?.impactOccurred()
      feedbackDidNotOccur = false
      }
      
      print("RELEASED")
    case .loading :
      startLoading()
      feedbackGenerator?.impactOccurred()
      print("LOADING")
    case .finished:
      finishing()
      feedbackGenerator = nil
      print("DONEZO")
    }
  }
  
  // MARK: - Animator States
  
  func initalLayout() {
    refreshView.center = CGPoint(x: refreshView.frame.size.width / 2, y: refreshView.frame.size.height - 200)
    
    refreshView.layer.removeAllAnimations()
    refreshView.kicksterLogoImageView.layer.removeAllAnimations()
    
    refreshView.layer.timeOffset = 0.0
    refreshView.kicksterLogoImageView.layer.timeOffset = 0.0
    
  }
  
  func releasingAnimation(_ progress: CGFloat) {
    
    self.refreshView.alpha = progress
    self.refreshView.kicksterLogoImageView.transform = CGAffineTransform(scaleX: progress * 1.5, y: progress * 1.5)
    
    func progressWithOffset(_ offset: Double, _ progress: Double) -> Double {
      return progress < offset ? 0 : (progress - offset) * 1/(1 - offset)
    }
  }
  
  func startLoading() {
    
//    refreshView.center = CGPoint(x: refreshView.frame.size.width / 2, y: refreshView.frame.size.height - 200)
    refreshView.kicksterLogoImageView.layer.timeOffset = animationDuration
    refreshView.layer.timeOffset = animationDuration
    
    UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: {
      self.refreshView.kicksterLogoImageView.transform = .identity
    }, completion: { completed in
      
      UIView.animate(withDuration: 1, delay: 0, options: UIViewAnimationOptions(), animations: {
        self.refreshView.alpha = 1
        self.refreshView.transform = CGAffineTransform(scaleX: 1, y: 1)
      }, completion: { completed in
        
        self.refreshView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.refreshView.center = CGPoint(x: self.refreshView.center.x, y: self.refreshView.center.y)
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 1
        animationGroup.repeatCount = .infinity
        
        let easeOut = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 1.25
        pulseAnimation.duration = 0.25
        pulseAnimation.autoreverses = true
        pulseAnimation.speed = 2.0
        pulseAnimation.timingFunction = easeOut
        pulseAnimation.repeatCount = 2
        
        animationGroup.animations = [pulseAnimation]
        
        let colorAnimation = CABasicAnimation(keyPath: "backgroundColor")
        colorAnimation.fillMode = kCAFillModeForwards
        colorAnimation.fromValue =  UIColor(red:0.90, green:0.04, blue:0.17, alpha:1.0).cgColor
        colorAnimation.autoreverses = true
        colorAnimation.repeatCount = .infinity
        colorAnimation.isRemovedOnCompletion = false
        colorAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        colorAnimation.speed = 1.0
        colorAnimation.duration = 2.0
        
        self.refreshView.layer.backgroundColor = UIColor(red:1.00, green:0.71, blue:0.76, alpha:1.0).cgColor
        self.refreshView.extensionView.layer.backgroundColor = UIColor(red:1.00, green:0.71, blue:0.76, alpha:1.0).cgColor
        
        self.refreshView.kicksterLogoImageView.layer.add(animationGroup, forKey: "pulse")
        self.refreshView.layer.add(colorAnimation, forKey: "Color")
        self.refreshView.extensionView.layer.add(colorAnimation, forKey: "ExtensionColor")
      })
      
    })
  }
  
  func finishing() {
    //Resets Animations
    self.refreshView.kicksterLogoImageView.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
    self.refreshView.layer.backgroundColor = UIColor(red:0.90, green:0.04, blue:0.17, alpha:1.0).cgColor
    self.refreshView.alpha = 0
    self.refreshView.extensionView.layer.backgroundColor = UIColor(red:0.90, green:0.04, blue:0.17, alpha:1.0).cgColor
  }
  
  //MARK: - Constraints
  
  func configureConstraints() {
    refreshViewConstraints = [
      refreshView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height.multiplied(by: 0.2)),
      refreshView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
    ]
    
    kicksterLogoImageViewConstraints = [
      refreshView.kicksterLogoImageView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height.multiplied(by: 0.1)),
      refreshView.kicksterLogoImageView.widthAnchor.constraint(equalTo: refreshView.kicksterLogoImageView.heightAnchor),
    ]
    
    let _ = [
      refreshViewConstraints,
      kicksterLogoImageViewConstraints,
		].map{ $0.map { $0.isActive = true } }
  }

}

