//
//  LCDownloadManager.m
//  LCDownloadDemo
//
//  Created by LiuChang on 16-6-24.
//  Copyright (c) 2016年 LiuChang. All rights reserved.
//

#import "LCDownloadManager.h"

@interface LCDownloadManager()<NSURLSessionTaskDelegate>

@property (nonatomic, strong) NSMutableDictionary *downloadDic;

@end
@implementation LCDownloadManager
static LCDownloadManager *_downloadManager;
+ (LCDownloadManager *)sharedInstance {
    if (!_downloadManager) {
        _downloadManager = [[self alloc]init];
    }
    return _downloadManager;
}


- (NSMutableDictionary *)downloadDic {
    if (!_downloadDic) {
        _downloadDic = [[NSMutableDictionary alloc]init];
    }
    return _downloadDic;
}

- (NSUInteger)allLength:(NSUInteger)tag {
    return [self getAllLength:tag];;
}


- (CGFloat)progressValue:(NSUInteger)tag {
    NSUInteger loadedLength = [self getFileDownloadedLength:tag];

    NSUInteger allLength = [self getAllLength:tag];
    NSLog(@"loaded:%lud  all:%lud",loadedLength,allLength);
    if (allLength == 0) {
        return 0.0;
    }
    return (double)loadedLength / allLength;
}

- (void)downloadData:(NSString *)url WithTag:(NSUInteger)tag progress: (void(^)( CGFloat progress)) progressBlock state:(void(^)(LCDownloadState state))stateBlack{
   
    if (!url && !tag) {
        return;
    }
    if ([self getAllLength:tag] == [self getFileDownloadedLength:tag] && [self getFileDownloadedLength:tag] > 0) {
        if (stateBlack) {
            stateBlack(LCDownloadStateCompleted);
        }
        return;
    }
    if ([self.downloadDic valueForKey:@(tag).stringValue]) {
     LCDownload *lc_D = [self.downloadDic valueForKey:@(tag).stringValue];
       
        if (lc_D.task.state == NSURLSessionTaskStateRunning ) {
            [lc_D.task suspend];
            if (lc_D.stateBlock) {
                lc_D.stateBlock(LCDownloadStateSuspended);
            }
        }else {
            [lc_D.task resume];
        }
        return;
    }
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    
    NSString *fullPath = [self createCachePath:tag];
    // 创建流
    NSOutputStream *stream = [NSOutputStream outputStreamToFileAtPath:fullPath append:YES];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    // 设置请求头
    NSString *range = [NSString stringWithFormat:@"bytes=%zd-", [self getFileDownloadedLength:tag]];
    [request setValue:range forHTTPHeaderField:@"Range"];
    
    // 创建一个Data任务
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];

    [task setValue:@(tag) forKeyPath:@"taskIdentifier"];
    
    LCDownload *lc_download = [[LCDownload alloc]init];
    lc_download.stream = stream;
    lc_download.task = task;
    lc_download.progressBlock = progressBlock;
    lc_download.stateBlock = stateBlack;
    [self.downloadDic setValue:lc_download forKey:@(tag).stringValue];
    [task resume];
}

- (void)removeAllFileData {
    NSString *fullPath = [self getCachDirectory];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:fullPath error:nil];
    [self.downloadDic enumerateKeysAndObjectsUsingBlock:^(NSString * key, LCDownload *lc_D, BOOL *stop) {
        if (lc_D) {
            [lc_D.task suspend];
            lc_D.progressBlock(0.0);
            [self.downloadDic removeObjectForKey:key];
        }
    }];
    

}
- (void)removeFileData:(NSUInteger)tag {
    if (!tag) {
        return;
    }
    NSString *fullPath = [self createCachePath:tag];
    NSFileManager *fileManager = [NSFileManager defaultManager ];
    if ([fileManager fileExistsAtPath:fullPath]) {
        [fileManager removeItemAtPath:fullPath error:nil];
    }
    
    LCDownload *lc_D = [self.downloadDic valueForKey:@(tag).stringValue];
    if (lc_D) {
        [lc_D.task suspend];
        if (lc_D.stateBlock) {
            lc_D.stateBlock(LCDownloadStateSuspended);
        }
        if (lc_D.progressBlock) {
            lc_D.progressBlock(0.0);
        }
        [self.downloadDic removeObjectForKey:@(tag).stringValue];
    }

    [self removeAllLength:tag];

    
}
// 创建文件名
- (NSString *)createFileName:(NSUInteger)tag {
    return [NSString stringWithFormat:@"LCDownload%lud",tag];
}
// 创建缓存路径
- (NSString *)createCachePath:(NSUInteger)tag {
    NSString *fileName = [self createFileName:tag];
    NSString *fullPath = [self getCachDirectory];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:NULL];
   NSString *path = [fullPath stringByAppendingPathComponent:fileName];
    
    return path;
}

- (NSString *)getCachDirectory {
    return [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"LCCache"];
}

- (void)setAllLength:(NSUInteger)allLength WithTag:(NSUInteger)tag {
    NSString *fileName = [self createFileName:tag];
    [[NSUserDefaults standardUserDefaults] setObject:@(allLength) forKey:fileName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)removeAllLength:(NSUInteger)tag {
    NSString *fileName = [self createFileName:tag];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:fileName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (NSUInteger)getAllLength:(NSUInteger)tag {
    NSString *fileName = [self createFileName:tag];
   NSNumber *allLength = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:fileName];
    if (allLength) {
        return allLength.unsignedIntegerValue;
    }
    return 0;
}


// 获取本地已经下载的大小
- (NSUInteger)getFileDownloadedLength:(NSUInteger)identifier {
    NSString *fullPath = [self createCachePath:identifier];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:fullPath]) {
        NSData *data = [NSData dataWithContentsOfFile:fullPath];
        return data.length;
    }
    return 0.0;
}
// 收到响应
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    LCDownload *lc_D = [self.downloadDic valueForKey:@(dataTask.taskIdentifier).stringValue];
    NSUInteger allLength = response.expectedContentLength + [self getFileDownloadedLength:dataTask.taskIdentifier];
    [self setAllLength:allLength WithTag:dataTask.taskIdentifier];
    lc_D.allLength = allLength;
    [lc_D.stream open];
    completionHandler(NSURLSessionResponseAllow);

}
// 接受数据（会多次调用）
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
   
     LCDownload *lc_D = [self.downloadDic valueForKey:@(dataTask.taskIdentifier).stringValue];
    if (lc_D) {
        if (lc_D.stateBlock) {
            lc_D.stateBlock(LCDownloadStateRunning);
        }
        [lc_D.stream write:data.bytes maxLength:data.length];
        CGFloat scale = (double)[self getFileDownloadedLength:dataTask.taskIdentifier] / lc_D.allLength;
        if (lc_D.progressBlock) {
            lc_D.progressBlock(scale);
        }
    }
    
}

// 请求完毕或失败
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    LCDownload *lc_D = [self.downloadDic valueForKey:@(task.taskIdentifier).stringValue];
    [lc_D.stream close];
    lc_D.stream = nil;
    if (lc_D.stateBlock) {
        lc_D.stateBlock(LCDownloadStateCompleted);
    }
    [self.downloadDic removeObjectForKey:@(task.taskIdentifier).stringValue];
    if (error) {
        if (lc_D.stateBlock) {
            lc_D.stateBlock(LCDownloadStateFailed);
        }
    }
}




@end
