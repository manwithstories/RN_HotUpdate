//
//  JSFRNFileDownLoader.m
//  JFSRN
//
//  Created by 刘澈 on 2017/11/1.
//  Copyright © 2017年 刘澈. All rights reserved.
//

#import "JFSRNFileDownLoader.h"
#import "JFSRNFileManager.h"
#import "JFSRNFileCacher.h"


@interface JFSRNDownLoadOperation :NSOperation <JFSRNFileOperation>

@property (nonatomic,strong)NSURL *url;
@property (nonatomic,strong,readonly)NSURLSessionTask *task;
@property (nonatomic,copy)JFSRNFileLoadProgressBlock progressBlock;
@property (nonatomic,copy)JFSRNFileLoadCompletionBlock completedBlock;
@property (nonatomic,copy)JFSRNFileCacheBlock cacheBlock;

@end

@implementation JFSRNDownLoadOperation

@synthesize url = _url;

- (void)dealloc {
    
}

- (instancetype)initWithTask:(NSURLSessionTask *)task{
    self = [super init];
    if(self != nil){
        _task = task;
    }
    return self;
}

- (void)main {
    if (self.task  != nil) {
        [self.task resume];
    }
}

- (void)cancel{
    if (self.task != nil) {
        [self.task cancel];
    }
    [super cancel];
}

@end


@interface JFSRNFileDownLoader()<NSURLSessionDownloadDelegate>
@property (nonatomic,strong) NSOperationQueue *downloadQueue;
@property (nonatomic,strong) NSURLSession *session;
@property (nonatomic,strong) NSMutableDictionary<NSURL *, JFSRNDownLoadOperation *> *URLOperations;
@end


@implementation JFSRNFileDownLoader


- (void)dealloc {
    [self.session invalidateAndCancel];
    self.session = nil;
    [self.downloadQueue cancelAllOperations];
}

#pragma  mark - init
+ (nonnull instancetype)sharedDownloader {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (instancetype) init {
    self = [super init];
    if (self != nil) {
        _sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _downloadQueue = [NSOperationQueue new];
        _downloadQueue.maxConcurrentOperationCount = 6;
        _downloadQueue.name = @"com.jd.jr.science.rn.netWork";
        
        _URLOperations = [NSMutableDictionary dictionary];
    }
    return self;
}


#pragma mark - public

- (_Nonnull id <JFSRNFileOperation>)downloadDiffWithURL:(NSURL *_Nonnull)url
                                               progress:(nullable JFSRNFileLoadProgressBlock )progressBlock
                                              completed:(nullable JFSRNFileLoadCompletionBlock)completedBlock
                                                  cache:(nullable JFSRNFileCacheBlock)cacheBlock;
{
    
    
    JFSRNDownLoadOperation *operation = [[JFSRNDownLoadOperation alloc] initWithTask:[self.session downloadTaskWithURL:url]];
    self.URLOperations[url] = operation;
    operation.progressBlock = progressBlock;
    operation.completedBlock = completedBlock;
    operation.cacheBlock = cacheBlock;
    [self.downloadQueue addOperation:operation];
    return operation;
}


#pragma mark - private


#pragma mark - override getter/setter
- (void)setDownloadTimeout:(NSTimeInterval)downloadTimeout {
    _downloadTimeout = downloadTimeout;
    if (_downloadTimeout <= 0) {
        _downloadTimeout = 15;
    }
    self.sessionConfiguration.timeoutIntervalForRequest = _downloadTimeout;
}

- (NSURLSession *)session {
    if (_session == nil) {
        _session = [NSURLSession sessionWithConfiguration:self.sessionConfiguration
                                                 delegate:self
                                            delegateQueue:nil];
    }
    return _session;
}


#pragma  mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    
    NSURL *url = downloadTask.currentRequest.URL;
    JFSRNDownLoadOperation *operation = self.URLOperations[url];
    if (operation != nil ) {
        NSData *data = [NSData dataWithContentsOfURL:location];
        if (operation.cacheBlock != nil) {
            operation.cacheBlock(data);
        }
        
        
        if (operation.completedBlock != nil) {
            operation.completedBlock(data,url);
            self.URLOperations[url] = nil;
        }
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSURL *url = downloadTask.currentRequest.URL;
    JFSRNDownLoadOperation *operation = self.URLOperations[url];
    if (operation != nil) {
        NSProgress *progress = [[NSProgress alloc] init];
        progress.totalUnitCount = totalBytesExpectedToWrite;
        progress.completedUnitCount = totalBytesWritten;
        if (operation.progressBlock != nil) {
            operation.progressBlock(progress);
        }
    }
}


@end
