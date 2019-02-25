//
//  ViewController.m
//  JFSRN
//
//  Created by 刘澈 on 2017/10/31.
//  Copyright © 2017年 刘澈. All rights reserved.
//

#import "ViewController.h"
#import "NSData+bsdiff.h"
#import <React/RCTRootView.h>
#import "JFSRNFileManager.h"

@interface ViewController ()
@property (nonatomic, strong) RCTRootView *RNView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSURL *patch_url =  [NSURL URLWithString:@"http://7xrbv4.com1.z0.glb.clouddn.com/hot.patched"];
    [[JFSRNFileManager sharedManager] loadDiffPatchedByURL:patch_url progress:nil completed:nil];
    
    
//    self.RNView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,  [UIScreen mainScreen].bounds.size.height);
//    [self.view addSubview:self.RNView];
//
//    NSLog(@"%@",NSStringFromCGRect(self.RNView.frame));
   
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (RCTRootView *)RNView {
    if (_RNView == nil) {
        //NSURL *url = [NSURL URLWithString:@"http://127.0.0.1:8081/index.ios.bundle?platform=ios"];
        
        NSURL *common_url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"common" ofType:@"bundle"]];
        NSURL *patch_url =  [NSURL URLWithString:@"http://7xrbv4.com1.z0.glb.clouddn.com/hot.patched"];
        
        
        // NSURL *patch_url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"jdrbankapp" ofType:@"plist"]];
        NSData *patch_data = [NSData dataWithContentsOfURL:patch_url];
        
        NSLog(@"%@",patch_data);
        NSData *data = [NSData dataWithData:[NSData dataWithContentsOfURL:common_url] andPatch:patch_data];
        
        if (data  == nil) {
            return  nil;
        }
        
        
        NSString *path = [NSString stringWithFormat:@"%@/Documents/new.bundle",NSHomeDirectory()];
        NSURL *merge_url = [NSURL fileURLWithPath:path ];
        
        BOOL flag =  [data writeToURL:merge_url atomically:YES];
        
        _RNView = [[RCTRootView alloc] initWithBundleURL:merge_url moduleName:@"AllApplication" initialProperties:@{}  launchOptions:nil];
    }
    return _RNView;
}


@end
