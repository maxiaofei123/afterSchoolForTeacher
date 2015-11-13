//
//  VoteNow_ViewController.h
//  forTeacher
//
//  Created by susu on 15/6/9.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VoteNow_ViewController : UIViewController

@property(nonatomic ,assign)NSString * voteNowClassId;
@property (nonatomic , copy) void (^addVoteBlock)();
@end
