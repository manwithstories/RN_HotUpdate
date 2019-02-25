//
//  JSFRNFileDownLoader.h
//  JFSRN
//
//  Created by 刘澈 on 2017/11/1.
//  Copyright © 2017年 刘澈. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JFSRNFileOperation.h"
typedef void(^JFSRNFileCacheBlock)(NSData * _Nullable data);

@interface JFSRNFileDownLoader : NSObject

+ (nonnull instancetype)sharedDownloader;

@property (nonatomic,assign) NSInteger maxConcurrentDownloads;
@property (nonatomic,readonly,assign) NSUInteger currentDownloadCount;
@property (nonatomic,assign) NSTimeInterval downloadTimeout;
@property (readonly, nonatomic, nonnull) NSURLSessionConfiguration *sessionConfiguration;

- (_Nonnull id <JFSRNFileOperation>)downloadDiffWithURL:(NSURL *_Nonnull)url
                                               progress:(nullable JFSRNFileLoadProgressBlock )progressBlock
                                              completed:(nullable JFSRNFileLoadCompletionBlock)completedBlock
                                                  cache:(nullable JFSRNFileCacheBlock)cacheBlock;


@end
