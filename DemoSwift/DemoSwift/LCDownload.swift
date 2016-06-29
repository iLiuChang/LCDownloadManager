//
//  LCDownload.swift
//  LCDownloadDemo
//
//  Created by 刘畅 on 16/6/24.
//  Copyright © 2016年 ifdoo. All rights reserved.
//

import UIKit
enum LCDownloadState {
    case Running    // 下载中
    case Suspended  // 暂停
    case Canceled  // 取消
    case Completed  // 下载完成
    case Failed     // 下载失败
}
class  LCDownload: NSObject {

    var dataTask: NSURLSessionDataTask?
    var outputStream: NSOutputStream?
    var fileHandle: NSFileHandle?
    var allLength: Int = 0
    var progressBlock: ((progress: CGFloat) -> Void)?
    var stateBlock: ((state: LCDownloadState) -> Void)?
}
