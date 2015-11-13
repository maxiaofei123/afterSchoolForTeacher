//
//  WorkDetail_ViewController.m
//  forTeacher
//
//  Created by susu on 15/6/2.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import "WorkDetail_ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>
#import "LocalPhotoViewController.h"


@interface WorkDetail_ViewController ()<UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,AVAudioSessionDelegate,AVAudioPlayerDelegate,UIScrollViewDelegate,UITextViewDelegate>
{

    UITextView * titleText;
    UITextView *contentText;
    NSMutableArray * btArr;
    NSMutableArray * mp3MutableArr;
    NSMutableArray * imageMutableArr;
    NSMutableArray * vedioMutableArr;
    NSMutableArray * vedioImageMutableArr;
    NSMutableArray * vedioMutableIdArr;
    NSMutableArray *chooseClassNoArr;
    
    NSMutableArray * potoIdMutableArr;
    NSMutableArray * vedioIdMutableArr;
    NSMutableArray * photoImageUrlArr;
    NSMutableArray * deleteVedioZhuangtaiArr;
    
    
    BOOL photoOrvedio;
    UIButton * playMp3;
    int index;
    int typeId;
    NSArray * typeArr;
    UIView * chooseTypeView ;
    NSArray * classNoArr;
    NSMutableArray * classButtonArr;
    NSMutableDictionary * zhuangTaiDic;
    UIButton * deleteWorkBt;
    NSMutableArray * arrVedioPath;
    
    //luyin
    AVAudioPlayer *player;
    AVAudioSession *session;
    NSURL *recordedFile;
    AVAudioRecorder *recorder;
    BOOL isRecording;
    NSString *mp3FilePath;
    NSString * cafPath;
    
    NSTimer *stopTimer;
    NSTimer * shortTimer;
    int   shortTime;
    
    UIScrollView * imageScrollView;
    UIScrollView * vedioScrollView;
    
    NSMutableArray *selectPhotos;
}
@property(strong,nonatomic)UIScrollView * releaseScrollView;
@property(strong,nonatomic)UITableView * chooseClassTable;
@property (nonatomic, retain) AudioStreamer *streamer;
@property (nonatomic,retain) NSMutableArray *items;         //存放本地歌曲
@property (nonatomic,retain) MPMusicPlayerController *mpc;

//record
@property (nonatomic , retain) AVAudioPlayer *player;
@property (nonatomic) BOOL isRecording;
@property (strong, nonatomic)  UIButton *recordButton;
@end

@implementation WorkDetail_ViewController

@synthesize player = _player ;
@synthesize isRecording ;

-(void)viewWillDisappear:(BOOL)animated
{
    [player stop];
    player = nil ;
    
    [_streamer stop];
    _streamer = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:ASStatusChangedNotification
                                                  object:_streamer];
    
    [playMp3 setImage:[UIImage imageNamed:@"playMp3.png"] forState:UIControlStateNormal];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    MainViewController * tabbar = (MainViewController *)self.tabBarController;
    [tabbar showTabBar];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationItem.title = @"查看作业";
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"提交修改   " style:UIBarButtonItemStylePlain target:self action:@selector(commitHomeWorkRelease:)];
    self.navigationItem.rightBarButtonItem=anotherButton;
    
    vedioMutableArr = [[NSMutableArray alloc] init];
    vedioImageMutableArr = [[NSMutableArray alloc] init];
    imageMutableArr = [[NSMutableArray alloc] init];
    mp3MutableArr = [[NSMutableArray alloc] init];
    potoIdMutableArr = [[NSMutableArray alloc] init];
    vedioIdMutableArr = [[NSMutableArray alloc] init];
    photoImageUrlArr = [[NSMutableArray alloc] init];
    vedioMutableIdArr = [[NSMutableArray alloc] init];
    deleteVedioZhuangtaiArr = [[NSMutableArray alloc] init];
    arrVedioPath = [[NSMutableArray alloc] init];
    index = 0 ;
    typeId = 0;
    typeArr = [[NSArray alloc] initWithObjects:@"text",@"image",@"audio",@"video", nil];
    classButtonArr = [[NSMutableArray alloc] init];
  //提交上去的图片和视频
    NSLog(@"lalla =%@",self.workDic);
    
    for (int i = 0; i<typeArr.count; i++) {
        NSString * str = [typeArr objectAtIndex:i];
        NSString * type = [self.workDic objectForKey:@"type"];
        NSLog(@"typr =%@ , str =%@",type,str);
        if ([type isEqualToString:str]) {
            typeId = i;
        }
    }
    chooseClassNoArr = [[NSMutableArray alloc] init];
    for (int i=0; i<[[self.workDic objectForKey:@"classes"] count]; i++) {
       [chooseClassNoArr addObject: [[[self.workDic objectForKey:@"classes"] objectAtIndex:i] objectForKey:@"school_class_id"]];
    }
    for (int i=0 ; i<[[self.workDic objectForKey:@"medias"] count]; i++) {
        NSString * type = [[[self.workDic objectForKey:@"medias"] objectAtIndex:i]objectForKey:@"content_type"];
        NSString * str = [[[self.workDic objectForKey:@"medias"] objectAtIndex:i]objectForKey:@"avatar"];
        if(![str isKindOfClass:[NSNull class]])
        {
            NSRange range = [type rangeOfString:@"/"];
            NSString * rangeType = [type substringToIndex:range.location];
            //                NSLog(@"range =%d =%@",range.location,rangeType);
            if ([rangeType isEqualToString:@"video"]) {
                
                [vedioMutableArr addObject:str];
                [vedioMutableIdArr addObject:[[[self.workDic objectForKey:@"medias"] objectAtIndex:i]objectForKey:@"media_resource_id"]];
                
            }else if ([rangeType isEqualToString:@"audio"]||[rangeType isEqualToString:@"sound"])
            {
                mp3FilePath = str ;
                
            }else if ([rangeType isEqualToString:@"image"])
            {
            
                NSData* data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]] returningResponse:nil error:nil];
                
                UIImage* image = [UIImage imageWithData:data];
                [photoImageUrlArr addObject:str];
                
                [imageMutableArr  addObject:image];

                [potoIdMutableArr addObject: [[[self.workDic objectForKey:@"medias"] objectAtIndex:i]objectForKey:@"media_resource_id"]];

            }
            
        }
    }
    for (int i =0 ; i<vedioMutableArr.count; i++) {

        [vedioImageMutableArr addObject:[UIImage imageNamed:@"test.png"]];
        
        [vedioIdMutableArr addObject: [[[self.workDic objectForKey:@"medias"] objectAtIndex:i]objectForKey:@"media_resource_id"]];
    }
    
    //录音
    AVAudioSession * audioSession = [AVAudioSession sharedInstance];
    
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error: nil];
    [audioSession setActive:YES error: nil];
    
    cafPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/downloadFile.wav"];
    //    NSLog(@"%@",path);
    recordedFile = [[NSURL alloc] initFileURLWithPath:cafPath];
    isRecording = NO;
    
    if(([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
    
    self.items = [NSMutableArray array];
    [self drawtextView];
    [self requestClass];
}

-(void)drawtextView
{
    _releaseScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 0, Main_Screen_Width-20, Main_Screen_Height-64-59)];
    _releaseScrollView.contentSize = CGSizeMake(Main_Screen_Width-20, Main_Screen_Height-49-64);
    _releaseScrollView.backgroundColor = [UIColor whiteColor];
    _releaseScrollView.delegate =self;
    _releaseScrollView.layer.cornerRadius = 5;
    _releaseScrollView.userInteractionEnabled = YES;
    [self.view addSubview:_releaseScrollView];
    
    //输入标题
    UIView * messege = [[UIView alloc] initWithFrame:CGRectMake(10, 10, Main_Screen_Width-40, 50)];
    [messege.layer setBorderColor:[[UIColor colorWithRed:210/255. green:210/255. blue:210/255. alpha:1.] CGColor]];
    [messege.layer setBorderWidth:1];
    [_releaseScrollView addSubview:messege];
    
    UIImageView * image = [[UIImageView alloc] initWithFrame:CGRectMake(5,5, 40, 40)];
    image.image = [UIImage imageNamed:@"wenziLiuyan.png"];
    [messege addSubview:image];
    
    titleText = [[UITextView alloc] initWithFrame:CGRectMake(50, 0, Main_Screen_Width-90, 50)];
    titleText.font = [UIFont systemFontOfSize:16.];
    titleText.delegate = self;
    titleText.tag = 101 ;
    titleText.text = [self.workDic objectForKey:@"title"];
    titleText.backgroundColor = [UIColor clearColor];
    [messege addSubview:titleText];
    
    //输入内容
    contentText = [[UITextView alloc] initWithFrame:CGRectMake(10, 70, Main_Screen_Width-40, 100)];
    contentText.font = [UIFont systemFontOfSize:16.];
    contentText.backgroundColor = [UIColor clearColor];
    contentText.delegate = self;
    contentText.text = [self.workDic objectForKey:@"description"];
    contentText.layer.borderWidth = 1;
    contentText.layer.borderColor = [[UIColor colorWithRed:210/255. green:210/255. blue:210/255. alpha:1.] CGColor];
    [_releaseScrollView addSubview:contentText];
    
    UIToolbar * topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, Main_Screen_Width, 30)];
    [topView setBarStyle:UIBarStyleBlackTranslucent];
    
    UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(2, 5, 50, 25);
    [btn addTarget:self action:@selector(hiddenKey) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"完成" forState:UIControlStateNormal];
    [btn setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc]initWithCustomView:btn];
    NSArray * buttonsArray = [NSArray arrayWithObjects:btnSpace,doneBtn,nil];
    [topView setItems:buttonsArray];
    [titleText setInputAccessoryView:topView];
    [contentText setInputAccessoryView:topView];
    
    //选择上传媒体类型
    for (int i=0; i<2; i++) {
        UIButton * chooseMp3Bt = [[UIButton alloc] initWithFrame:CGRectMake(Main_Screen_Width-115-98*i,180, 90, 30)];
        [chooseMp3Bt setImage:[UIImage imageNamed:[NSString stringWithFormat:@"choose%d.png",i+1]] forState:UIControlStateNormal];
        chooseMp3Bt.tag = 100+i;
        [chooseMp3Bt addTarget:self action:@selector(chooseResourse:) forControlEvents:UIControlEventTouchUpInside];
        [_releaseScrollView addSubview:chooseMp3Bt];
    }
    
    UIView * chooseClassView = [[UIView alloc] initWithFrame:CGRectMake(10, 213, Main_Screen_Width-40, 100)];
    chooseClassView.layer.borderWidth = 1;
    chooseClassView.layer.borderColor = [[UIColor colorWithRed:210/255. green:210/255. blue:210/255. alpha:1.] CGColor];
    [_releaseScrollView addSubview:chooseClassView];
    
    UILabel * classLable = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, 80, 20)];
    classLable.text = @"选择班级:";
    [chooseClassView addSubview:classLable];
    
    _chooseClassTable = [[UITableView alloc] initWithFrame:CGRectMake(90, 0, Main_Screen_Width-100-40, 100)];
    _chooseClassTable.delegate = self;
    _chooseClassTable.dataSource = self;
    _chooseClassTable.backgroundColor = [UIColor clearColor];
    [chooseClassView addSubview:_chooseClassTable];
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [_chooseClassTable setTableFooterView:view];
    
    //录音
    UIView * View = [[UIView alloc] initWithFrame:CGRectMake(10,320, Main_Screen_Width-40, 60)];
    View.layer.borderWidth = 1;
    View.layer.borderColor = [[UIColor colorWithRed:210/255. green:210/255. blue:210/255. alpha:1.] CGColor];
    [_releaseScrollView addSubview:View];
    
    UILabel * lable = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, Main_Screen_Width-160-30, 20)];
    lable.text = @"录音";
    [View addSubview: lable];
    
    playMp3 = [[UIButton alloc] initWithFrame:CGRectMake(View.frame.size.width-60,8, 44, 44)];
    playMp3.tag =1;
    [playMp3 setImage:[UIImage imageNamed:@"playMp3.png"] forState:UIControlStateNormal];
    [playMp3 addTarget:self action:@selector(playRecord:) forControlEvents:UIControlEventTouchUpInside];
    [View addSubview:playMp3];
    _recordButton = [[UIButton alloc] initWithFrame:CGRectMake(View.frame.size.width-120, 8, 44, 44)];
    [_recordButton setImage:[UIImage imageNamed:@"addRecoeder.png"] forState:UIControlStateNormal];
    [_recordButton addTarget:self action:@selector(startStopRecording:) forControlEvents:UIControlEventTouchUpInside];
    if(mp3FilePath.length>0)
    {
        playMp3.enabled = YES;
    }else
    {
        playMp3.enabled = NO;
    }
    [View addSubview:_recordButton];
    
    //作业类型
    chooseTypeView = [[UIView alloc] initWithFrame:CGRectMake(0,320+70,Main_Screen_Width-20, 60)];
    [_releaseScrollView addSubview:chooseTypeView];
    
    UILabel * typeLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 0,120, 20)];
    typeLable.text = @"选择作业类型";
    [chooseTypeView addSubview:typeLable];
    NSArray * arr = [[NSArray alloc] initWithObjects:@"传文字",@"传照片", @"传录音",@"传视频",nil];
    btArr = [[NSMutableArray alloc] init];
    for (int i =0 ; i<4; i++) {
        float w =( Main_Screen_Width-40)/4;
        UIButton * bt = [[UIButton alloc] initWithFrame:CGRectMake(10+w*i, 25, 25, 25)];
        bt.tag = i;
        [bt setImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
        [bt setImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateSelected];
        [bt addTarget:self action:@selector(chooseType:) forControlEvents:UIControlEventTouchUpInside];
        [chooseTypeView addSubview:bt];
        if (i== typeId) {
            bt.selected = YES ;
        }
        UILabel * lable = [[UILabel alloc] initWithFrame:CGRectMake(35+w*i,28, 60, 20)];
        lable.text = [arr objectAtIndex:i];
        lable.alpha = 0.6;
        lable.font = [UIFont systemFontOfSize:14.];
        [chooseTypeView addSubview:lable];
        [btArr addObject:bt];
    }

    deleteWorkBt = [[UIButton alloc] initWithFrame:CGRectMake(10, 320+70+70, self.view.frame.size.width-40, 60)];
    [deleteWorkBt setImage:[UIImage imageNamed:@"deleteWork.png"] forState:UIControlStateNormal];
    [deleteWorkBt addTarget:self action:@selector(deleteWork) forControlEvents:UIControlEventTouchUpInside];
    [_releaseScrollView addSubview:deleteWorkBt];
    
    [self releaseView];
    
}



-(void)releaseView
{
    [imageScrollView removeFromSuperview];
    [vedioScrollView removeFromSuperview];
    int h = 80;

    if (imageMutableArr.count>0) {
        imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,310+h, Main_Screen_Width-20, 110)];
        imageScrollView.showsHorizontalScrollIndicator = NO;
        imageScrollView.backgroundColor = [UIColor whiteColor];
        imageScrollView.contentSize = CGSizeMake(108 * imageMutableArr.count+10,100);
        imageScrollView.delegate =self;
        imageScrollView.pagingEnabled = YES;
        imageScrollView.userInteractionEnabled = YES;
        [_releaseScrollView addSubview:imageScrollView];
        for (int i=0; i<imageMutableArr.count; i++) {
            UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10+110*i,10, 100, 100)];
            imageView.tag = i;
            imageView.userInteractionEnabled = YES;
            // 内容模式
            imageView.clipsToBounds = YES;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            [imageScrollView addSubview:imageView];

                imageView.image = [imageMutableArr objectAtIndex:i];
            
            imageView.tag =i;
            UITapGestureRecognizer *pass1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImage:)];
            [imageView addGestureRecognizer:pass1];
            
            UIButton * bt = [[UIButton alloc] initWithFrame:CGRectMake(90+110*i,0, 30, 30) ];
            [bt setImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
            bt.tag = i ;
            [bt addTarget:self action:@selector(deletePhoto:) forControlEvents:UIControlEventTouchUpInside];
            [imageScrollView addSubview:bt];
        }
        int XX = 110+h;
        h =XX;
        
        if (330+h > Main_Screen_Height-64-59) {
            _releaseScrollView.contentSize = CGSizeMake(Main_Screen_Width-20,320+h+10);
        }
    }
    
    if (vedioMutableArr.count>0) {
        vedioScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,320+h, Main_Screen_Width-20, 110)];
        vedioScrollView.showsHorizontalScrollIndicator = NO;
        vedioScrollView.backgroundColor = [UIColor whiteColor];
        vedioScrollView.contentSize = CGSizeMake(108 * vedioMutableArr.count+10,100);
        vedioScrollView.delegate =self;
        vedioScrollView.pagingEnabled = YES;
        vedioScrollView.userInteractionEnabled = YES;
        [_releaseScrollView addSubview:vedioScrollView];
        
        for (int i=0; i<vedioMutableArr.count; i++) {
            UIImageView * myImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10+110*i, 10, 100, 100)];

            myImageView.image = [vedioImageMutableArr objectAtIndex:i];
 
            [vedioScrollView addSubview:myImageView];
            
            myImageView.backgroundColor = [UIColor colorWithRed:235/255. green:235/255. blue:235/255. alpha:1.];
            UIButton * imageBt = [[UIButton alloc] initWithFrame:CGRectMake(35+108*i,25, 50, 50)];
            [imageBt setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
            imageBt.tag = i;
            [imageBt addTarget:self action:@selector(initMpMOviePlayerHomeWorks:) forControlEvents:UIControlEventTouchUpInside];
            [vedioScrollView addSubview:imageBt];
            
            UIButton * bt = [[UIButton alloc] initWithFrame:CGRectMake(90+110*i,0, 30, 30) ];
            [bt setImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
            bt.tag = i ;
            [bt addTarget:self action:@selector(deleteVedio:) forControlEvents:UIControlEventTouchUpInside];
            [vedioScrollView addSubview:bt];
        }
        int XX = 110+h;
        h =XX;
        
        if (320+h > Main_Screen_Height-64-59) {
            _releaseScrollView.contentSize = CGSizeMake(Main_Screen_Width-20,320+h);
        }
    }
    
    chooseTypeView.frame = CGRectMake(0, 320+h,Main_Screen_Width-20, 50);
    deleteWorkBt.frame = CGRectMake(10, 320+h+70,Main_Screen_Width-40, 60);
    if (320+h+50+70 > Main_Screen_Height-64-59) {
        _releaseScrollView.contentSize = CGSizeMake(Main_Screen_Width-20,320+h+60+70);
    }
}
-(void)deletePhoto:(UIButton *)sender
{
    [imageMutableArr removeObjectAtIndex:sender.tag];
    if (imageMutableArr.count == 0) {
        [imageScrollView removeFromSuperview];
    }
    [self releaseView];
}

- (void)movieImage:(UIImage *)image
{
    [vedioImageMutableArr addObject:image];
}

- (void)movieToImage:(NSString *)mp4Str
{
    NSURL *url = [NSURL URLWithString:mp4Str];
    
    AVURLAsset *asset=[[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform=TRUE;
    CMTime thumbTime = CMTimeMakeWithSeconds(0,30);
    
    AVAssetImageGeneratorCompletionHandler handler =
    ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        if (result != AVAssetImageGeneratorSucceeded) {
        
        
        }//没成功
        
        UIImage *thumbImg = [UIImage imageWithCGImage:im];
        
        [self performSelectorOnMainThread:@selector(movieImage:) withObject:thumbImg waitUntilDone:YES];
        
    };
    
    generator.maximumSize = self.view.frame.size;
    [generator generateCGImagesAsynchronouslyForTimes:
     [NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:handler];
}

-(void)requestClass
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/teachers/%@/school_classes",[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"class =%@",responseObject);
        classNoArr = [responseObject objectForKey:@"school_classes"];
        zhuangTaiDic = [[NSMutableDictionary alloc] init];
        for (int i =0; i<classNoArr.count; i++) {
            [zhuangTaiDic setObject:@"0" forKey:[NSString stringWithFormat:@"%d",i]];
        }
        for (int i=0; i<chooseClassNoArr.count; i++ ) {
            for (int j =0; j<classNoArr.count; j++) {
                
                int xx = [[chooseClassNoArr objectAtIndex:i] intValue];
                
                int jj = [[[classNoArr objectAtIndex:j] objectForKey:@"id"] intValue];
                if (xx == jj) {
                    [zhuangTaiDic setObject:@"1" forKey:[NSString stringWithFormat:@"%d",j]];
                }
            }
        }
        [_chooseClassTable reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(void)commitHomeWorkRelease:(UIButton *)sender
{
    
    NSString * str1;
    NSString * str2 ;
    NSString *classStr =[NSString stringWithFormat:@""];
    NSString * ok = @"请输入消息内容";
    
    if (!([titleText.text isEqualToString:@"输入消息标题"])) {
        if (titleText.text.length>0) {
            str1 = [NSString stringWithFormat:@"%@",titleText.text];
        }
    }
    if (!([contentText.text isEqualToString:@"输入消息内容"])) {
        if (contentText.text.length>0) {
            str2 = [NSString stringWithFormat:@"%@",contentText.text];
        }
    }
    if (str1.length==0 ) {
        ok = @"请输入消息标题";
    }else if (str2.length==0)
    {
        ok = @"请输入消息内容";
    }
    else if (classStr.length<1) {
        ok = @"请选择班级";
    }
    
    for (int i=0; i<zhuangTaiDic.count; i++) {
        NSString *s = [zhuangTaiDic objectForKey:[NSString stringWithFormat:@"%d",i]];
        NSString *t;
        
        t = [NSString stringWithFormat:@"%@",classStr];
        int ss = [s intValue];
        if (ss) {
            classStr = [t stringByAppendingString:[NSString stringWithFormat:@",%@",[[classNoArr objectAtIndex:i] objectForKey:@"id"]]];
        }
    }
//        NSLog(@"str 1 =%@  str2  =%@",str1,str2  );
    if (str1.length >0 && str2.length > 0&&classStr.length>0) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.labelText = @"正在提交...";
        NSDictionary * dic = [[NSDictionary alloc] initWithObjectsAndKeys:titleText.text,@"work_paper[title]",contentText.text,@"work_paper[description]",[typeArr objectAtIndex:typeId],@"work_paper[paper_type]",classStr,@"school_class_ids",nil ];
//        NSLog(@"dic =%@",dic);
        AFHTTPRequestOperationManager * manger = [AFHTTPRequestOperationManager manager];
        [manger PUT:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/work_papers/%@",[self.workDic objectForKey:@"id"]] parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSDictionary * dic =responseObject;
            NSLog(@"dic =%@",responseObject);
            HUD.labelText = @"提交成功。。。";
            [HUD hide:YES afterDelay:1.];
            [self deletePhotos];
            [self  deleteVedioForId ];
            [self creatMedia:[[dic objectForKey:@"work_paper"] objectForKey:@"id"]];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error =%@ ",error);
            HUD.labelText = @"请求失败,请检查网络链接";
            [HUD hide:YES afterDelay:1.];
        }];
    }else
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:ok delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}

-(void)creatMedia:(NSString *)workId
{
    int count = imageMutableArr.count + mp3MutableArr.count  + vedioMutableArr.count;
    if (count>0) {
        for (int i =0; i<imageMutableArr.count; i++) {
                AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
                [manager POST:[NSString stringWithFormat: @"http://114.215.125.31/api/v1/work_papers/%@/media_resources",workId] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData){

                        NSData *imageData =UIImageJPEGRepresentation([imageMutableArr objectAtIndex:i], 0.5);
                        [formData appendPartWithFileData:imageData name:@"media_resource[avatar]"fileName:[NSString stringWithFormat:@"anyImage_%d.jpg",i+1] mimeType:@"image/jpeg"];
                    
                 
                } success:^(AFHTTPRequestOperation *operation, id responseObject)
                 {
                     NSDictionary * dic =responseObject;
                     NSLog(@"dic =%@",dic);
                     HUD.labelText = @"提交成功。。。";
                     [HUD hide:YES afterDelay:1.];
                     
                 }failure:^(AFHTTPRequestOperation *operation, NSError *error){
                     NSLog(@"error =%@ ",error);
                     HUD.labelText = @"请求超时";
                     [HUD hide:YES afterDelay:1.];
                 }  ];
            
        }
        if (mp3FilePath.length > 0) {
            if([mp3FilePath rangeOfString:@"http://"].location !=NSNotFound){
                
            }else{
            AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
            [manager POST:[NSString stringWithFormat: @"http://114.215.125.31/api/v1/work_papers/%@/media_resources",workId] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData){

                    if ([self audio_PCMtoMP3])
                    {
                        NSData * mp3data = [NSData dataWithContentsOfFile:mp3FilePath];
                        [formData appendPartWithFileData:mp3data name:@"media_resource[avatar]"fileName:[NSString stringWithFormat:@"anyaudio.mp3"] mimeType:@"audio/mp3"];
                    }
                
            } success:^(AFHTTPRequestOperation *operation, id responseObject)
             {
                 NSDictionary * dic =responseObject;
                 NSLog(@"dic =%@",dic);
                 //清楚写入的 caf mp3
                 NSFileManager * caffileManager = [[NSFileManager alloc]init];
                 [caffileManager removeItemAtPath:cafPath error:nil];
                 NSFileManager * mp3fileManager = [[NSFileManager alloc]init];
                 [mp3fileManager removeItemAtPath:mp3FilePath error:nil];
                 
                 HUD.labelText = @"提交成功。。。";
                 [HUD hide:YES afterDelay:1.];
                 
             }failure:^(AFHTTPRequestOperation *operation, NSError *error){
                 NSLog(@"error =%@ ",error);
                 HUD.labelText = @"请求超时";
                 [HUD hide:YES afterDelay:1.];
             }  ];
            }
            
        }
        
        for (int i =0; i<arrVedioPath.count; i++) {

                AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
                [manager POST:[NSString stringWithFormat: @"http://114.215.125.31/api/v1/work_papers/%@/media_resources",workId] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData){

                        NSData * mp4data = [NSData dataWithContentsOfFile:[arrVedioPath objectAtIndex:i]];
                    
                        [formData appendPartWithFileData:mp4data name:@"media_resource[avatar]"fileName:[NSString stringWithFormat:@"anyVideo_%d.mp4",i+1] mimeType:@"video/mp4"];
                    
                } success:^(AFHTTPRequestOperation *operation, id responseObject)
                 {
                     NSDictionary * dic =responseObject;
                     NSLog(@"dic =%@",dic);
                     HUD.labelText = @"提交成功。。。";
                     [HUD hide:YES afterDelay:1.];
                     
                 }failure:^(AFHTTPRequestOperation *operation, NSError *error){
                     NSLog(@"error =%@ ",error);
                     HUD.labelText = @"请求超时";
                     [HUD hide:YES afterDelay:1.];
                 }  ];
            }
        
        [self.delegate headerRefresh];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        HUD.labelText = @"提交成功。。。";
        [HUD hide:YES afterDelay:1.];
    }
    
}

//tableView

//指定有多少个分区(Section)，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//指定每个分区中有多少行，默认为1
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return classNoArr.count;
}

//绘制Cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *tableSampleIdentifier = @"TableSampleIdentifier";
    
    UITableViewCell * cell =  [tableView dequeueReusableCellWithIdentifier:tableSampleIdentifier];
    [cell removeFromSuperview];
    if (cell ==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableSampleIdentifier];
    }else
    {
        [cell removeFromSuperview];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableSampleIdentifier];
        
    }
    cell.backgroundColor = [UIColor clearColor];
    
    if (classNoArr.count > 0) {
        int zhuangTai = [[zhuangTaiDic objectForKey:[NSString stringWithFormat:@"%d",indexPath.row]] intValue];
        
        UIButton * classBt = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
        classBt.tag = indexPath.row;
        [classBt setImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
        [cell.contentView addSubview:classBt];
        [classBt setImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateSelected];
        [classButtonArr addObject:classBt];
        
        if (zhuangTai) {
            classBt.selected = YES;
        }else {
            classBt.selected = NO;
        }
        
        UILabel * classLable = [[UILabel alloc] initWithFrame:CGRectMake(50, 5, Main_Screen_Width-50-40, 30)];
        classLable.text = [[classNoArr objectAtIndex:indexPath.row] objectForKey:@"class_no"];
        [cell.contentView addSubview:classLable];
    }
    
    return cell;
}

//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    int zhuangTai = [[zhuangTaiDic objectForKey:[NSString stringWithFormat:@"%d",indexPath.row]] intValue];
    if (zhuangTai) {
        [zhuangTaiDic setObject:@"0" forKey:[NSString stringWithFormat:@"%d",indexPath.row]];
    }else
    {
        [zhuangTaiDic setObject:@"1" forKey:[NSString stringWithFormat:@"%d",indexPath.row]];
    }
    
    //刷新tableView单行数据；
    NSIndexPath * index3 = [NSIndexPath indexPathForItem:indexPath.row inSection:0];
    NSArray * array = [NSArray arrayWithObject:index3];
    [_chooseClassTable reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationAutomatic];
}


#pragma mark - recording
- (void)startStopRecording:(id)sender
{
    if(!isRecording)
    {
        stopTimer = [NSTimer scheduledTimerWithTimeInterval:180 target:self selector:@selector(stoprecord) userInfo:nil repeats:NO];
        shortTimer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(shortTime) userInfo:nil repeats:NO];
        shortTime = 0;
        
        NSLog(@"正在录音......");
        session = [AVAudioSession sharedInstance];
        //        session.delegate = self;
        NSError *sessionError;
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
        if(session == nil)
            NSLog(@"Error creating session: %@", [sessionError description]);
        else
            [session setActive:YES error:nil];
        //录音设置
        NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
        //录音格式 无法使用
        [settings setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey: AVFormatIDKey];
        //采样率
        [settings setValue :[NSNumber numberWithFloat:44100.0] forKey: AVSampleRateKey];//44100.0
        //通道数
        [settings setValue :[NSNumber numberWithInt:2] forKey: AVNumberOfChannelsKey];
        //线性采样位数
        [settings setValue :[NSNumber numberWithInt:16] forKey: AVLinearPCMBitDepthKey];
        //音频质量,采样质量
        [settings setValue:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
        
        isRecording = YES;
        [self.recordButton setImage:[UIImage imageNamed:@"record.png"] forState:UIControlStateNormal];
        [playMp3 setEnabled:NO];
        
        recorder = [[AVAudioRecorder alloc] initWithURL:recordedFile settings:nil error:nil];
        [recorder prepareToRecord];
        [recorder record];
        player = nil;
        
    }
    else
    {
        [self stoprecord];
    }
}

-(void)shortTime
{
    shortTime = 1;
    [stopTimer invalidate];
    stopTimer=nil;
}

-(void)stoprecord
{
    //取消录音
    if (shortTime ==1) {
        NSLog(@"录音结束......");
        isRecording = NO;
        [self.recordButton setImage:[UIImage imageNamed:@"addRecoeder.png"] forState:UIControlStateNormal];
        [playMp3 setEnabled:YES];
        isRecording = NO;
        [recorder stop];
        if (recorder) {
            recorder = nil;
            AVAudioSession * audioSession = [AVAudioSession sharedInstance];
            [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error: nil];
            
            UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
            AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
            UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
            AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
            NSError *playerError;
            player = [[AVAudioPlayer alloc] initWithContentsOfURL:recordedFile error:&playerError];
            if (player == nil)
            {
                NSLog(@"ERror creating player: %@", [playerError description]);
            }
            player.delegate = self;
        }
        [mp3MutableArr addObject:recordedFile];
        
    }else
    {
        [stopTimer invalidate];
        stopTimer=nil;
        
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.labelText = @"录制时间少于4秒请重新录制";
        [HUD hide:YES afterDelay:1];
        [playMp3 setEnabled:NO];
        [self.recordButton setImage:[UIImage imageNamed:@"addRecoeder.png"] forState:UIControlStateNormal];
        [recorder stop];
        isRecording = NO;
    }
}

-(void)playRecord:(UIButton *)sender
{
   
    if([mp3FilePath rangeOfString:@"http://"].location !=NSNotFound)//网络音频播放
    {
        if (!_streamer) {
            _streamer= [[AudioStreamer alloc] initWithURL:[NSURL URLWithString:mp3FilePath]];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(paperWorkPlaybackStateChanged:)
                                                         name:ASStatusChangedNotification
                                                       object:_streamer];
        }
       if ([_streamer isPlaying])
       {
           [_streamer pause];
           [playMp3 setImage:[UIImage imageNamed:@"playMp3.png"] forState:UIControlStateNormal];
       }else
       {
           [_streamer start];
           [self.recordButton setEnabled:NO];
           [playMp3 setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
       }
    }else {
        if([player isPlaying])
        {
            [player pause];
            [self.recordButton setEnabled:YES];
            [playMp3 setImage:[UIImage imageNamed:@"playMp3.png"] forState:UIControlStateNormal];
            
        }else
        {
            
            [player play];
            [self.recordButton setEnabled:NO];
            [playMp3 setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        }
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self.recordButton setEnabled:YES];
    self.player = nil;
    [playMp3 setImage:[UIImage imageNamed:@"playMp3.png"] forState:UIControlStateNormal];
}

- (void)paperWorkPlaybackStateChanged:(NSNotification *)notification
{
    if ([_streamer isWaiting])
    {
        [playMp3 setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        
    } else if ([_streamer isIdle]) {
        [_streamer stop];
        _streamer = nil;
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:ASStatusChangedNotification
                                                      object:_streamer];
        
        [playMp3 setImage:[UIImage imageNamed:@"playMp3.png"] forState:UIControlStateNormal];
        
    } else if ([_streamer isPaused]) {//暂停
        //        [_streamer stop];
        [playMp3 setImage:[UIImage imageNamed:@"playMp3.png"] forState:UIControlStateNormal];
        
    } else if ([_streamer isPlaying] || [_streamer isFinishing]) {
        
        [playMp3 setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        
    } else {
        
    }
}

- ( BOOL)audio_PCMtoMP3
{
    NSString *cafFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/downloadFile.wav"];
    mp3FilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/downloadFile.mp3"];
    NSFileManager* fileManager=[NSFileManager defaultManager];
    if([fileManager removeItemAtPath:mp3FilePath error:nil])
    {
        
    }
    @try {
        int read, write;
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 22050.0);
        lame_set_VBR(lame, vbr_default);
        
        lame_init_params(lame);
        // mp3压缩参数
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    return YES;
}


- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView.tag ==101) {
        
        if ( [titleText.text isEqualToString:@"输入消息标题"]) {
            titleText.text = @"";
        }
        
    }else if ( [contentText.text isEqualToString:@"输入消息内容"]) {
        contentText.text = @"";
    }
}




-(void)chooseType:(UIButton *)sender
{
    for (int i=0; i<4; i++) {
        UIButton * button = [btArr objectAtIndex:i];
        button.selected = NO;
        if (sender.tag ==i) {
            button.selected = YES;
            typeId = i;
        }
    }
}

#pragma mark -choosePhotosAndVedio

-(void)deletePhotos
{
    for (int i=0; i<potoIdMutableArr.count; i++) {
            
            AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
            [manager DELETE:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/work_papers/%@/media_resources/%@",[self.workDic objectForKey:@"id"],[potoIdMutableArr objectAtIndex:i]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
            }];
            
    }

}

-(void)deleteVedioForId
{
    for (int i=0; i<deleteVedioZhuangtaiArr.count; i++) {
        NSString * vid = [[deleteVedioZhuangtaiArr objectAtIndex:i] objectForKey:@"id"];
        AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
        [manager DELETE:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/work_papers/%@/media_resources/%@",[self.workDic objectForKey:@"id"],vid] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
}

-(void)deleteVedio:(UIButton *)sender
{
    if([[vedioMutableArr objectAtIndex:sender.tag] rangeOfString:@"http://"].location !=NSNotFound){
        NSDictionary * dic = @{@"id":[vedioMutableIdArr objectAtIndex:sender.tag]};
        [vedioMutableIdArr removeObjectAtIndex:sender.tag];
        [deleteVedioZhuangtaiArr  addObject:dic];
    }
    
    [vedioMutableArr removeObjectAtIndex:sender.tag];
    if (vedioMutableArr.count == 0) {
        [vedioScrollView removeFromSuperview];
    }
    [self releaseView];
}

-(void)deleteWork
{
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.labelText = @"正在删除...";
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    [manager DELETE:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/work_papers/%@",[self.workDic objectForKey:@"id"]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        HUD.labelText = @"删除成功";
        [HUD hide:YES ];
        [self.delegate headerRefresh];
        [self.navigationController popToRootViewControllerAnimated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        HUD.labelText = @"删除失败";
        [HUD hide:YES afterDelay:1.];
    }];
}

-(void)chooseResourse:(UIButton *)sender
{
    switch (sender.tag) {
        case 101:
        {
            UIActionSheet *sheet =[[UIActionSheet alloc]initWithTitle:@"选择图片来源" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"从相册中选择",@"摄像头拍摄",@"取消", nil];
            sheet.tag =101;
            [sheet showInView:[UIApplication sharedApplication].keyWindow];
        }
            break;
            
        case 102:
        {
            
            
        }
            break;
            
        case 100:
        {
            UIActionSheet *sheet =[[UIActionSheet alloc]initWithTitle:@"选择视频来源" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"从相册中选择",@"摄像头拍摄",@"取消", nil];
            sheet.tag =103;
            [sheet showInView:[UIApplication sharedApplication].keyWindow];
        }
            break;
            
        default:
            break;
    }
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag ==101) {
        
        switch (buttonIndex) {
            case 1:
            {
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
                    UIImagePickerController *imgPicker = [UIImagePickerController new];
                    imgPicker.delegate = self;
                    imgPicker.allowsEditing= NO;//获取原始图片不允许编辑
                    imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    [self presentViewController:imgPicker animated:YES completion:nil];
                    return;
                }
                else {
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                        message:@"该设备没有摄像头"
                                                                       delegate:self
                                                              cancelButtonTitle:nil
                                                              otherButtonTitles:@"好", nil];
                    [alertView show];
                    
                }
            }
                break;
            case 0:
            {
                photoOrvedio = NO ;
                LocalPhotoViewController *pick=[[LocalPhotoViewController alloc] init];
                self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:nil action:nil];
                pick.selectPhotoDelegate=self;
                pick.selectPhotos=selectPhotos;
                
                [self.navigationController pushViewController:pick animated:YES];
            }
                break;
            default:
                break;
        }
        
    }else if (actionSheet.tag ==103)
    {
        switch (buttonIndex) {
            case 1:
            {
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
                    UIImagePickerController *imgPicker = [UIImagePickerController new];
                    imgPicker.delegate = self;
                    imgPicker.allowsEditing= NO;
                    imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    imgPicker.cameraDevice=UIImagePickerControllerCameraDeviceRear;//设置使用哪个摄像头，这里设置为后置摄像头
                    imgPicker.mediaTypes=@[(NSString *)kUTTypeMovie];
                    imgPicker.videoQuality=UIImagePickerControllerQualityTypeIFrame960x540;//视频质量设置
                    //                    imgPicker.videoQuality=UIImagePickerControllerQualityTypeIFrame1280x720;
                    imgPicker.cameraCaptureMode=UIImagePickerControllerCameraCaptureModeVideo;//设置摄像头模式（拍照，录制视频）
                    imgPicker.videoMaximumDuration = 60.0f;//设置最长录制1分钟
                    [self presentViewController:imgPicker animated:YES completion:nil];
                    return;
                }
                else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                        message:@"该设备没有摄像头"
                                                                       delegate:self
                                                              cancelButtonTitle:nil
                                                              otherButtonTitles:@"好", nil];
                    [alertView show];
                    
                }
            }
                break;
            case 0:
            {
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.allowsEditing = YES;
                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:( NSString *)kUTTypeMovie];
                [imagePicker setMediaTypes:mediaTypes];
                photoOrvedio = YES;
                [self presentViewController:imagePicker animated:YES completion:nil];
                
                //                photoOrvedio = YES ;
                //                LocalPhotoViewController *pick=[[LocalPhotoViewController alloc] init];
                //                self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:nil action:nil];
                //                pick.selectPhotoDelegate=self;
                //                pick.selectPhotos=selectPhotos;
                //
                //                [self.navigationController pushViewController:pick animated:YES];
            }
                break;
        }
    }
}

-(void)getSelectedPhoto:(NSMutableArray *)photos{
    selectPhotos=photos;
    for (int i=0; i<selectPhotos.count; i++) {
        ALAsset *asset=[selectPhotos objectAtIndex:i];
        CGImageRef posterImageRef=[asset thumbnail];
        UIImage *posterImage=[UIImage imageWithCGImage:posterImageRef];
        [imageMutableArr addObject:posterImage];
    }
    NSLog(@"供选择%d张照片 imageArr =%@",[photos count],imageMutableArr);
    [self releaseView];
}

#pragma end

#pragma mark - UIImagePickerController代理方法
//完成
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {//如果是拍照
        if(photoOrvedio)
        {
            UIImage * image =info[UIImagePickerControllerOriginalImage];
            [imageMutableArr addObject:image];
            [self releaseView];
            photoOrvedio = NO;
        }else {
            UIImage *image;
            image=[info objectForKey:UIImagePickerControllerOriginalImage];//获取原始照片
            [imageMutableArr addObject:image];
            [self releaseView];
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);//保存到相簿
        }
    }else if([mediaType isEqualToString:(NSString *)kUTTypeMovie]){//如果是录制视频
        if (photoOrvedio ) {
            photoOrvedio = NO;
            NSURL *url=[info objectForKey:UIImagePickerControllerMediaURL];//视频路径
            NSLog(@"选取的视频路径 =%@",url);
            [self movToMp4:url];
        }else
        {
            NSURL *url1=[info objectForKey:UIImagePickerControllerMediaURL];//视频路径
            NSLog(@"保存视频 url＝%@",url1);
            [self movToMp4:url1];
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
        self.modalPresentationStyle=UIModalPresentationOverCurrentContext;
    }
}

-(void)movToMp4:(NSURL *)videoURL
{
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyyMMddHHmmss"];
    NSString * mp4Path = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@.mp4", [formater stringFromDate:[NSDate date]]];
    //    NSLog(@"mp4Path =%@",_mp4Path);
    if ([compatiblePresets containsObject:AVAssetExportPresetLowQuality])
    {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPresetLowQuality];
        //大小是5M多点，如果是Low则为600KB左右,一般选取Medium即可
        exportSession.outputURL = [NSURL fileURLWithPath:mp4Path];
        exportSession.outputFileType = AVFileTypeMPEG4;
        //
        CMTime start = CMTimeMakeWithSeconds(0, 600);
        CMTime duration = CMTimeMakeWithSeconds(60.0, 600);
        CMTimeRange range = CMTimeRangeMake(start, duration);//剪切视频
        exportSession.timeRange = range;
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"转换失败: %@", [[exportSession error] localizedDescription]);
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export canceled");
                    break;
                case AVAssetExportSessionStatusCompleted:
                {
                    
                    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(mp4Path)) {
                        //保存视频到相簿，注意也可以使用ALAssetsLibrary来保存
                        UISaveVideoAtPathToSavedPhotosAlbum(mp4Path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);//保存视频到相簿
                    }
                    
                }
                    break;
                default:
                    break;
            }
        }];
    }
    
}

//视频保存后的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        NSLog(@"保存视频过程中发生错误，错误信息:%@",error.localizedDescription);
    }else{
        NSLog(@"视频保存成功");
        //获取视频首张图片
        NSURL *url=[NSURL fileURLWithPath:videoPath];
        [vedioImageMutableArr addObject:[self requestFirstImage:url]];
        NSString * str = [url absoluteString];
        [ vedioMutableArr addObject:str];
        [arrVedioPath addObject:url];
        [self releaseView];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(UIImage *)requestFirstImage:(NSURL *)url
{
    //获取视频首张图片
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return thumb;
}


#pragma mark - playMovieAndShowPigPhoto

-(void)initMpMOviePlayerHomeWorks:( UIButton  *)sender
{
    NSLog(@"url =%@",[vedioMutableArr objectAtIndex:sender.tag]);
    MPMoviePlayerViewController  *moviePlayer =[[ MPMoviePlayerViewController alloc ]  initWithContentURL :[NSURL URLWithString:[vedioMutableArr objectAtIndex:sender.tag]]];
    
    [self createMPPlayerController:moviePlayer];
}

-(void)initRequestMpMOviePlayerHomeWorks:( UIButton  *)sender
{
    MPMoviePlayerViewController  *moviePlayer =[[ MPMoviePlayerViewController alloc ]  initWithContentURL :[NSURL URLWithString:[vedioMutableArr objectAtIndex:sender.tag]]];
    [self createMPPlayerController:moviePlayer];
}

- ( void )createMPPlayerController:( MPMoviePlayerViewController  *)moviePlayer {
    
    [moviePlayer. moviePlayer   prepareToPlay ];
    
    [ self   presentMoviePlayerViewControllerAnimated :moviePlayer]; // 这里是presentMoviePlayerViewControllerAnimated
    
    [moviePlayer. moviePlayer   setControlStyle : MPMovieControlStyleFullscreen ];
    
    [moviePlayer. view   setBackgroundColor :[ UIColor   clearColor ]];
    
    [moviePlayer. view   setFrame : self . view . bounds ];
    
    [[ NSNotificationCenter   defaultCenter ]  addObserver : self
     
                                                  selector : @selector (movieFinishedCallback:)
     
                                                      name : MPMoviePlayerPlaybackDidFinishNotification
     
                                                    object :moviePlayer. moviePlayer ];
    
    
}

-( void )movieStateChangeCallback:( NSNotification *)notify  {
    
    //点击播放器中的播放/ 暂停按钮响应的通知
}

-( void )movieFinishedCallback:( NSNotification *)notify{
    
    // 视频播放完或者在presentMoviePlayerViewControllerAnimated下的Done按钮被点击响应的通知。
    
    MPMoviePlayerController * theMovie = [notify  object ];
    
    [[ NSNotificationCenter   defaultCenter ]  removeObserver : self
     
                                                         name : MPMoviePlayerPlaybackDidFinishNotification
     
                                                       object :theMovie];
    
    [ self   dismissMoviePlayerViewControllerAnimated ];
}

- (void) tapImage:(UITapGestureRecognizer *)tap
{
//    int count = imageMutableArr.count;
//    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
//    for (int i = 0; i<count; i++) {
//        // 替换为中等尺寸图片
//        MJPhoto *photo = [[MJPhoto alloc] init];
//        photo.srcImageView.image = [imageMutableArr objectAtIndex:i];
//        [photos addObject:photo];
//    }
//    
//    // 2.显示相册
//    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
//    browser.currentPhotoIndex = tap.view.tag;
//    
//    // 弹出相册时显示的第一张图片是？
//    browser.photos = photos; // 设置所有的图片
//    [browser show];
}

-(void)hiddenKey
{
    [titleText resignFirstResponder];
    [contentText resignFirstResponder];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
