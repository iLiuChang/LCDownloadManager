# LCDownloadManager
![效果](https://github.com/LiuChang712/LCDownloadManager/blob/master/DemoSwift/DemoSwift/Download.gif)

####使用
```Swift
    let sd = LCSwiftDownload.sharedInstance
    sd.downloadData(url, tag: Tag1, resume: button.selected, progerss: { (progerssValue) in

    // Todo...

    }) { (state) in

    // Todo...

    }
```
