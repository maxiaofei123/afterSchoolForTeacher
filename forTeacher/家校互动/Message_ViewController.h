//
//  Message_ViewController.h
//  afterShoolForTeacher
//
//  Created by susu on 15/4/17.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKSTableView.h"
@interface Message_ViewController : UIViewController<SKSTableViewDelegate>

@property(nonatomic,strong)NSString * classId;
@property (nonatomic, strong)  SKSTableView *messageTableView;

@end
