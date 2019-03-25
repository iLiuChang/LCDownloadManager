//
//  LCDownload.h
//  LCDownloadDemo
//
//  Created by LiuChang on 16-6-24.
//  Copyright (c) 2016年 LiuChang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef enum {
    LCDownloadStateRunning = 0,     /** 下载中 */
    LCDownloadStateSuspended,     /** 下载暂停 */
    LCDownloadStateCompleted,     /** 下载完成 */
    LCDownloadStateCanceled,     /** 取消下载 */
    LCDownloadStateFailed         /** 下载失败 */
}LCDownloadState;
@interface LCDownload : NSObject
@property (nonatomic, strong) NSOutputStream *stream;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, assign) long long allLength;
@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, copy) void(^progressBlock)( CGFloat progress);
@property (nonatomic, copy) void(^stateBlock)(LCDownloadState state);
@end
