//
//  LCDownloadManager.h
//  LCDownloadDemo
//
//  Created by LiuChang on 16-6-24.
//  Copyright (c) 2016年 LiuChang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LCDownload.h"
@interface LCDownloadManager : NSObject
+ (LCDownloadManager *)sharedInstance;
// 添加下载任务
- (void)downloadData:(NSString *)url WithTag:(NSUInteger)tag progress: (void(^)( CGFloat progress)) progressBlock state:(void(^)(LCDownloadState state))stateBlack;
// 删除下载的文件
- (void)removeFileData:(NSUInteger)tag;
// 清空
- (void)removeAllFileData;
// 总大小
- (NSUInteger)allLength:(NSUInteger)tag;
// 进度
- (CGFloat)progressValue:(NSUInteger)tag;
@end
