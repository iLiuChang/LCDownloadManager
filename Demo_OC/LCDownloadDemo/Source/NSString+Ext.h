//
//  NSString+Ext.h
//  LCDownloadDemo
//
//  Created by 刘畅 on 2019/3/25.
//  Copyright © 2019 LiuChang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Ext)

- (NSString *)md5String;

- (NSString *)hmacMD5StringWithKey:(NSString *)key;

@end
