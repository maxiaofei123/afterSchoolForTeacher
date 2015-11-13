//
//  ChangeMessage_ViewController.h
//  forTeacher
//
//  Created by susu on 15/6/8.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UIViewChangeValueDelegate<NSObject>

-(void)headerRefresh;

@end

@interface ChangeMessage_ViewController : UIViewController
@property(nonatomic,strong)NSString * classId;
@property(nonatomic,strong)NSDictionary * conentDic;

@property(nonatomic,assign) NSObject<UIViewChangeValueDelegate> *delegate;
@end
