//
//  NSData+bsdiff.h
//  bsdiff
//
//  Created by tcguo on 16/11/24.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <bzlib.h>

@interface NSData (bsdiff)

+ (NSData *)dataWithData:(NSData *)data andPatch:(NSData *)patch;


@end
