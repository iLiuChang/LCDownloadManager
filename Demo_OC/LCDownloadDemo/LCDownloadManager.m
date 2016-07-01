//
//  LCDownloadManager.m
//  LCDownloadDemo
//
//  Created by LiuChang on 16-6-24.
//  Copyright (c) 2016年 LiuChang. All rights reserved.
//

#import "LCDownloadManager.h"
#define AllLengthKey(tag)  [NSString stringWithFormat:@"%lud",tag]

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

- (NSUInteger)allLengthWithTag:(NSUInteger)tag {
    return [self getAllLength:tag];;
}


- (CGFloat)progressWithTag:(NSUInteger)tag {
    NSUInteger loadedLength = [self getFileDownloadedLength:tag];

    NSUInteger allLength = [self getAllLength:tag];
    NSLog(@"loaded:%lud  all:%lud",loadedLength,allLength);
    if (allLength == 0) {
        return 0.0;
    }
    return (double)loadedLength / allLength;
}

- (void)downloadDataWithURL:(NSString *)url tag:(NSUInteger)tag resume:(BOOL)resume progress: (void(^)( CGFloat progress)) progressBlock state:(void(^)(LCDownloadState state))stateBlack{
   
    if (!url && !tag) {
        return;
    }
    if ([self getAllLength:tag] == [self getFileDownloadedLength:tag] && [self getFileDownloadedLength:tag] > 0) {
        if (stateBlack) {
            stateBlack(LCDownloadStateCompleted);
        }
        if (progressBlock) {
            progressBlock(1.0);
        }
        return;
    }
    if ([self.downloadDic valueForKey:@(tag).stringValue]) {
     LCDownload *lc_D = [self.downloadDic valueForKey:@(tag).stringValue];
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
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    

    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    // 设置请求头
    NSString *range = [NSString stringWithFormat:@"bytes=%zd-", [self getFileDownloadedLength:tag]];
    [request setValue:range forHTTPHeaderField:@"Range"];
    
    // 创建一个Data任务
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];

    [task setValue:@(tag) forKeyPath:@"taskIdentifier"];
    
    LCDownload *lc_download = [[LCDownload alloc]init];
    lc_download.task = task;
    lc_download.progressBlock = progressBlock;
    lc_download.stateBlock = stateBlack;
    [self.downloadDic setValue:lc_download forKey:@(tag).stringValue];
    if (resume) {
        [task resume];
    }
}

- (void)resumeWithTag:(NSUInteger)tag {
    LCDownload *lc_D = [self.downloadDic valueForKey:@(tag).stringValue];
    if (lc_D) {
        [lc_D.task resume];
    }
}

- (void)suspendWithTag:(NSUInteger)tag {
    LCDownload *lc_D = [self.downloadDic valueForKey:@(tag).stringValue];
    if (lc_D) {
        [lc_D.task suspend];
        lc_D.stateBlock(LCDownloadStateSuspended);
    }
}

- (void)cancelWithTag:(NSUInteger)tag {
    LCDownload *lc_D = [self.downloadDic valueForKey:@(tag).stringValue];
    if (lc_D) {
        [lc_D.task cancel];
        lc_D.stateBlock(LCDownloadStateCanceled);
    }
}

- (NSData *)downloadedDataWithTag:(NSUInteger)tag {
    return [self getFileDownloadedData:tag];
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
- (void)removeFileDataWithTag:(NSUInteger)tag {
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
        [lc_D.task cancel];
        if (lc_D.stateBlock) {
            lc_D.stateBlock(LCDownloadStateCanceled);
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
    [self createFileAllLengthPlist];
    NSString *path = [self getFileAllLengthPath];
    NSMutableDictionary *dic = [self getFileAllLengthDic];
    [dic setValue:@(allLength) forKey:AllLengthKey(tag)];
    [dic writeToFile:path atomically:YES];
}

- (void)removeAllLength:(NSUInteger)tag {
    NSString *path = [self getFileAllLengthPath];
    NSMutableDictionary *dic = [self getFileAllLengthDic];
    if ([dic.allKeys containsObject:AllLengthKey(tag)]) {
        [dic removeObjectForKey:AllLengthKey(tag)];
        [dic writeToFile:path atomically:YES];
    }

}
- (NSUInteger)getAllLength:(NSUInteger)tag {
        NSMutableDictionary *dic = [self getFileAllLengthDic];
    if ([dic.allKeys containsObject:AllLengthKey(tag)]) {
        return ((NSNumber *)[dic valueForKey:AllLengthKey(tag)]).unsignedIntegerValue;
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
- (NSUInteger)getFileDownloadedLength:(NSUInteger)tag {
    NSData *data = [self getFileDownloadedData:tag];
    if (data) return data.length;
    return 0.0;
}

- (NSData *)getFileDownloadedData:(NSUInteger)tag {
    NSString *fullPath = [self createCachePath:tag];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:fullPath]) {
        NSData *data = [NSData dataWithContentsOfFile:fullPath];
        return data;
    }
    return nil;
}
// 收到响应
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    LCDownload *lc_D = [self.downloadDic valueForKey:@(dataTask.taskIdentifier).stringValue];
    NSUInteger allLength = response.expectedContentLength + [self getFileDownloadedLength:dataTask.taskIdentifier];
    [self setAllLength:allLength WithTag:dataTask.taskIdentifier];
    NSString *fullPath = [self createCachePath:dataTask.taskIdentifier];
    // 创建流
    NSOutputStream *stream = [NSOutputStream outputStreamToFileAtPath:fullPath append:YES];
    lc_D.stream = stream;
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
