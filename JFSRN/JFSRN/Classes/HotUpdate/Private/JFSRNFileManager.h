//
//  JFSRNFileManager.h
//  JFSRN
//
//  Created by 刘澈 on 2017/11/1.
//  Copyright © 2017年 刘澈. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JFSRNFileOperation.h"

@interface JFSRNFileManager : NSObject

+ (nonnull instancetype)sharedManager;

- (nullable id <JFSRNFileOperation>)loadDiffPatchedByURL:(nonnull NSURL *)url
                                                progress:(nullable JFSRNFileLoadProgressBlock )progressBlock
                                               completed:(nullable JFSRNFileLoadCompletionBlock)completedBlock;


@end
