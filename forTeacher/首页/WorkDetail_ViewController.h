//
//  WorkDetail_ViewController.h
//  forTeacher
//
//  Created by susu on 15/6/2.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "passDelegate.h"

@interface WorkDetail_ViewController : UIViewController

@property(nonatomic,strong)NSDictionary * workDic;
@property(nonatomic,assign) NSObject<UIViewPassValueDelegate> *delegate;
@end
