//
//  LCSwiftDownload.swift
//  LCDownloadDemo
//
//  Created by 刘畅 on 16/6/24.
//  Copyright © 2016年 ifdoo. All rights reserved.
//

import UIKit

class LCSwiftDownload: NSObject , URLSessionDataDelegate {

   
    private lazy var downloadDic: [String: LCDownload] = {
        return [:]
    }()
 
    
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
    func downloadData(url: String, tag: Int, resume: Bool, progerss: ((Float) -> Void)?, state: ((LCDownloadState) -> Void)?) {
        
        let fileLength = getFileDataDownloadedLength(tag: tag)
        let allLength = getAllLength(tag: tag)
        if fileLength > 0 && fileLength == allLength {
            state?(.Completed)
            progerss?(1.0)
            return
        }
        let tagStr = String(tag)
        if let download = downloadDic[tagStr] {
            let dataTask = download.dataTask
            if resume {
                dataTask?.resume()
                download.stateBlock?(.Running)
            }else {
                dataTask?.suspend()
                download.stateBlock?(.Suspended)
            }
        }else {
            var request = URLRequest(url: URL(string: url)!)
            
            let session = initSession()

            request.setValue("bytes=\(fileLength)-", forHTTPHeaderField: "Range")
            let dataTask = session.dataTask(with: request)
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
//    func state(tag: Int) -> LCDownloadState {
//        if let download = downloadDic[String(tag)] {
//            download.stateBlock = { (state: LCDownloadState) in
//                return state
//            }
//        }
//        return .Failed
//    }
    
    /**
     获取下载的数据
     
     - parameter tag: 唯一标识
     */
    func getDownloadedData(tag: Int) -> NSData? {
        return getFileDownloadedData(tag: tag)
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
            download.stateBlock?(.Suspended)
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
            download.stateBlock?(.Canceled)
        }
    }
    
    /**
     获取总大小
     
     - parameter tag: 唯一标识
     */
    func getAllLength(tag: Int) -> Int {
        let dic = getFileAllLengthDic()
        let key = initFileAllLengthKey(tag: tag)
        if  let str = dic?.value(forKey: key) as? String {
            return Int(str)!
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
        let downloadedLength = getFileDataDownloadedLength(tag: tag)
        let allLength = getAllLength(tag: tag)
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
        let path = initFileDataCachePath(tag: tag)
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            do {
                try fileManager.removeItem(atPath: path)
            }catch {
                print(error)
            }
        }
        removeAllLength(tag: tag)
        
        if let download = downloadDic[String(tag)] {
            download.dataTask?.cancel()
            download.stateBlock?(.Canceled)
            download.outputStream?.close()
            download.outputStream = nil
            downloadDic.removeValue(forKey: String(tag))
        }
    }
    
    /**
     清空
     */
    func removeAllFileDownloadedData() {
        let path = initCachDirectoryPath()
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(atPath: path)
        }catch {
            print(error)
        }
        for str in downloadDic.keys {
            if let download = downloadDic[str] {
                download.dataTask?.cancel()
                download.stateBlock?(.Canceled)
                download.outputStream?.close()
                download.outputStream = nil
                downloadDic.removeValue(forKey: str)
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
        var path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last
        path = path! + "/LCDownloadCache"
        let fileManager = FileManager.default
        do {
            try fileManager.createDirectory(atPath: path!, withIntermediateDirectories: true, attributes: nil)
        }catch {
            print(error)
        }
        return path!
    }
    
    // 创建文件
    func initFileDataCachePath(tag: Int) -> String {
        let fileName = initFileDataName(tag: tag)
        let cache = initCachDirectoryPath()
        let path = cache + "/" + fileName
        return path
    }
    
    // 创建plist文件
    func initFileAllLengthPlist() {
        
        let path = getFileAllLengthPath()
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: path) {
            fileManager.createFile(atPath: path, contents: nil, attributes: nil)
            let dic = NSMutableDictionary()
            dic.write(toFile: path, atomically: true)
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
        let data = getFileDownloadedData(tag: tag)
        if data == nil {
            return 0
        }
        return data!.length
    }
    
    func initSession() -> URLSession {

        let configuration = URLSessionConfiguration.background(withIdentifier: "com.liuchang.cn")
        let session = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session;
    }
    
    // 获取本地下载的数据
    func getFileDownloadedData(tag: Int) -> NSData? {
        let path = initFileDataCachePath(tag: tag)
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            return NSData(contentsOfFile: path)
        }
        return nil
    }
    
    // 储存总大小
    func setAllLength(length: Int64, WithTag tag: Int) {
        initFileAllLengthPlist()
        let key = initFileAllLengthKey(tag: tag)
        let path = getFileAllLengthPath()
        let dic = getFileAllLengthDic()
        dic?.setValue(String(length), forKey: key)
        dic?.write(toFile: path, atomically: true)
    }
  
    // 删除中大小
    func removeAllLength(tag: Int) {
         let path = getFileAllLengthPath()
        let dic = getFileAllLengthDic()
        let key = initFileAllLengthKey(tag: tag)
        dic?.removeObject(forKey: key)
        dic?.write(toFile: path, atomically: true)
    }
    
}
 extension LCSwiftDownload {
    // 收到响应
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        let response = response as! HTTPURLResponse
        let allLength = Int(response.expectedContentLength) + getFileDataDownloadedLength(tag: dataTask.taskIdentifier)
        setAllLength(length: Int64(allLength), WithTag: dataTask.taskIdentifier)
        if let download = downloadDic[String(dataTask.taskIdentifier)] {
            let path = initFileDataCachePath(tag: dataTask.taskIdentifier)
            print(path)
            download.outputStream = OutputStream.init(toFileAtPath: path, append: true)
            download.outputStream!.open()
            download.allLength = Int(allLength)
        }
        completionHandler(.allow)
    }
    
    // 获取data 会多次调用

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if let download = downloadDic[String(dataTask.taskIdentifier)] {
            let downloadedLength = getFileDataDownloadedLength(tag: dataTask.taskIdentifier)
            
            let dataMutablePointer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
            
            //Copies the bytes to the Mutable Pointer
            data.copyBytes(to: dataMutablePointer, count: data.count)
            
            //Cast to regular UnsafePointer
            let dataPointer = UnsafePointer<UInt8>(dataMutablePointer)
            
            //Your stream
            download.outputStream?.write(dataPointer, maxLength: data.count)
            let progress = Float(downloadedLength) / Float(download.allLength)
            download.stateBlock?(.Running)
            download.progressBlock?(progress)
        }
    }
    
    // 下载完成
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let download = downloadDic[String(task.taskIdentifier)] {
            download.stateBlock?(.Completed)
            download.progressBlock?(1.0)
            download.outputStream?.close()
            download.outputStream = nil
            downloadDic.removeValue(forKey: String(task.taskIdentifier))
            if error != nil {
                download.stateBlock?(.Failed)
            }
        }

    }
    
}
