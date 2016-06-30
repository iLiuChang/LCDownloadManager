//
//  ViewController.swift
//  LCDownloadDemo
//
//  Created by 刘畅 on 16/6/24.
//  Copyright © 2016年 ifdoo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    let Tag1 = 123
    let Tag2 = 980
    let url = "http://baobab.wdjcdn.com/1455782903700jy.mp4"
    
    weak var pv1: UIProgressView!
    weak var pv2: UIProgressView!
    weak var label1: UILabel!
    weak var label2: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let button = UIButton()
        let sd = LCSwiftDownload.sharedInstance

        
       
        let p1 = sd.getProgressValue(Tag1)
        let pv1 = UIProgressView()
        let label1 = UILabel()
        label1.text = String(format: "%.2f", p1)
        label1.frame = CGRectMake(0, 50, 50, 50)
        label1.textColor = UIColor.blackColor()
        self.view.addSubview(label1)
        self.label1 = label1
        pv1.progress = Float(p1)
        pv1.frame = CGRectMake(50, 70, 200, 10)
        pv1.progressTintColor = UIColor.blueColor()
        self.view.addSubview(pv1)
        self.pv1 = pv1
        button.frame = CGRectMake(pv1.frame.maxX, 50, 50, 50)
        button.setTitleColor(UIColor.blackColor(), forState: .Normal)
        button.addTarget(self, action: #selector(self.click(_:)), forControlEvents: .TouchUpInside)
        button.setImage(UIImage(named: "start"), forState: .Normal)
        button.setImage(UIImage(named: "pauce"), forState: .Selected)
        self.view.addSubview(button)
        
        let removeButton = UIButton()
        removeButton.frame = CGRectMake(button.frame.maxX, 50, 50, 50)
        removeButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        removeButton.addTarget(self, action: #selector(self.remove(_:)), forControlEvents: .TouchUpInside)
        removeButton.setImage(UIImage(named: "delete"), forState: .Normal)
        self.view.addSubview(removeButton)
       
        
        let p2 = sd.getProgressValue(Tag2)
        
        let label2 = UILabel()
        label2.text = String(format: "%.2f", p2)
        label2.frame = CGRectMake(0, 140, 50, 50)
        label2.textColor = UIColor.blackColor()
        self.view.addSubview(label2)
        self.label2 = label2
        
        let pv2 = UIProgressView()
        pv2.progress = Float(p2)
        pv2.progressTintColor = UIColor.blueColor()
        pv2.frame = CGRectMake(50, 160, 200, 10)
        self.view.addSubview(pv2)
        self.pv2 = pv2
        let button1 = UIButton()
        button1.frame = CGRectMake(pv1.frame.maxX, 140, 50, 50)
        button1.setTitleColor(UIColor.blackColor(), forState: .Normal)
        button1.addTarget(self, action: #selector(self.click1(_:)), forControlEvents: .TouchUpInside)
        button1.setImage(UIImage(named: "start"), forState: .Normal)
        button1.setImage(UIImage(named: "pauce"), forState: .Selected)
        self.view.addSubview(button1)
        
        let rbutton1 = UIButton()
        rbutton1.frame = CGRectMake(button1.frame.maxX, 140, 50, 50)
        rbutton1.setTitleColor(UIColor.blackColor(), forState: .Normal)
        rbutton1.addTarget(self, action: #selector(self.remove1(_:)), forControlEvents: .TouchUpInside)
        rbutton1.setImage(UIImage(named: "delete"), forState: .Normal)
        self.view.addSubview(rbutton1)
        
      
        
    }
    
    func click(button: UIButton) {
    button.selected = !button.selected
    let sd = LCSwiftDownload.sharedInstance
        sd.downloadData(url, tag: Tag1, resume: button.selected, progerss: { (progerssValue) in
            self.label1.text = String(format: "%.2f", progerssValue)
            self.pv1.progress = progerssValue
            }) { (state) in
                
        }
    
    }
    
    func remove(button: UIButton) {
        pv1.progress = 0
        label1.text = "0.00"
        LCSwiftDownload.sharedInstance.removeFileDownloadedData(Tag1)
    }
    
    func click1(button: UIButton) {
        button.selected = !button.selected
        let sd = LCSwiftDownload.sharedInstance
        sd.downloadData(url, tag: Tag2, resume: button.selected, progerss: { (progerssValue) in
            self.label2.text = String(format: "%.2f", progerssValue)
            self.pv2.progress = progerssValue
            }, state: nil)
      
    }
    
    func remove1(button: UIButton) {
        pv2.progress = 0
        label2.text = "0.00"
        LCSwiftDownload.sharedInstance.removeFileDownloadedData(Tag2)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

