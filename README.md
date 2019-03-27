# LCDownloadManager
![效果](https://github.com/LiuChang712/LCDownloadManager/blob/master/DemoSwift/DemoSwift/Download.gif)

#### 使用
```Swift

let sd = LCSwiftDownload.sharedInstance
sd.downloadData(url: url, tag: Tag1, resume: button.isSelected, progerss: { (progerssValue) in
DispatchQueue.main.async {
self.label1.text = String(format: "%.2f", progerssValue)
self.pv1.progress = progerssValue

}
}) { (state) in

}

```
