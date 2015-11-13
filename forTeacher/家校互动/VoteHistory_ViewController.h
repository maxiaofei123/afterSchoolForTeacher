//
//  VoteHistory_ViewController.h
//  forTeacher
//
//  Created by susu on 15/6/9.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VoteHistory_ViewController : UIViewController
@property(nonatomic,assign)NSString * historyclassID;
@property (nonatomic , copy) void (^addVoteBlock)(NSString *voteId);
@end
