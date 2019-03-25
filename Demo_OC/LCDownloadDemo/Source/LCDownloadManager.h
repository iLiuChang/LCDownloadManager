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

/**
 *  初始化
 *
 */
+ (LCDownloadManager *)sharedInstance;

/**
 *  添加下载任务
 *
 *  @param url           url
 *  @param resume        是否下载
 *  @param progressBlock 下载进度回调
 *  @param stateBlack    下载状态回调
 */
- (void)downloadDataWithURL:(NSString *)url resume:(BOOL)resume progress: (void(^)( CGFloat progress)) progressBlock state:(void(^)(LCDownloadState state))stateBlack;

/**
 *  删除本地数据
 *
 */
- (void)removeFileDataWithURL:(NSString *)url;

/**
 *  清空
 */
- (void)removeAllFileData;

/**
 *  总大小
 *
 *  @param tag 唯一标识
 */
//- (NSUInteger)allLengthWithTag:(NSUInteger)tag;

/**
 *  进度
 *
 *  @param tag 唯一标识
 */
- (CGFloat)progressWithURL:(NSString *)url;

/**
 *  开始
 *
 */
- (void)resumeWithURL:(NSString *)url;

/**
 *  暂停
 *
 */
- (void)suspendWithURL:(NSString *)url;

/**
 *  取消
 *
 */
- (void)cancelWithURL:(NSString *)url;

/**
 *  已经下载的本地数据
 *
 *  @param tag 唯一标识
 */
//- (NSData *)downloadedDataWithURL:(NSString *)url;
@end
