//
//  JFSRNView.m
//  JFSRN
//
//  Created by 刘澈 on 2017/11/5.
//  Copyright © 2017年 刘澈. All rights reserved.
//

#import "JFSRNView.h"
#import "JFSRNFileManager.h"
#import "NSData+bsdiff.h"

#define  TEMP_RN_FILE_PATH  [NSString stringWithFormat:@"%@/%@",NSHomeDirectory(),@"/Library/Caches/com.jd.jr.science.rn/"]
@interface JFSRNView()
@property (nonatomic,copy)NSURL *diffFileURL;
@property (nonatomic,copy)NSString *moduleName;
@property (nonatomic,strong)NSDictionary * initialProperties;
@property (nonatomic,strong)NSDictionary * launchOptions;
@property (nonatomic,copy) NSString *rnFilePath;
@property (nonatomic,strong)NSData *commonData;
@property (nonatomic,strong)RCTRootView *RNRootView;
@property (nonatomic,weak)id<JFSRNFileOperation>operation;
@end

@implementation JFSRNView

- (void)dealloc {
    if (_rnFilePath != nil) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:_rnFilePath error:nil];
    }
    
    if (_operation != nil && [_operation respondsToSelector:@selector(cancel)]) {
        [_operation cancel];
    }
}

- (instancetype)initWithDiffFileURL:(NSURL *)url
                         commonData:(NSData *)commonData
                         moduleName:(NSString *)moduleName
                  initialProperties:(NSDictionary *)initialProperties
                      launchOptions:(NSDictionary *)launchOptions {
    
    
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    if (self != nil) {
        NSParameterAssert(url);
        NSParameterAssert(moduleName);
        _diffFileURL = url;
        _moduleName = moduleName;
        _initialProperties = initialProperties;
        _launchOptions = launchOptions;
        [self _createFolder];
        __weak JFSRNView *wself = self;
        self.operation =  [[JFSRNFileManager sharedManager] loadDiffPatchedByURL:url progress:nil completed:^(NSData * _Nullable data, NSURL * _Nonnull url) {
                dispatch_async(dispatch_get_main_queue(), ^{
                   __unused JFSRNView *sself = wself;
                    NSData *newData = commonData != nil?[NSData dataWithData:commonData andPatch:data]: data;
                    if (newData != nil) {
                        NSUInteger i = [[NSDate date] timeIntervalSince1970]*1000;
                        NSString *fileName = [NSString stringWithFormat:@"%lu", (unsigned long)i];
                        NSString *fullPath = [NSString stringWithFormat:@"%@/%@.bundle",TEMP_RN_FILE_PATH,fileName];
                        if ([newData writeToFile:fullPath atomically:YES]) {
                            sself.rnFilePath = fullPath;
                            sself.RNRootView = [[RCTRootView alloc] initWithBundleURL:[NSURL fileURLWithPath:sself.rnFilePath] moduleName:sself.moduleName initialProperties:sself.initialProperties launchOptions:sself.launchOptions];
                            sself.RNRootView.frame = sself.bounds;
                            [sself addSubview:sself.RNRootView];
                            if ([(NSObject *)sself.delegate respondsToSelector:@selector(rctRootViewDidDisplay)]) {
                                [sself.delegate rctRootViewDidDisplay];
                            }
                        }
                    }else {
                        if ([(NSObject *)sself.delegate respondsToSelector:@selector(rctRootViewLoadFailed)]) {
                            [sself.delegate rctRootViewLoadFailed];
                        }
                    }
                });
        }];
    }
    return self;
}



#pragma mark - override getter/setter
- (void)setRNRootView:(RCTRootView *)RNRootView {
    _RNRootView = RNRootView;
    if ([(NSObject *)self.delegate respondsToSelector:@selector(rctRootViewWillDisplay)]) {
        [self.delegate rctRootViewWillDisplay];
    }
}

- (void)setOperation:(id<JFSRNFileOperation>)operation {
    __weak id<JFSRNFileOperation> obj = operation;
    _operation = obj;
    if (_operation != nil && [(NSObject *)self.delegate respondsToSelector:@selector(rctRootViewPrepareLoad)]) {
        [self.delegate rctRootViewPrepareLoad];
    }
}


#pragma  mark - private
- (void)_createFolder {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error =nil;
    [fileManager createDirectoryAtPath:TEMP_RN_FILE_PATH withIntermediateDirectories:YES attributes:nil error:&error];
}


@end

