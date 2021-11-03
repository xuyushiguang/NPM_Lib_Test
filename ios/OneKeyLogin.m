//
//  OneKeyLogin.m
//  example
//
//  Created by xingye yang on 2021/10/28.
//

#import <UIKit/UIKit.h>
#import "OneKeyLogin.h"
#import <TYRZUISDK/TYRZUISDK.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCrypto.h>
#import "CYAnyCornerRadiusUtil.h"
//在appdelegate设置
#define APPID  [[NSUserDefaults standardUserDefaults]objectForKey:@"TYRZSDKAPPID"]
#define APPKEY [[NSUserDefaults standardUserDefaults]objectForKey:@"TYRZSDKAPPKEY"]
#define APPSECRET [[NSUserDefaults standardUserDefaults]objectForKey:@"TYRZSDKAPPSECRET"]

#define SUCCESSCODE @"103000"


/**
 * 隐私协议路径
 */
#define PRIVACY_PROTOCOL_URL  @"https://agreement.quectel.com/privacy_agreement_zh_CN.html"
/**
 * 用户协议路径
 */
#define  USER_PROTOCOL_URL  @"https://agreement.quectel.com/user_agreement_zh_CN.html"

@interface OneKeyLogin()
@property(nonatomic,strong)UIActivityIndicatorView *waitAV;
@property(nonatomic,strong)UIView *waitBGV;
@property (nonatomic,assign) BOOL authWindow;
@property(nonatomic,weak)UIViewController *topVC;
@property(nonatomic,copy)RCTPromiseResolveBlock callbackBlock;
@property(nonatomic,assign)BOOL loginType;
@property(nonatomic,strong)NSDictionary *paramsDic;
@end

@implementation OneKeyLogin

+ (UIViewController*)topViewController {
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

+ (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}


- (UIView *)waitBGV{
  if(!_waitBGV){
    _waitBGV = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    _waitBGV.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    _waitBGV.hidden = YES;
    [[UIApplication sharedApplication].keyWindow addSubview:_waitBGV];
  }
  return _waitBGV;
}

- (UIActivityIndicatorView *)waitAV{
  if(!_waitAV){
    _waitAV = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    CGRect _fra = [UIApplication sharedApplication].keyWindow.frame;
    _waitAV.center = CGPointMake(_fra.size.width/2, _fra.size.height/2);
    _waitAV.color = [UIColor blackColor];
    [self.waitBGV addSubview:_waitAV];
  }
  return _waitAV;
}


-(void)showIndicator{
  dispatch_async(dispatch_get_main_queue(), ^{
    self.waitBGV.hidden = NO;
    [self.waitAV startAnimating];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self.waitBGV];
  });
  
  
}

-(void)hiddenIndicator{
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.waitAV stopAnimating];
    self.waitBGV.hidden = YES;
  });
}

RCT_EXPORT_MODULE();

//返回函数执行时所在的线程，一般跨段交互都会操作UI，所以返回主线程
- (dispatch_queue_t)methodQueue
{
  return  dispatch_get_main_queue();
}

//返回给js端，iOS已经实现的方法列表，js只能监听这些方法。
-(NSArray<NSString *>*)supportedEvents
{
  return @[];
}

////暴露给js端的方法，获取移动端的登录token,然后直接把token传给我们的服务器,
//RCT_EXPORT_METHOD(oneKeyLogin:(NSDictionary*)params resolve:(RCTPromiseResolveBlock)resolveBlock reject:(RCTPromiseRejectBlock)reject){
//  NSLog(@"ios =oneKeyLogin=%@",params);
//  if(_callbackBlock){
//    _callbackBlock = NULL;
//  }
//  if([params isKindOfClass:NSDictionary.class]){
//    self.paramsDic = [NSDictionary dictionaryWithDictionary:params];
//  }
//  self.callbackBlock = resolveBlock;
//  self.loginType = 0;
//  [self openLogin];
//}

//暴露给js端的方法，获取移动端的登录token,不直接登录,然后把token传给js,在js端去登录;
RCT_EXPORT_METHOD(getLoginToken:(NSDictionary*)params resolve:(RCTPromiseResolveBlock)resolveBlock reject:(RCTPromiseRejectBlock)reject){
  NSLog(@"ios =oneKeyLogin=%@",params);
  if(_callbackBlock){
    _callbackBlock = NULL;
  }
  if([params isKindOfClass:NSDictionary.class]){
    self.paramsDic = [NSDictionary dictionaryWithDictionary:params];
  }
  self.callbackBlock = resolveBlock;
  self.loginType = 1;
  [self openLogin];
}

//暴露给js端的方法，调起一键登录页面
RCT_EXPORT_METHOD(dismiss){
  if(_topVC){
    [_topVC dismissViewControllerAnimated:YES completion:nil];
  }
  _callbackBlock = NULL;
}


-(void)openLogin{
  [self showIndicator];
  [UASDKLogin.shareLogin setTimeoutInterval: 8000];
  UIViewController *topVC = [OneKeyLogin topViewController];
  self.topVC = topVC;
  __weak typeof(self) weakSelf = self;
  /*注意事项:********************************model测试专用******************************************************************
       UACustomModel的 currentVC 必须要传*/
  UACustomModel *model = [[UACustomModel alloc]init];
  //1、当前VC 必传 不传会提示调用失败
  model.currentVC = topVC;
  model.statusBarStyle = UIStatusBarStyleDefault;
  
//  model.webNavReturnImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"lib_rn_ios_yywl_close" ofType:@"png"]];
  model.webNavTitleAttrs = @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont systemFontOfSize:18]};
  
  model.checkTipText = @"请勾选同意服务条款";
  model.privacyState = NO;
  model.presentAnimated = YES;
  model.faceOrientation = UIInterfaceOrientationPortrait;
  
  model.authLoadingViewBlock = ^(UIView *loadingView) {
    UIActivityIndicatorView *  _waitAV = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    CGRect _fra = [UIApplication sharedApplication].keyWindow.frame;
    _waitAV.center = CGPointMake(_fra.size.width/2, _fra.size.height/2);
    _waitAV.color = [UIColor blackColor];
    
    UIView *view = [[UIView alloc] initWithFrame:_fra];
    view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    [view addSubview:_waitAV];
    
    [loadingView addSubview:view];
      
  };
  
  CGRect statusReact = [[UIApplication sharedApplication] statusBarFrame];
  
//        CGFloat overallScaleW = UIScreen.mainScreen.bounds.size.width/ 375.f;
  //推出动画由model中的presentType来决定
  model.presentType = UAPresentationDirectionBottom;
  model.modalPresentationStyle = UIModalPresentationCustom;
  //36、边缘弹窗方式中的VC尺寸
  CGFloat _controllseH = UIScreen.mainScreen.bounds.size.height - statusReact.size.height - 44;
  model.controllerSize = CGSizeMake(UIScreen.mainScreen.bounds.size.width, _controllseH);
  
  CGRect screenBounds = UIScreen.mainScreen.bounds;
  
  CGFloat _imgH = (_controllseH/2 - 65 - 40 - 60)/3;
  
  
  //号码框
  model.numberOffsetY_B = @(_controllseH - (_imgH + 65) - _imgH - 40);
  model.numberTextAttributes = @{
    NSFontAttributeName:[UIFont systemFontOfSize:26],
    NSForegroundColorAttributeName:[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1]
  };
  
  //登录按钮
  model.logBtnText = [[NSMutableAttributedString alloc] initWithString:@"" attributes:@{
    NSFontAttributeName:[UIFont systemFontOfSize:16],
    NSForegroundColorAttributeName:[UIColor whiteColor]
  }];
  model.logBtnOffsetY_B = @(_controllseH/2-25);
  model.logBtnOriginLR = @[@30,@30];
  model.logBtnHeight = 50;
  model.logBtnImgs = @[
    [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"lib_rn_ios_yywl_loginBt" ofType:@"png"]],
    [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"lib_rn_ios_yywl_loginBt" ofType:@"png"]],
    [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"lib_rn_ios_yywl_loginBt" ofType:@"png"]],
  ];
  
  //隐私
  model.uncheckedImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"lib_rn_ios_yywl_check_off" ofType:@"png"]];
  model.checkedImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"lib_rn_ios_yywl_check_on" ofType:@"png"]];
  model.checkboxWH = @(15);
  model.privacyOffsetY_B = @(_controllseH/2-25 -50 - 25);
  //20、隐私的内容模板
  model.appPrivacyDemo = [[NSAttributedString alloc]initWithString:@"我已阅读并同意&&默认&&、移远用户协议及隐私政策" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize: 13],NSForegroundColorAttributeName:[UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1]}];
  NSString *userProtocol = self.paramsDic[@"userProtocol"];
  NSString *privacyProtocol = self.paramsDic[@"privacyProtocol"];
  NSAttributedString *str1 = [[NSAttributedString alloc]initWithString:@"用户协议" attributes:@{NSLinkAttributeName:userProtocol}];
  NSAttributedString *str2 = [[NSAttributedString alloc]initWithString:@"隐私政策" attributes:@{NSLinkAttributeName:privacyProtocol}];
  //21、隐私条款默认协议是否开启书名号
  model.privacySymbol = NO;
  //23、隐私条款:数组对象
  model.appPrivacy = @[str1,str2];
  //24、隐私条款名称颜色（协议）
  model.privacyColor = [UIColor colorWithRed:54.0/255.0 green:92.0/255.0 blue:210.0/255.0 alpha:1];
  model.appPrivacyOriginLR = @[@30,@30];
  //隐私web页导航
  
  
  model.authViewBlock = ^(UIView *customView, CGRect numberFrame , CGRect loginBtnFrame,CGRect checkBoxFrame, CGRect privacyFrame) {
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    CornerRadii cornerRadii = CornerRadiiMake(20, 20, 0, 0);
    CGPathRef path = CYPathCreateWithRoundedRect(customView.bounds,cornerRadii);
    shapeLayer.path = path;
    CGPathRelease(path);
    customView.layer.mask = shapeLayer;
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"lib_rn_ios_yywl_app_log" ofType:@"png"]]];
    imgView.frame = CGRectMake((screenBounds.size.width - 65)/2, _imgH, 65, 65);
    [customView addSubview:imgView];
    
    UILabel *tip = [[UILabel alloc] init];
    tip.frame = CGRectMake(0, numberFrame.origin.y+ numberFrame.size.height+ 10, screenBounds.size.width, 40);
    tip.text = @"中国移动提供认证服务";
    tip.textColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1];
    tip.font = [UIFont systemFontOfSize:13];
    [customView addSubview:tip];
    tip.textAlignment = NSTextAlignmentCenter;
    
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(10,  10, 50, 50)];
    [btn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"lib_rn_ios_yywl_close" ofType:@"png"]] forState:UIControlStateNormal];
    [btn addTarget:weakSelf action:@selector(dismiss) forControlEvents:(UIControlEventTouchUpInside)];
    [customView addSubview:btn];
  };
  
  
  //******************************************************************************************************************
      
  [UASDKLogin.shareLogin getAuthorizationWithModel:model complete:^(id  _Nonnull sender) {
    dispatch_async(dispatch_get_main_queue(), ^{
      NSString *resultCode = sender[@"resultCode"];
      
      NSLog(@"selfsender=%@",sender);
      if ([resultCode isEqualToString:SUCCESSCODE]) {
        if(weakSelf.loginType == 0){
          NSString * token = sender[@"token"];
          [weakSelf sendTokenToServer:token];
        }else{
          [weakSelf hiddenIndicator];
          [weakSelf rnBlock:sender];
        }
        
      }else if ([resultCode isEqualToString:@"200087"]){
        [weakSelf hiddenIndicator];
        
      } else{
        [weakSelf hiddenIndicator];
        [weakSelf rnBlock:sender];
      }
    });
      
  }];
  
}

-(void)rnBlock:(id)sender{
  if(self.callbackBlock){
    self.callbackBlock(sender);
    self.callbackBlock = NULL;
  }
}

-(void)sendTokenToServer:(NSString*)loginToken
{
  
    if (loginToken.length <= 0) {
        
        return;
    }
  [self showIndicator];
    //一键登录token
    NSString *loginTokenURL = @"http://192.168.25.121:8901/enduserapi/phoneAuthLogin";
    
    //appid
    NSString *appid = APPID;//TYRZSDKAPPID
    
    //加密算法类型。RSA SM  MD5
    NSString *encryptionalgorithm = @"MD5";
    
    //扩展参数,不是必填
    NSString *expandparams = @"";
    
    //msgid
    NSString *msgid = [self.class uuid];
    
    //0不对服务器ip白名单进行强校验,1对服务器ip白名单进行强校验
    NSString *strictcheck = @"0";
    //systemtime
    NSString *systemtime = [self.class timestamp];
    
    //appkey
    NSString *appkey = APPSECRET;//TYRZSDKAPPSECRET
    
    //appkey
    NSString *token = loginToken;
    
    NSString *userDomain = @"C.DM.29535.1";
    
    //版本号
    NSString *version = @"2.0";
    
    //sign
    NSString *sign = [NSString stringWithFormat:@"%@%@%@%@%@%@%@",appid,version,msgid,systemtime,strictcheck,token,appkey];
    sign = [self.class md5:sign];
    
    NSDictionary *loginTokenParams = @{
        @"appid":appid,
        @"encryptionalgorithm":encryptionalgorithm,
//        @"expandparams":expandparams,
        @"msgid":msgid,
        @"sign":sign,
        @"strictcheck":strictcheck,
        @"systemtime":systemtime,
        @"token":token,
        @"userDomain":userDomain,
        @"version":version
    };
    loginTokenURL = [NSString stringWithFormat:@"%@?appid=%@&encryptionalgorithm=%@&msgid=%@&sign=%@&strictcheck=%@&systemtime=%@&token=%@&userDomain=%@&version=%@",loginTokenURL,appid,encryptionalgorithm,msgid,sign,strictcheck,systemtime,token,userDomain,version];
    
  NSLog(@"===loginTokenURL=====%@",loginTokenURL);
  
    __weak typeof(self)weakSelf = self;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:loginTokenURL]];
  [request setTimeoutInterval:6];
    request.HTTPMethod = @"POST";
  
    [[NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
      NSLog(@"=====用户手机信息======");
      [weakSelf hiddenIndicator];
      dispatch_async(dispatch_get_main_queue(), ^{
        if (data.length > 0) {
          NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
          NSLog(@"=====用户手机信息======2=%@",dataString);
          NSError *error;
          NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
          if (!error) {
            [weakSelf rnBlock:dic];
          }else{
            [weakSelf rnBlock:@{}];
          }
          
        }else{
          [weakSelf rnBlock:@{}];
        }
      });
            
    }] resume];
    
}


+ (NSString *)uuid {
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_ref);
    CFRelease(uuid_string_ref);
    
    return [[uuid lowercaseString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

/**
 系统当前日期，精确到毫秒，共17位
 */
+ (NSString *)timestamp {
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmssSSS"];
    NSString *result = [formatter stringFromDate:now];
    
    return result;
}
/**
 MD5加密

 @param src 加密字符串
 @return 加密结果
 */
+ (NSString *)md5:(NSString *)src {
    
    const char *source = [src UTF8String];
    unsigned char md5[CC_MD5_DIGEST_LENGTH];
    CC_MD5(source, (uint32_t)strlen(source), md5);
    
    NSMutableString *retString = [NSMutableString stringWithCapacity:40];
    
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        NSString *strValue = [NSString stringWithFormat:@"%02X", md5[i]];
        if ([strValue length] == 0) {
            strValue = @"";
        }
        
        [retString appendString:strValue];
    }
    
    if ([retString length] == 0) {
        return @"";
    }
    
    return [retString lowercaseString];
    
}

- (UIImage*) createImageWithColor: (UIColor*) color

{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);

    UIGraphicsBeginImageContext(rect.size);

    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);

    CGContextFillRect(context, rect);

    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return theImage;

}

@end
