//
//  JSFRNFileCacher.m
//  JFSRN
//
//  Created by 刘澈 on 2017/11/1.
//  Copyright © 2017年 刘澈. All rights reserved.
//

#import "JFSRNFileCacher.h"


static NSCache *s_memoryCache;
typedef NS_ENUM(NSUInteger, JSFRNIOOperationType) {
    JSFRNIOOperation_inPutType = 0,
    JSFRNIOOperation_outPutType
};

@interface JFSRNIOOperation : NSOperation <JFSRNFileOperation>



@property (nonatomic,assign,readonly)JSFRNIOOperationType operationType;
@property (nonatomic,strong)NSData *inPutData;
@property (nonatomic,copy)NSString *path;
@property (nonatomic,copy)JFSRNFileLoadProgressBlock progressBlock;
@property (nonatomic,copy)JFSRNFileLoadCompletionBlock completedBlock;
@property (nonatomic,copy)JFSRNFileCacheCompletionBlock cacheCompletionBlock;
@property (nonatomic,strong,readonly)NSURL *url;
@property (nonatomic,copy)NSString *fileName;


- (instancetype)initInputOperationWithData:(NSData *)inPutData inPutPath:(NSString *)path;
- (instancetype)initOnputOperationWithOutPutPath:(NSString *)path;

@end

@implementation JFSRNIOOperation

@synthesize url = _url;

- (void)dealloc {
    
}

- (instancetype)initInputOperationWithData:(NSData *)inPutData inPutPath:(NSString *)path {
    NSParameterAssert(inPutData);
    NSParameterAssert(path);
    self = [super init];
    if (self != nil) {
        _inPutData = inPutData;
        _path = path;
        _operationType = JSFRNIOOperation_inPutType;
    }
    return self;
}
- (instancetype)initOnputOperationWithOutPutPath:(NSString *)path{
   NSParameterAssert(path);
    self = [super init];
    if (self != nil) {
        _operationType = JSFRNIOOperation_outPutType;
        _path = path;
    }
    return self;
}

- (void)main {
    if (self.cancelled) {
        return;
    }
    
    switch (self.operationType) {
        case JSFRNIOOperation_inPutType: {
            [self _inPut];
        }
            break;
            
        default: {
            [self _outPut];
        }
            break;
    }
}

- (void)_inPut {
    if (self.inPutData != nil && self.path != nil) {
       [self.inPutData writeToFile:self.path atomically:YES];
       [s_memoryCache  setObject:self.inPutData forKey:self.path cost:self.inPutData.length];
        if (self.cacheCompletionBlock != nil) {
            self.cacheCompletionBlock(self.fileName);
        }
    }
}

- (void)_outPut {
    NSData *data = [s_memoryCache objectForKey:self.path];
    if (data == nil) {
        data = [[NSData alloc] initWithContentsOfFile:self.path];
        if (data != nil) {
            [s_memoryCache setObject:data forKey:self.path cost:data.length];
        }
    }
    
    
    if (self.progressBlock != nil) {
        NSProgress * progress = [[NSProgress alloc] init];
        progress.totalUnitCount = 1;
        progress.completedUnitCount = 1;
        self.progressBlock(progress);
    }
    
    if (self.completedBlock != nil) {
        self.completedBlock(data,self.url);
    }
    
}

- (void)cancel{
    [super cancel];
}

@end


@interface JFSRNFileCacher()
@property (nonatomic,copy,readonly)NSString *cachePath;
@property (nonatomic,strong)NSOperationQueue *ioQueue;

@end

@implementation JFSRNFileCacher

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (nonnull instancetype)sharedImageCacheWithCachPath:(NSString *)cachePath {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        s_memoryCache = [[NSCache alloc] init];
        s_memoryCache.totalCostLimit = 10 * 1024 * 1024; // 10MB
        s_memoryCache.name = @"com.jd.jr.science.rn";
        instance = [[self alloc] initWithCachePath:cachePath];
    });
    return instance;
}

- (instancetype)initWithCachePath:(NSString *)cachePath {
    NSParameterAssert(cachePath);
    
    self = [super init];
    if (self != nil) {
        _ioQueue = [NSOperationQueue new];
        _ioQueue.name = @"com.jd.jr.science.rn.ioQueue";
        _ioQueue.maxConcurrentOperationCount = 6;
        
        _cachePath = cachePath;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_clearMemoryCache)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    return self;
}


- (JFSRNIOOperation *)getDataByCachePath:(NSString *)path
                                progress:(nullable JFSRNFileLoadProgressBlock)progressBlock
                               completed:(nullable JFSRNFileLoadCompletionBlock)completedBlock {
    
    JFSRNIOOperation *outPutOperation = [[JFSRNIOOperation alloc] initOnputOperationWithOutPutPath:path];
    outPutOperation.progressBlock  = progressBlock;
    outPutOperation.completedBlock  = completedBlock;
    [self.ioQueue addOperation:outPutOperation];
    return outPutOperation;
}

- (void)cacheData:(nonnull NSData *)data
       byFileName:(nonnull NSString *)fileName
        completed:(nullable JFSRNFileCacheCompletionBlock)cacheCompletedBlock {
     NSParameterAssert(fileName);
     NSParameterAssert(data);
    if (data == nil || ![fileName isKindOfClass:[NSString class]] || fileName.length<1) {
        return;
    }
    JFSRNIOOperation *inPutOperation = [[JFSRNIOOperation alloc] initInputOperationWithData:data inPutPath:[NSString stringWithFormat:@"%@/%@",self.cachePath,fileName]];
    inPutOperation.cacheCompletionBlock = cacheCompletedBlock;
    inPutOperation.fileName = fileName;
    [self.ioQueue addOperation:inPutOperation];
}




#pragma mark - private
- (void)_clearMemoryCache {
    [s_memoryCache removeAllObjects];
}


#pragma mark - public
- (BOOL)hasCacheByPath:(NSString *)path {
    NSParameterAssert(path);
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

@end
