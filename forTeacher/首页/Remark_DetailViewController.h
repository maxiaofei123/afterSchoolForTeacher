//
//  Remark_DetailViewController.h
//  afterShoolForTeacher
//
//  Created by susu on 15/4/1.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NIDropDown.h"
#import "passDelegate.h"

@interface Remark_DetailViewController : UIViewController <NIDropDownDelegate>

@property(nonatomic,strong)NSString* studentWorkId;
@property(nonatomic,strong)NSString* workPaperId;

@property(nonatomic,assign) NSObject<UIViewPassValueDelegate> *delegate;
@end
