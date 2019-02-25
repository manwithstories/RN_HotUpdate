//
//  JFSRNView.h
//  JFSRN
//
//  Created by 刘澈 on 2017/11/5.
//  Copyright © 2017年 刘澈. All rights reserved.
//

#import <UIKit/UIKit.h>
#import  <React/RCTRootView.h>

@protocol JFSRNViewDelegate
@optional
- (void)rctRootViewPrepareLoad;
- (void)rctRootViewWillDisplay;
- (void)rctRootViewDidDisplay;
- (void)rctRootViewLoadFailed;
@end

@interface JFSRNView : UIView

@property (nonatomic,strong,readonly)RCTRootView *RNRootView;
@property (nonatomic,weak)id <JFSRNViewDelegate> delegate;

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)new  NS_UNAVAILABLE;

- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;




/**
 如果传进来的commonData为nil，就视为没有预加载包，是要下载完整的 业务JSBundle文件

 @param url <#url description#>
 @param commonData <#commonData description#>
 @param moduleName <#moduleName description#>
 @param initialProperties <#initialProperties description#>
 @param launchOptions <#launchOptions description#>
 @return <#return value description#>
 */
- (instancetype)initWithDiffFileURL:(NSURL *)url
                         commonData:(NSData *)commonData
                         moduleName:(NSString *)moduleName
                  initialProperties:(NSDictionary *)initialProperties
                      launchOptions:(NSDictionary *)launchOptions;

@end
