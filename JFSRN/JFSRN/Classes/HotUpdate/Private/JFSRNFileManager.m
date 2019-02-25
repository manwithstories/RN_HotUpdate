//
//  JFSRNFileManager.m
//  JFSRN
//
//  Created by 刘澈 on 2017/11/1.
//  Copyright © 2017年 刘澈. All rights reserved.
//

#import "JFSRNFileManager.h"
#import "JFSRNFileCacher.h"
#import "JFSRNFileDownLoader.h"
#import <objc/runtime.h>
#import <CommonCrypto/CommonCrypto.h>

#define  MAPPING_TABLE_PATH @"/Documents/com.jd.jr.science.rn"
#define  MAPPING_TABLE_NAME @"mapping.plist"
#define  DIFF_FILE_PATH  @"/Documents/com.jd.jr.science.rn/patched"




@interface JFSRNFileManager ()

@property (nonatomic,strong) JFSRNFileDownLoader *downloader;
@property (nonatomic,strong) JFSRNFileCacher *cacher;
@property (nonatomic,strong) NSMutableDictionary <NSString* ,NSString*>*fileMappingTable;
@property (nonatomic,copy,readonly) NSString * _Nonnull mappingTablePath;
@property (nonatomic,copy,readonly) NSString *_Nonnull  diffFilePath;

@end

@implementation JFSRNFileManager

@synthesize mappingTablePath = _mappingTablePath;
@synthesize diffFilePath = _diffFilePath;

#pragma mark - init
+ (nonnull instancetype)sharedManager {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (nonnull instancetype)init {
    JFSRNFileCacher *cacher = [JFSRNFileCacher sharedImageCacheWithCachPath:[NSString stringWithFormat:@"%@%@",NSHomeDirectory(),DIFF_FILE_PATH]];
    JFSRNFileDownLoader *downloader = [JFSRNFileDownLoader sharedDownloader];
    return [self initWithCache:cacher downloader:downloader];
}

- (nonnull instancetype)initWithCache:(nonnull JFSRNFileCacher *)cacher downloader:(nonnull JFSRNFileDownLoader *)downloader {
    
    if ((self = [super init])) {
        _cacher = cacher;
        _downloader = downloader;
        [self _setup];
    }
    return self;
}


#pragma mark - public
- (nullable id <JFSRNFileOperation>)loadDiffPatchedByURL:(nonnull NSURL *)url
                                                progress:(nullable JFSRNFileLoadProgressBlock )progressBlock
                                               completed:(nullable JFSRNFileLoadCompletionBlock)completedBlock {
    
    if ([url isKindOfClass:NSString.class]) {
        url = [NSURL URLWithString:(NSString *)url];
    }
    
    if (url == nil || url.absoluteString.length < 1) {
        NSAssert(url, @"url must not be nil.");
        return nil;
    }
    
    NSObject <JFSRNFileOperation> *operation  = nil;
    NSString *cachePath = [NSString stringWithFormat:@"%@/%@",self.diffFilePath,[self _getCachePathByURLString:url.absoluteString]];
    
    //有缓存取缓存
    if (cachePath != nil && [self.cacher hasCacheByPath:cachePath]) {
        operation =  [self.cacher getDataByCachePath:cachePath progress:progressBlock completed:completedBlock];
    }else { //没缓存去下载
        [self.downloader downloadDiffWithURL:url progress:progressBlock completed:completedBlock cache:^(NSData * data) {
            [self.cacher cacheData:data byFileName:[self _getMD5SignFromData:data] completed:^(NSString *  fileName) {
                self.fileMappingTable[url.absoluteString] = fileName;
                [self _saveFileMappingTable];
            }];
        }];
    }
    [operation setValue:url forKey:@"_url"];
    return operation;
}



#pragma mark - private method


- (void)_saveFileMappingTable {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    if (self.fileMappingTable != nil) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *fullPath = [NSString stringWithFormat:@"%@%@/%@",NSHomeDirectory(),MAPPING_TABLE_PATH,MAPPING_TABLE_NAME];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [fileManager removeItemAtPath:fullPath error:nil];
            [self.fileMappingTable writeToFile:fullPath atomically:YES];
        });
      
    }
    
    dispatch_semaphore_signal(semaphore);
}

-(NSString *)_getMD5SignFromData:(NSData *)data {
    
    //1: 创建一个MD5对象
    CC_MD5_CTX md5;
    //2: 初始化MD5
    CC_MD5_Init(&md5);
    //3: 准备MD5加密
    CC_MD5_Update(&md5, data.bytes, (CC_LONG)data.length);
    //4: 准备一个字符串数组, 存储MD5加密之后的数据
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    //5: 结束MD5加密
    CC_MD5_Final(result, &md5);
    NSMutableString *resultString = [NSMutableString string];
    //6:从result数组中获取最终结果
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [resultString appendFormat:@"%02X", result[i]];
    }
    return resultString;
}


- (void)_setup {
    [self _createMappingTableDirectory];
    [self _createDiffFileCacheDirectory];
}

//创建映射表文件夹
-(void)_createMappingTableDirectory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:self.mappingTablePath]){
        NSError *error =nil;
        [fileManager createDirectoryAtPath:self.mappingTablePath withIntermediateDirectories:YES attributes:nil error:&error];
    }
}

- (void)_createDiffFileCacheDirectory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //创建RN diff 文件夹
    if (![fileManager fileExistsAtPath:self.diffFilePath]) {
        NSError *error =nil;
         [fileManager createDirectoryAtPath:self.diffFilePath withIntermediateDirectories:YES attributes:nil error:&error];
    }
}


//是否在映射表中有映射
- (NSString *)_getCachePathByURLString:(NSString *)url_string {
    return  url_string == nil?nil:self.fileMappingTable[url_string];
}


#pragma mark - override getter/setter
- (NSString *)mappingTablePath {
    if (_mappingTablePath == nil || _mappingTablePath.length<1) {
        _mappingTablePath = [NSString stringWithFormat:@"%@%@",NSHomeDirectory(),MAPPING_TABLE_PATH];
    }
    return _mappingTablePath;
}

- (NSString *)diffFilePath {
    if (_diffFilePath == nil || _diffFilePath.length <1) {
        _diffFilePath = [NSString stringWithFormat:@"%@%@",NSHomeDirectory(),DIFF_FILE_PATH];
    }
    return _diffFilePath;
}

- (NSMutableDictionary *)fileMappingTable {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    if (_fileMappingTable == nil ) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *path = [NSString stringWithFormat:@"%@%@/%@",NSHomeDirectory(),MAPPING_TABLE_PATH,MAPPING_TABLE_NAME];
        _fileMappingTable =  [fileManager fileExistsAtPath:path]? [[NSMutableDictionary alloc] initWithContentsOfFile:path] : [NSMutableDictionary dictionary];
    }
    dispatch_semaphore_signal(semaphore);
    return _fileMappingTable;
}

@end
