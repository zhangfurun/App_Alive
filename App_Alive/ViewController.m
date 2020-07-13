//
//  ViewController.m
//  App_Alive
//
//  Created by ifenghui on 2020/7/13.
//  Copyright © 2020 ifenghuI. All rights reserved.
//

#import "ViewController.h"

static NSString * LAST_TIME = @"background_alive_last";
static NSString * MAX_TIME = @"background_alive_max";

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *maxTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *lasTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *currTimeLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
   __block NSInteger maxTime = ((NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:MAX_TIME]).integerValue;
    NSInteger lastTime = ((NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:LAST_TIME]).integerValue;
    
    self.maxTimeLabel.text = [NSString stringWithFormat:@"最大存活:\n%ld秒", maxTime];
    self.currTimeLabel.text = @"当前存活:\n0秒";
    self.lasTimeLabel.text = [NSString stringWithFormat:@"上次存活:\n%ld秒", lastTime];
    
    
    [[NSUserDefaults standardUserDefaults] setValue:0 forKey:LAST_TIME];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    __block NSTimeInterval timeToLive = 0;
    
    __weak typeof(self) WS = self;
    [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        timeToLive++;
        NSLog(@"app运行中:%@",@(timeToLive));
        
        WS.currTimeLabel.text = [NSString stringWithFormat:@"当前存活:\n%ld秒", (NSInteger)timeToLive];
        
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:(NSInteger)timeToLive] forKey:LAST_TIME];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        maxTime = ((NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:MAX_TIME]).integerValue;
        if (maxTime <= timeToLive) {
            
            WS.maxTimeLabel.text = [NSString stringWithFormat:@"最大存活:\n%ld秒", (NSInteger)timeToLive];
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:(NSInteger)timeToLive] forKey:MAX_TIME];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }];
}
@end
