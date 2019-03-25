//
//  NSString+Ext.m
//  LCDownloadDemo
//
//  Created by 刘畅 on 2019/3/25.
//  Copyright © 2019 LiuChang. All rights reserved.
//

#import "NSString+Ext.h"
#import "NSData+Ext.h"

@implementation NSString (Ext)

- (NSString *)md5String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] md5String];
}

- (NSString *)hmacMD5StringWithKey:(NSString *)key {
    return [[self dataUsingEncoding:NSUTF8StringEncoding]
            hmacMD5StringWithKey:key];
}

@end
