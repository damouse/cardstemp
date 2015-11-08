//
//  LandingViewController.swift
//  FabAgainst
//
//  Created by Mickey Barboi on 9/29/15.
//  Copyright © 2015 paradrop. All rights reserved.
//

import UIKit
import Riffle
import Spring
import IHKeyboardAvoiding


class LandingViewController: UIViewController, RiffleDelegate {
    @IBOutlet weak var buttonLogin: UIButton!
    @IBOutlet weak var viewLogo: SpringView!
    @IBOutlet weak var viewButtons: SpringView!
    @IBOutlet weak var viewLogin: SpringView!
    
    @IBOutlet weak var textfieldUsername: UITextField!
    
    var app: RiffleAgent!
    var me: RiffleAgent!
    
    
    override func viewDidLoad() {
        Riffle.setFabric("ws://ubuntu@ec2-52-26-83-61.us-west-2.compute.amazonaws.com:8000/ws")
        IHKeyboardAvoiding.setAvoidingView(viewLogin)
    }
    
    override func viewWillAppear(animated: Bool) {
        textfieldUsername.layer.borderColor = UIColor.whiteColor().CGColor
        textfieldUsername.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
    }
   
    override func viewDidAppear(animated: Bool) {
        viewLogo.animate()
        viewLogin.animate()
    }

    
    // MARK: Core Logic
    func play() {
        app.call("pd.demo.cardsagainst/play", app.domain, handler: { (cards: [Card], players: [Player], state: String, roomName: String) in
            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("game") as! GameViewController
            
            // Temporary
            if roomName == "0" {
                return
            }
            
            controller.currentPlayer = players.filter { $0.domain == self.me.domain }[0]
            controller.currentPlayer.hand = cards
            controller.players = players
            controller.state = state
            
            controller.app = self.app
            controller.me = self.me
            controller.room = RiffleAgent(name: roomName, superdomain: self.app)
            
            // Present the controller with a transparent effect
            let effect = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
            effect.frame = controller.view.frame
            controller.view.insertSubview(effect, atIndex:0)
            controller.modalPresentationStyle = .OverFullScreen
            self.modalPresentationStyle = .CurrentContext
            
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }
    
    
    //MARK: Riffle Delegate
    func onJoin() {
        print("Session connected")
        
        // Animations
        viewLogin.animation = "zoomOut"
        viewLogin.animate()
        viewButtons.animation = "zoomIn"
        viewButtons.animate()
    }
    
    func onLeave() {
        print("Session disconnected")
    }
    
    
    // MARK: Actions
    @IBAction func login(sender: AnyObject) {
        textfieldUsername.resignFirstResponder()
        let name = textfieldUsername.text!
        
        app = RiffleAgent(domain: "xs.demo.damouse.exagainst")
        me = RiffleAgent(name: name, superdomain: app)
        me.delegate = self
        me.join()
    }
    
    @IBAction func playpg13(sender: AnyObject) {
        play()
    }
    
    @IBAction func playR(sender: AnyObject) {
        play()
    }
    
}