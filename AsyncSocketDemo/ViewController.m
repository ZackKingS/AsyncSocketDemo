//
//  ViewController.m
//  AsyncSocketDemo
//
//  Created by Damon on 16/8/30.
//  Copyright © 2016年 Damon. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"
#import <AVFoundation/AVFoundation.h>
enum{
    SOCKET_OFFLINE_SERVER = -2,//服务器断开
    SOCKET_OFFLINE_USER,       //用户主动断开
};

@interface ViewController ()
//@property(strong,nonatomic)  dispatch_source_t timer;


@end
void EMSystemSoundFinishedPlayingCallback(SystemSoundID sound_id, void* user_data)
{
    AudioServicesDisposeSystemSoundID(sound_id);
}
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    [self setup];
    
    
}



// 播放接收到新消息时的声音
- (SystemSoundID)playNewMessageSound
{
    // 要播放的音频文件地址
    //    NSURL *bundlePath = [[NSBundle mainBundle] URLForResource:@"EaseUIResource" withExtension:@"bundle"];
    //    NSURL *audioPath = [[NSBundle bundleWithURL:bundlePath] URLForResource:@"in" withExtension:@"caf"];
    
    NSString *str = [[NSBundle  mainBundle]pathForResource:@"in.caf" ofType:nil];
    
    NSURL* audioPath =[NSURL URLWithString:str];
    
    // 创建系统声音，同时返回一个ID
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(audioPath), &soundID);
    // Register the sound completion callback.
    AudioServicesAddSystemSoundCompletion(soundID,
                                          NULL, // uses the main run loop
                                          NULL, // uses kCFRunLoopDefaultMode
                                          EMSystemSoundFinishedPlayingCallback, // the name of our custom callback function
                                          NULL // for user data, but we don't need to do that in this case, so we just pass NULL
                                          );
    
    AudioServicesPlaySystemSound(soundID);
    
    
    
    return soundID;
}

// 震动
- (void)playVibration
{
    // Register the sound completion callback.
    AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate,
                                          NULL, // uses the main run loop
                                          NULL, // uses kCFRunLoopDefaultMode
                                          EMSystemSoundFinishedPlayingCallback, // the name of our custom callback function
                                          NULL // for user data, but we don't need to do that in this case, so we just pass NULL
                                          );
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

-(void)tcpTest:(UIButton*)sender
{
    NSLog(@"tcpTest");
    self.myTcpSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self tcpConnetwithData:[NSString stringWithFormat:@"%d",(int)sender.tag]];
    [self.mySocketArray addObject: self.myTcpSocket];
}

-(void)tcpConnetwithData:(NSString*)userData
{
    [self.myTcpSocket setUserData:userData];
    
    NSError *error = nil;
    if (![ self.myTcpSocket connectToHost:@"hudongdong.com" onPort:80 withTimeout:2.0f error:&error]) {
        NSLog(@"error:%@",error);
    }
    
    //    NSError *error = nil;
    //    if (![ self.myTcpSocket connectToHost:@"192.168.1.143" onPort:12345 withTimeout:2.0f error:&error]) {
    //        NSLog(@"error:%@",error);
    //    }
    
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"didConnectToHost");
    
    //////****  1      ****////
    //连上之后可以每隔30s发送一次心跳包
    //        self.mytime =[NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(heartbeatFunc) userInfo:nil repeats:YES];
    //        [self.mytime fire];
    
    
    //////****  2      ****////
    //    NSRunLoop *currentRunloop = [NSRunLoop currentRunLoop];
    //    [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(runn) userInfo:nil repeats:YES];
    //    [currentRunloop run];
    
    
    
    //////****  3      ****////
    
    
    //    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    //    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    //    dispatch_source_set_event_handler(timer, ^{
    //        NSLog(@"GCD---%@",[NSThread currentThread]);
    //
    //        //心跳包的内容是前后端自定义的
    //        NSString *heart = @"Damon";
    //        NSData *data= [heart dataUsingEncoding:NSUTF8StringEncoding];
    //        [self.myTcpSocket writeData:data withTimeout:10.0f tag:0];
    //    });
    //
    //    //4.启动执行
    //    dispatch_resume(timer);
    //
    //    //5.用强指针引用 定时器（保证其不被销毁）
    //    self.timer = timer;
    
    
    
    //////****  4     ****////
    
    [self startTime];
    
    UIApplication*   app = [UIApplication sharedApplication];
    __block    UIBackgroundTaskIdentifier bgTask;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    });
    
    
    
    
    
}


- (void)startTime{
    
    
    __block int timeout = 60; //倒计时时间
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),3.0*NSEC_PER_SEC, 0); //每秒执行
    
    dispatch_source_set_event_handler(_timer, ^{
        
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //定时结束后的UI处理
            });
        }else{
            
            //心跳包的内容是前后端自定义的
            NSString *heart = @"Damon";
            NSData *data= [heart dataUsingEncoding:NSUTF8StringEncoding];
            [self.myTcpSocket writeData:data withTimeout:10.0f tag:timeout];
            
            
            NSLog(@"时间 = %d",timeout);
            NSString *strTime = [NSString stringWithFormat:@"发送验证码(%dS)",timeout];
            NSLog(@"strTime = %@",strTime);
            dispatch_async(dispatch_get_main_queue(), ^{
                //定时过程中的UI处理
            });
            
            timeout--;
        }
    });
    dispatch_resume(_timer);
    
}

//向服务器发送完数据之后回调
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"have send");
    
    
    [self run:(long)tag];
    
    if (tag == 1) {
        NSLog(@"first send");
    }
    else if (tag ==2){
        NSLog(@"second send");
    }
}

-(void)run:(long)tag
{
    
    
    
    
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];  //30秒后推送
    
    //        localNotification.fireDate = [NSDate date];  //30秒后推送
    localNotification.timeZone = [NSTimeZone localTimeZone];
    localNotification.userInfo = @{
                                   @"name":@"the Name",
                                   @"id":@"0",
                                   };
    localNotification.alertBody = @"alertBody";
    localNotification.alertTitle = [NSString stringWithFormat:@"%ld",tag];
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification]; //注入系统
    
    
    
    [self playVibration];
    
    [self playNewMessageSound];
    
    //后台播放声音
    
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    
    
}



//发送心跳包
-(void)heartbeatFunc
{
    //心跳包的内容是前后端自定义的
    NSString *heart = @"Damon";
    NSData *data= [heart dataUsingEncoding:NSUTF8StringEncoding];
    [self.myTcpSocket writeData:data withTimeout:10.0f tag:0];
}


-(void)runn
{
    //心跳包的内容是前后端自定义的
    NSString *heart = @"Damon";
    NSData *data= [heart dataUsingEncoding:NSUTF8StringEncoding];
    [self.myTcpSocket writeData:data withTimeout:10.0f tag:0];
}



-(void)tcpOtherTest:(UIButton*)sender
{
    GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [socket setUserData:[NSString stringWithFormat:@"%d",(int)sender.tag]];
    [self.mySocketArray addObject:socket];
    
    NSError *error = nil;
    //    if (![socket connectToHost:@"hudongdong.com" onPort:80 withTimeout:2 error:&error]) {
    //        NSLog(@"error:%@",error);
    //    }
    
    if (![socket connectToHost:@"192.168.3.148" onPort:5656 withTimeout:2 error:&error]) {
        NSLog(@"error:%@",error);
    }
}

-(void)udpTest:(UIButton*)sender
{
    NSLog(@"udpTest");
    
}

-(void)disConnectSocket
{
    for (GCDAsyncSocket *socket in self.mySocketArray) {
        socket.userData = [NSString stringWithFormat:@"%d",SOCKET_OFFLINE_USER];
        [self.mytime invalidate];   //停止心跳包发送
        [socket disconnect];    //断开链接
    }
    
}




//发送数据
-(void)sendData
{
    NSString *dataStr = @"Damon_Hu";
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    [self.myTcpSocket writeData:data withTimeout:10.0f tag:1];
    
    NSString *dataStr2 = @"Damon_Hu2";
    NSData *data2 = [dataStr2 dataUsingEncoding:NSUTF8StringEncoding];
    [self.myTcpSocket writeData:data2 withTimeout:10.0f tag:2];
}
//接受数据
-(void)reciveData:(NSData*)data
{
    //接收到的数据写入本地
    NSLog(@"%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
}

#pragma mark  GCDAsyncSocketDelegate
//连接


//断开连接
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err
{
    NSLog(@"socketDidDisconnect");
    //主动断开
    if ([sock.userData isEqualToString:[NSString stringWithFormat:@"%d",SOCKET_OFFLINE_USER]]) {
        return;
    }
    else{
        NSLog(@"%@",err);
        //断线重连
        [self tcpConnetwithData:@"1"];
    }
}



//多链接
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    NSLog(@"userData:%@",[newSocket userData]);
}


-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    
    UILocalNotification *notification = [[UILocalNotification alloc]init];
    NSDate * pushDate = [NSDate date];
    notification.fireDate = pushDate;
    notification.alertAction = @"open";
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.repeatInterval = 0;
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.alertBody = @"123123";
    NSDictionary * inforDic = [NSDictionary dictionaryWithObject:@"name" forKey:@"localNoti"];
    notification.userInfo =inforDic;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    UIApplication *application = [UIApplication sharedApplication];
    if (application.applicationIconBadgeNumber >= 0 && application.applicationIconBadgeNumber <99) {
        application.applicationIconBadgeNumber += 1;
    }else if (application.applicationIconBadgeNumber >=99){
        application.applicationIconBadgeNumber = 99;
    }
    
}


//本地接收到数据之后回调
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    [self.myTcpSocket readDataWithTimeout:10.0f tag:tag];
    //接受到数据之后写入本地
    [self reciveData:data];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setup{
    
    
    
    
    
    self.mySocketArray =[[NSMutableArray alloc] init];
    //可以使用自动布局
    UIEdgeInsets padding = UIEdgeInsetsMake(50, 50, 10, -50);
    UIButton *button = [[UIButton alloc] init];
    [self.view addSubview:button];
    [button setTag:1];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(padding.top);
        make.left.equalTo(self.view.mas_left).with.offset(padding.left);
    }];
    [button setTitle:@"TCP测试" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(tcpTest:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *button2 = [[UIButton alloc] init];
    [self.view addSubview:button2];
    [button2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(padding.top);
        make.right.equalTo(self.view.mas_right).with.offset(padding.right);
    }];
    [button2 setTitle:@"UDP测试" forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(udpTest:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *button3 = [[UIButton alloc] init];
    [button setTag:2];
    [self.view addSubview:button3];
    [button3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(padding.top+50);
        make.left.equalTo(self.view.mas_left).with.offset(padding.left);
    }];
    [button3 setTitle:@"TCP测试2" forState:UIControlStateNormal];
    [button3 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button3 addTarget:self action:@selector(tcpOtherTest:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *button4 = [[UIButton alloc] init];
    [self.view addSubview:button4];
    [button4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(padding.top+50);
        make.right.equalTo(self.view.mas_right).with.offset(padding.right);
    }];
    [button4 setTitle:@"断开连接" forState:UIControlStateNormal];
    [button4 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button4 addTarget:self action:@selector(disConnectSocket) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    
    
    
    
}



@end
