//
//  JSFFileOperation.h
//  JFSRN
//
//  Created by 刘澈 on 2017/11/1.
//  Copyright © 2017年 刘澈. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^JFSRNFileLoadCompletionBlock)(NSData * _Nullable data,NSURL * _Nonnull url);
typedef void(^JFSRNFileLoadProgressBlock)(NSProgress * _Nonnull progress);

@protocol JFSRNFileOperation <NSObject>

@required
@property (nonatomic,strong,readonly)NSURL * _Nonnull url;
@property (nonatomic,copy)JFSRNFileLoadProgressBlock _Nullable progressBlock;
@property (nonatomic,copy)JFSRNFileLoadCompletionBlock _Nullable completedBlock;

- (void)cancel;

@end
