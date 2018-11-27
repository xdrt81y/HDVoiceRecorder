//
//  ViewController.m
//  HDVoiceRecorder
//
//  Created by haidi han on 2018/11/23.
//  Copyright © 2018 haidi han. All rights reserved.
//

#import "ViewController.h"
#import "HDVoiceRecorderViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)voiceButtonClick:(id)sender {
    HDVoiceRecorderViewController *vc = [[HDVoiceRecorderViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
