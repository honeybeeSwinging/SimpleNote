//
//  EditNoteViewController.m
//  SimpleNote
//
//  Created by v2panda on 16/4/7.
//  Copyright © 2016年 v2panda. All rights reserved.
//

#import "EditNoteViewController.h"

@interface EditNoteViewController ()

@end

@implementation EditNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"EditNoteViewController - %@",self.noteModel);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
