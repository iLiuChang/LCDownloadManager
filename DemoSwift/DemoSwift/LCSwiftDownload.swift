//
//  LCSwiftDownload.swift
//  LCDownloadDemo
//
//  Created by 刘畅 on 16/6/24.
//  Copyright © 2016年 ifdoo. All rights reserved.
//

import UIKit

class LCSwiftDownload: NSObject , NSURLSessionDataDelegate {

   
    private lazy var downloadDic: [String: LCDownload] = {
        return [:]
    }()
 
  
    override init() {
        super.init()
        initFileAllLengthPlist()
    }
    
    private static var sDownload = LCSwiftDownload()
    class var sharedInstance: LCSwiftDownload {
        return sDownload
    }
    
 
    /**
     在点击事件中使用
     
     - parameter url:      url
     - parameter tag:      唯一标识
     - parameter resume:   是否开始下载
     - parameter progerss: 进度 可以为nil
     - parameter state:    状态 可以为nil
     */
    func downloadData(url: String, tag: Int, resume: Bool, progerss: ((progerssValue: Float) -> Void)?, state: ((state: LCDownloadState) -> Void)?) {
        
        let fileLength = getFileDataDownloadedLength(tag)
        let allLength = getAllLength(tag)
        if fileLength > 0 && fileLength == allLength {
            state?(state: .Completed)
            progerss?(progerssValue: 1.0)
            return
        }
        let tagStr = String(tag)
        if let download = downloadDic[tagStr] {
            let dataTask = download.dataTask
            if resume {
                dataTask?.resume()
                download.stateBlock?(state: .Running)
            }else {
                dataTask?.suspend()
                download.stateBlock?(state: .Suspended)
            }
        }else {
            let request = NSMutableURLRequest(URL: NSURL(string: url)!)
            let session = initSession()

            request.setValue("bytes=\(fileLength)-", forHTTPHeaderField: "Range")
            let dataTask = session.dataTaskWithRequest(request)
            dataTask.setValue(tag, forKey: "taskIdentifier")
          
            let download = LCDownload()
            download.dataTask = dataTask
            download.progressBlock = progerss
            download.stateBlock = state
            downloadDic[tagStr] = download
            if resume {
                dataTask.resume()
            }
        }
        
    }
    
    
    /**
     获取下载状态
     
     - parameter tag:   唯一标识
     */
    func state(tag: Int) -> LCDownloadState {
        if let download = downloadDic[String(tag)] {
            download.stateBlock = { (state: LCDownloadState) in
                return state
            }
        }
        return .Failed
    }
    
    /**
     获取下载的数据
     
     - parameter tag: 唯一标识
     */
    func getDownloadedData(tag: Int) -> NSData? {
        return getFileDownloadedData(tag)
    }
  
    
    /**
     开始
     必须有下载任务，否则无效
     - parameter tag: 唯一标识
     */
    func start(tag: Int) {
        if let download = downloadDic[String(tag)] {
            download.dataTask?.resume()
        }
    }
    
    /**
     暂停
     必须有下载任务，否则无效
     - parameter tag: 唯一标识
     */
    func suspend(tag: Int) {
        if let download = downloadDic[String(tag)] {
            download.dataTask?.suspend()
            download.stateBlock?(state: .Suspended)
        }
    }
    
    /**
     取消
     必须有下载任务，否则无效
     - parameter tag: 唯一标识
     */
    func cancel(tag: Int) {
        if let download = downloadDic[String(tag)] {
            download.dataTask?.cancel()
            download.stateBlock?(state: .Canceled)
        }
    }
    
    /**
     获取总大小
     
     - parameter tag: 唯一标识
     */
    func getAllLength(tag: Int) -> Int {
        let dic = getFileAllLengthDic()
        let key = initFileAllLengthKey(tag)
        if  let str = dic?.valueForKey(key) {
            return Int(String(str))!
        }
        return 0
    }
    
   
    /**
     获取进度
     
     - parameter tag:      唯一标识
     - parameter progress: 会调用多次，传空返回默认进度
     
     - returns: 返回进度
     */
    func getProgressValue(tag: Int) -> Float {
        let downloadedLength = getFileDataDownloadedLength(tag)
        let allLength = getAllLength(tag)
        if allLength == 0 {
            return 0
        }
        let progressScale = Float(downloadedLength) / Float(allLength)
        return progressScale
    }
    
    /**
     删除指定文件
     
     - parameter tag: 唯一标识
     */
    func removeFileDownloadedData(tag: Int) {
        let path = initFileDataCachePath(tag)
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(path) {
            do {
                try fileManager.removeItemAtPath(path)
            }catch {
                print(error)
            }
        }
        removeAllLength(tag)
        
        if let download = downloadDic[String(tag)] {
            download.dataTask?.cancel()
            download.outputStream?.close()
            download.outputStream = nil
            downloadDic.removeValueForKey(String(tag))
        }
    }
    
    /**
     清空
     */
    func removeAllFileDownloadedData() {
        let path = initCachDirectoryPath()
        let fileManager = NSFileManager.defaultManager()
        do {
            try fileManager.removeItemAtPath(path)
        }catch {
            print(error)
        }
        for str in downloadDic.keys {
            if let download = downloadDic[str] {
                download.dataTask?.cancel()
                download.outputStream?.close()
                download.outputStream = nil
                downloadDic.removeValueForKey(str)
            }
        }
    }
    
   
}

private extension LCSwiftDownload {
    // 创建文件名
    func initFileDataName(tag: Int) -> String {
        return "LCDownload\(tag)"
    }
    func initFileAllLengthKey(tag: Int) -> String {
        return "AllLength\(tag)"
    }
    
    // 创建文件夹
    func initCachDirectoryPath() -> String {
        var path = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).last
        path = path! + "/LCDownloadCache"
        let fileManager = NSFileManager.defaultManager()
        do {
            try fileManager.createDirectoryAtPath(path!, withIntermediateDirectories: true, attributes: nil)
        }catch {
            print(error)
        }
        return path!
    }
    
    // 创建文件
    func initFileDataCachePath(tag: Int) -> String {
        let fileName = initFileDataName(tag)
        let cache = initCachDirectoryPath()
        let path = cache + "/" + fileName
        return path
    }
    
    // 创建plist文件
    func initFileAllLengthPlist() {
        
        let path = getFileAllLengthPath()
        let fileManager = NSFileManager.defaultManager()
        if !fileManager.fileExistsAtPath(path) {
            fileManager.createFileAtPath(path, contents: nil, attributes: nil)
            let dic = NSMutableDictionary()
            dic.writeToFile(path, atomically: true)
        }
    }
    
    func getFileAllLengthPath() -> String{
        let cache = initCachDirectoryPath()
        let path = cache + "/AllLength.plist"
        return path
    }
    
    func getFileAllLengthDic() -> NSMutableDictionary? {
        let path = getFileAllLengthPath()
        let dic = NSMutableDictionary.init(contentsOfFile: path)
        return dic
    }
    
    // 获取已经下载的大小
    func getFileDataDownloadedLength(tag: Int) -> Int {
        let data = getFileDownloadedData(tag)
        if data == nil {
            return 0
        }
        return data!.length
    }
    
    func initSession() -> NSURLSession {
        return NSURLSession.init(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: NSOperationQueue.mainQueue())
    }
    
    // 获取本地下载的数据
    func getFileDownloadedData(tag: Int) -> NSData? {
        let path = initFileDataCachePath(tag)
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(path) {
            return NSData(contentsOfFile: path)
        }
        return nil
    }
    
    // 储存总大小
    func setAllLength(length: IntMax, WithTag tag: Int) {
        let key = initFileAllLengthKey(tag)
        let path = getFileAllLengthPath()
        let dic = getFileAllLengthDic()
        dic?.setValue(String(length), forKey: key)
        dic?.writeToFile(path, atomically: true)
    }
  
    // 删除中大小
    func removeAllLength(tag: Int) {
         let path = getFileAllLengthPath()
        let dic = getFileAllLengthDic()
        let key = initFileAllLengthKey(tag)
        dic?.removeObjectForKey(key)
        dic?.writeToFile(path, atomically: true)
    }
    
}
 extension LCSwiftDownload {
    // 收到响应
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        
        let response = response as! NSHTTPURLResponse
        let allLength = response.expectedContentLength + getFileDataDownloadedLength(dataTask.taskIdentifier)
        setAllLength(allLength, WithTag: dataTask.taskIdentifier)
        if let download = downloadDic[String(dataTask.taskIdentifier)] {
            let path = initFileDataCachePath(dataTask.taskIdentifier)
            print(path)
            download.outputStream = NSOutputStream.init(toFileAtPath: path, append: true)
            download.outputStream!.open()
            download.allLength = Int(allLength)
        }
        
        completionHandler(.Allow)

   
    }
    
    // 获取data 会多次调用
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        if let download = downloadDic[String(dataTask.taskIdentifier)] {
            let downloadedLength = getFileDataDownloadedLength(dataTask.taskIdentifier)
            download.outputStream!.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
            let progress = Float(downloadedLength) / Float(download.allLength)
            download.stateBlock?(state: .Running)
            download.progressBlock?(progress: progress)
        }
        
    }
    
    // 下载完成
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if let download = downloadDic[String(task.taskIdentifier)] {
            let cData = getDownloadedData(task.taskIdentifier)
            download.stateBlock?(state: .Completed)
            download.progressBlock?(progress: 1.0)
            download.outputStream?.close()
            download.outputStream = nil
            downloadDic.removeValueForKey(String(task.taskIdentifier))
            if error != nil {
                download.stateBlock?(state: .Failed)
            }
        }
       
    }
    
}