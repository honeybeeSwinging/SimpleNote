//
//  NoteListController.m
//  SimpleNote
//
//  Created by 徐臻 on 15/3/19.
//  Copyright (c) 2015年 xuzhen. All rights reserved.
//

#import "NoteListController.h"
#import "NoteManager.h"
#import "NoteDetailController.h"
#import "VNNote.h"
#import "VNConstants.h"
#import "NoteListCell.h"

#import "SVProgressHUD.h"
#import "UIColor+VNHex.h"

@interface NoteListController ()<UITextFieldDelegate>
{
    NSMutableString *_resultString;
    NSArray *colorArr;
    NSInteger colorCount;
    UITextField *txt;
    SCLAlertView *alert;
}

@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation NoteListController

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self setupNavigationBar];

  self.view.backgroundColor = [UIColor whiteColor];
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
  self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(reloadData)
                                               name:kNotificationCreateFile
                                             object:nil];
    
}

-(void)tapClick
{
    if ([txt isFirstResponder]) {
        [txt resignFirstResponder];
        [UIView animateWithDuration:0.1 animations:^{
            UIView *view1 = [alert getView];
            CGRect r = view1.frame;
            r.origin.y = r.origin.y +70;
            view1.frame =  r;
        }];
    }
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [self reloadData];
}
- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupNavigationBar
{
  UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"20150427041642990_easyicon_net_32"]
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(changeColor)];
  self.navigationItem.leftBarButtonItem = leftItem;
  
  UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_add_tab"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(createTask)];
  self.navigationItem.rightBarButtonItem = rightItem;
  self.navigationItem.title = kAppName;
}

-(void)changeColor
{
    colorArr = [NSArray arrayWithObjects:DefaultColor,DefaultGreen,DefaultRed,DefaultYellow,nil];
    
    colorCount = (colorCount + 1)%4;
    NSNumber *numObj = [NSNumber numberWithInteger:colorCount];
    [[NSUserDefaults standardUserDefaults]setObject:numObj forKey:@"colorCount"];
    [self.navigationController.navigationBar setBarTintColor:colorArr[colorCount]];
}

- (void)reloadData
{
  _dataSource = [[NoteManager sharedManager] readAllNotes];
  [self.tableView reloadData];
}

- (NSMutableArray *)dataSource
{
  if (!_dataSource)
  {
    _dataSource = [[NoteManager sharedManager] readAllNotes];
  }
  return _dataSource;
}

- (void)createTask
{
  NoteDetailController *controller = [[NoteDetailController alloc] init];
  [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - DataSource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  VNNote *note = [self.dataSource objectAtIndex:indexPath.row];
  return [NoteListCell heightWithNote:note];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NoteListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListCell"];
  if (!cell) {
    cell = [[NoteListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ListCell"];
  }
  VNNote *note = [self.dataSource objectAtIndex:indexPath.row];
  cell.index = indexPath.row;
  [cell updateWithNote:note];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:NO];
  VNNote *note = [self.dataSource objectAtIndex:indexPath.row];
    if(note.encryptStr)
    {
        alert = [[SCLAlertView alloc] init];
        txt = [alert addTextField:@"请输入密码"];
        txt.delegate = self;
        txt.secureTextEntry = YES;
        txt.autocorrectionType = UITextAutocorrectionTypeNo;
        txt.autocapitalizationType = UITextAutocapitalizationTypeNone;
       
        [alert addButton:@"确定" actionBlock:^(void) {
            if ([txt.text isEqualToString:note.encryptStr]) {
                [txt resignFirstResponder];
                    NoteDetailController *controller = [[NoteDetailController alloc] initWithNote:note];
                    controller.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:controller animated:YES];
            }else
            {
                SCLAlertView *alert = [[SCLAlertView alloc] init];
                [alert showWarning:self title:@"失败" subTitle:@"密码错误" closeButtonTitle:@"确定" duration:0.0f];
            }
        }];

        [alert showSuccess:self title:@"验证密码" subTitle:@"请输入密码" closeButtonTitle:nil duration:0.0f];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [alert.view addGestureRecognizer:tap];
        UIView *view1 = [alert getShadowView];
        [view1 addGestureRecognizer:tap];
    }
    else
    {
        NoteDetailController *controller = [[NoteDetailController alloc] initWithNote:note];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

//  became first responder
- (void)textFieldDidBeginEditing:(UITextField *)textField;
{
    NSLog(@"became first responder");
     UIView *view1 = [alert getView];
    [UIView animateWithDuration:0.1 animations:^{
        CGRect r = view1.frame;
        r.origin.y = r.origin.y - 70;
        view1.frame =  r;
    }];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    [UIView animateWithDuration:0.1 animations:^{
        UIView *view1 = [alert getView];
        CGRect r = view1.frame;
        r.origin.y = r.origin.y +70;
        view1.frame =  r;
    }];
    return YES;
}

#pragma mark - EditMode

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
  return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    VNNote *note = [self.dataSource objectAtIndex:indexPath.row];
    [[NoteManager sharedManager] deleteNote:note];
    
    [self.dataSource removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
  }
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
@end