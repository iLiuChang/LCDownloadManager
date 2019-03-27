//
//  ViewController.swift
//  LCDownloadDemo
//
//  Created by 刘畅 on 16/6/24.
//  Copyright © 2016年 ifdoo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    let Tag1 = 12334
    let Tag2 = 980
    let url = "http://118.31.132.13:8002/images/f/f3/CCP_REST_DEMO_Objective-C_v2.6r.zip"
    
    weak var pv1: UIProgressView!
    weak var pv2: UIProgressView!
    weak var label1: UILabel!
    weak var label2: UILabel!
    weak var button1: UIButton!
    weak var button2: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let button = UIButton()
        let sd = LCSwiftDownload.sharedInstance

        
       
        let p1 = sd.getProgressValue(tag: Tag1)
        let pv1 = UIProgressView()
        let label1 = UILabel()
        label1.text = String(format: "%.2f", p1)
        label1.frame = CGRect(x: 0, y: 50, width: 50, height: 50)
        label1.textColor = UIColor.black
        self.view.addSubview(label1)
        self.label1 = label1
        pv1.progress = Float(p1)
        pv1.frame = CGRect(x: 50, y: 70, width: 200, height: 10)
        pv1.progressTintColor = UIColor.blue
        self.view.addSubview(pv1)
        self.pv1 = pv1
        button.frame = CGRect(x: pv1.frame.maxX, y: 50, width: 50, height: 50)
        button.setTitleColor(UIColor.black, for: .normal)
        button.addTarget(self, action: #selector(self.click(button:)), for: .touchUpInside)
        button.setImage(UIImage(named: "start"), for: .normal)
        button.setImage(UIImage(named: "pauce"), for: .selected)
        self.view.addSubview(button)
        self.button1 = button
        
        let removeButton = UIButton()
        removeButton.frame = CGRect(x: button.frame.maxX, y: 50, width: 50, height: 50)
        removeButton.setTitleColor(UIColor.black, for: .normal)
        removeButton.addTarget(self, action: #selector(self.remove(button:)), for: .touchUpInside)
        removeButton.setImage(UIImage(named: "delete"), for: .normal)
        self.view.addSubview(removeButton)
       
        
        let p2 = sd.getProgressValue(tag: Tag2)
        
        let label2 = UILabel()
        label2.text = String(format: "%.2f", p2)
        label2.frame = CGRect(x: 0, y: 140, width: 50, height: 50)
        label2.textColor = UIColor.black
        self.view.addSubview(label2)
        self.label2 = label2
        
        let pv2 = UIProgressView()
        pv2.progress = Float(p2)
        pv2.progressTintColor = UIColor.blue
        pv2.frame = CGRect(x: 50, y: 160, width: 200, height: 10)
        self.view.addSubview(pv2)
        self.pv2 = pv2
        let button1 = UIButton()
        button1.frame = CGRect(x: pv1.frame.maxX, y: 140, width: 50, height: 50)
        button1.setTitleColor(UIColor.black, for: .normal)
        button1.addTarget(self, action: #selector(self.click1(button:)), for: .touchUpInside)
        button1.setImage(UIImage(named: "start"), for: .normal)
        button1.setImage(UIImage(named: "pauce"), for: .selected)
        self.view.addSubview(button1)
        self.button2 = button1
        let rbutton1 = UIButton()
        rbutton1.frame = CGRect(x: button1.frame.maxX, y: 140, width: 50, height: 50)
        rbutton1.setTitleColor(UIColor.black, for: .normal)
        rbutton1.addTarget(self, action: #selector(self.remove1(button:)), for: .touchUpInside)
        rbutton1.setImage(UIImage(named: "delete"), for: .normal)
        self.view.addSubview(rbutton1)
        
      
        
    }
    
    @objc func click(button: UIButton) {
        button.isSelected = !button.isSelected
    let sd = LCSwiftDownload.sharedInstance
        sd.downloadData(url: url, tag: Tag1, resume: button.isSelected, progerss: { (progerssValue) in
            DispatchQueue.main.async {
                self.label1.text = String(format: "%.2f", progerssValue)
                self.pv1.progress = progerssValue

            }
            }) { (state) in
                
        }
    
    }
    
    @objc func remove(button: UIButton) {
        pv1.progress = 0
        label1.text = "0.00"
        self.button1.isSelected = false
        LCSwiftDownload.sharedInstance.removeFileDownloadedData(tag: Tag1)
    }
    
    @objc func click1(button: UIButton) {
        button.isSelected = !button.isSelected
        let sd = LCSwiftDownload.sharedInstance
        sd.downloadData(url: url, tag: Tag2, resume: button.isSelected, progerss: { (progerssValue) in
            self.label2.text = String(format: "%.2f", progerssValue)
            self.pv2.progress = progerssValue
            }, state: nil)
      
    }
    
    @objc func remove1(button: UIButton) {
        pv2.progress = 0
        label2.text = "0.00"
        self.button2.isSelected = false 
        LCSwiftDownload.sharedInstance.removeFileDownloadedData(tag: Tag2)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

