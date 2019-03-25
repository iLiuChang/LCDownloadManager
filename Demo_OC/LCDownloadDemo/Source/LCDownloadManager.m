//
//  LCDownloadManager.m
//  LCDownloadDemo
//
//  Created by LiuChang on 16-6-24.
//  Copyright (c) 2016年 LiuChang. All rights reserved.
//

#import "LCDownloadManager.h"
#import "NSString+Ext.h"


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

- (NSUInteger)allLengthWithFileName:(NSString *)fileName {
    return [self getAllLengthWithFileName:fileName];;
}


- (CGFloat)progressWithURL:(NSString *)url {
    NSString *fileName = url.md5String;
    NSUInteger loadedLength = [self getFileDownloadedLengthWithFileName:fileName];

    NSUInteger allLength = [self getAllLengthWithFileName:fileName];
    NSLog(@"loaded:%lud  all:%lud",loadedLength,allLength);
    if (allLength == 0) {
        return 0.0;
    }
    return (double)loadedLength / allLength;
}

- (void)downloadDataWithURL:(NSString *)url resume:(BOOL)resume progress: (void(^)( CGFloat progress)) progressBlock state:(void(^)(LCDownloadState state))stateBlack{
   
    if (!url) {
        NSLog(@"url is nil");
        return;
    }
    
    NSString *urlmd5 = url.md5String;

    if ([self getAllLengthWithFileName:urlmd5] == [self getFileDownloadedLengthWithFileName:urlmd5] && [self getFileDownloadedLengthWithFileName:urlmd5] > 0) {
        if (stateBlack) {
            stateBlack(LCDownloadStateCompleted);
        }
        if (progressBlock) {
            progressBlock(1.0);
        }
        return;
    }
    if ([self.downloadDic valueForKey:url]) {
     LCDownload *lc_D = [self.downloadDic valueForKey:url];
        if (resume) {
            [lc_D.task resume];
            
        }else {
            [lc_D.task suspend];
            if (lc_D.stateBlock) {
                lc_D.stateBlock(LCDownloadStateSuspended);
            }

        }
      
        return;
    }
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    // 设置请求头
    NSString *range = [NSString stringWithFormat:@"bytes=%zd-", [self getFileDownloadedLengthWithFileName:urlmd5]];
    [request setValue:range forHTTPHeaderField:@"Range"];
    // 创建一个Data任务
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    
    LCDownload *lc_download = [[LCDownload alloc]init];
    lc_download.task = task;
    lc_download.progressBlock = progressBlock;
    lc_download.stateBlock = stateBlack;
    lc_download.fileName = urlmd5;
    [self.downloadDic setValue:lc_download forKey:url];
    if (resume) {
        [task resume];
    }
}

- (void)resumeWithURL:(NSString *)url {
    LCDownload *lc_D = [self.downloadDic valueForKey:url];
    if (lc_D) {
        [lc_D.task resume];
    }
}

- (void)suspendWithURL:(NSString *)url {
    LCDownload *lc_D = [self.downloadDic valueForKey:url];
    if (lc_D) {
        [lc_D.task suspend];
        lc_D.stateBlock(LCDownloadStateSuspended);
    }
}

- (void)cancelWithURL:(NSString *)url {
    LCDownload *lc_D = [self.downloadDic valueForKey:url];
    if (lc_D) {
        [lc_D.task cancel];
        lc_D.stateBlock(LCDownloadStateCanceled);
    }
}

- (NSData *)downloadedDataWithFileName:(NSString *)fileName {
    return [self getFileDownloadedDataWithFileName:fileName];
}

- (void)removeAllFileData {
    NSString *fullPath = [self getCachDirectory];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:fullPath error:nil];
    [self.downloadDic enumerateKeysAndObjectsUsingBlock:^(NSString * key, LCDownload *lc_D, BOOL *stop) {
        if (lc_D) {
            [lc_D.task suspend];
            lc_D.progressBlock(0.0);
        }
    }];
    [self.downloadDic removeAllObjects];


}

- (void)removeFileDataWithURL:(NSString *)url {
    if (!url) {
        return;
    }
    
    LCDownload *lc_D = [self.downloadDic valueForKey:url];
    if (!lc_D) {
        return;
    }
    NSString *fullPath = [self createCachePathWithFileName:lc_D.fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager ];
    if ([fileManager fileExistsAtPath:fullPath]) {
        [fileManager removeItemAtPath:fullPath error:nil];
    }

    [lc_D.task cancel];
    if (lc_D.stateBlock) {
        lc_D.stateBlock(LCDownloadStateCanceled);
    }
    if (lc_D.progressBlock) {
        lc_D.progressBlock(0.0);
    }
    [self.downloadDic removeObjectForKey:url];

    [self removeAllLengthWithFileName:lc_D.fileName];

}

// 创建缓存路径
- (NSString *)createCachePathWithFileName:(NSString *)fileName {
    NSString *fullPath = [self getCachDirectory];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:NULL];
   NSString *path = [fullPath stringByAppendingPathComponent:fileName];
    return path;
}

- (NSString *)getCachDirectory {
    return [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"LCCache"];
}

- (void)setAllLength:(NSUInteger)allLength WithFileName:(NSString *)fileName {
    [self createFileAllLengthPlist];
    NSString *path = [self getFileAllLengthPath];
    NSMutableDictionary *dic = [self getFileAllLengthDic];
    [dic setValue:@(allLength) forKey:fileName];
    [dic writeToFile:path atomically:YES];
}

- (void)removeAllLengthWithFileName:(NSString *)fileName {
    NSString *path = [self getFileAllLengthPath];
    NSMutableDictionary *dic = [self getFileAllLengthDic];
    if ([dic.allKeys containsObject:fileName]) {
        [dic removeObjectForKey:fileName];
        [dic writeToFile:path atomically:YES];
    }

}
- (NSUInteger)getAllLengthWithFileName:(NSString *)fileName {
        NSMutableDictionary *dic = [self getFileAllLengthDic];
    if ([dic.allKeys containsObject:fileName]) {
        return ((NSNumber *)[dic valueForKey:fileName]).unsignedIntegerValue;
    }
    return 0;
}

- (void)createFileAllLengthPlist {
    NSString *path = [self getFileAllLengthPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        [fileManager createFileAtPath:path contents:nil attributes:nil];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic writeToFile:path atomically:YES];
    }
}

- (NSString *)getFileAllLengthPath {
    NSString *path = [self getCachDirectory];
    path = [path stringByAppendingPathComponent:@"AllLength.plist"];
    return  path;
}

- (NSMutableDictionary *)getFileAllLengthDic {
    NSString *path = [self getFileAllLengthPath];
    return [[NSMutableDictionary alloc]initWithContentsOfFile:path];
}

// 获取本地已经下载的大小
- (NSUInteger)getFileDownloadedLengthWithFileName:(NSString *)fileName {
    NSData *data = [self getFileDownloadedDataWithFileName:fileName];
    if (data) return data.length;
    return 0.0;
}

- (NSData *)getFileDownloadedDataWithFileName:(NSString *)fileName {
    NSString *fullPath = [self createCachePathWithFileName:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:fullPath]) {
        NSData *data = [NSData dataWithContentsOfFile:fullPath];
        return data;
    }
    return nil;
}
// 收到响应
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    NSString *url = dataTask.currentRequest.URL.absoluteString;
    LCDownload *lc_D = [self.downloadDic valueForKey:url];
    NSInteger allLength = response.expectedContentLength + [self getFileDownloadedLengthWithFileName:lc_D.fileName];
    NSLog(@"allLength:%d expectedContentLength:%d", allLength, response.expectedContentLength);
    if (allLength <= 0) {
        completionHandler(NSURLSessionResponseCancel);
        return;
    }
    [self setAllLength:allLength WithFileName:lc_D.fileName];
    NSString *fullPath = [self createCachePathWithFileName:lc_D.fileName];
    // 创建流
    NSOutputStream *stream = [NSOutputStream outputStreamToFileAtPath:fullPath append:YES];
    lc_D.stream = stream;
    lc_D.allLength = allLength;
    [lc_D.stream open];
    completionHandler(NSURLSessionResponseAllow);

}
// 接受数据（会多次调用）
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    NSString *url = dataTask.currentRequest.URL.absoluteString;
     LCDownload *lc_D = [self.downloadDic valueForKey:url];
    if (lc_D) {
        if (lc_D.stateBlock) {
            lc_D.stateBlock(LCDownloadStateRunning);
        }
        [lc_D.stream write:data.bytes maxLength:data.length];
        CGFloat scale = (double)[self getFileDownloadedLengthWithFileName:lc_D.fileName] / lc_D.allLength;
        if (lc_D.progressBlock) {
            lc_D.progressBlock(scale);
        }
    }
    
}

// 请求完毕或失败
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSString *url = task.currentRequest.URL.absoluteString;
    LCDownload *lc_D = [self.downloadDic valueForKey:url];
    [lc_D.stream close];
    lc_D.stream = nil;
    if (lc_D.stateBlock) {
        lc_D.stateBlock(LCDownloadStateCompleted);
    }
    [self.downloadDic removeObjectForKey:url];
    if (error) {
        if (lc_D.stateBlock) {
            lc_D.stateBlock(LCDownloadStateFailed);
        }
    }
}




@end
