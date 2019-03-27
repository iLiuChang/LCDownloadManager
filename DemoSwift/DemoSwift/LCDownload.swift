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

    var dataTask: URLSessionDataTask?
    var outputStream: OutputStream?
    var allLength: Int = 0
    var progressBlock: ((Float) -> Void)?
    var stateBlock: ((LCDownloadState) -> Void)?
}
