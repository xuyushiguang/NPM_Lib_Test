//###############记录iOS一键登录配置流程###################################
记录iOS一键登录配置流程

1. xcode 版本需使用 9.0 以上，否则会报错

2. 导入认证 SDK 的 framework，直接将移动认证 TYRZUISDK.framework 拖到
项目中

3. 在 Xcode 中找到 TARGETS-->Build Setting-->Linking-->Other Linker
Flags 在这选项中需要添加-ObjC</br> 注意:如果以上操作仍然出现unrecognized selector sent to instance 找不到方法的报错,则添加更
改为_all_load

4. 资源文件:在 Xcode 中务必导入 TYRZResource.bundle 到项目中，否则授
权界面显示异常（不显示默认图片） TARGETS-->Build Phases-->Copy
Bundle Resources-> 点击 "+" --> Add Other --> TYRUIZSDK.framework
--> TYRZResource.bundle -->确定

5. 导入 sdk 语句：#import <TYRZUISDK/TYRZUISDK.h>，导入后才能调用 SDK
的方法

6. 在 info.plist 文件中添加一个子项目 App Transport Security Settings，
然后在其中添加一个 key：Allow Arbitrary Loads，其值为 YES。修改后
其他运营商才能使用一键登录。

7. 如需支持 iOS12 以下系统，需要添加依赖库，在项目设置 target -> 选
项卡 Build Phase -> Linked Binary with Libraries 添加如下依赖库：
Network.framework。

//###############代码编写###################################
代码编写

1. 在appDelegate.h导入头文件#import <TYRZUISDK/TYRZUISDK.h>

2. 在appDelegate.m 注册APPID和APPKEY

#define APPID  @"300012085186"
#define APPKEY @"DEDD63D788F2E97F082520FA0A61BE49"
#define APPSECRET @"BF02F4D272E94EC6B8B02E26E7857BAA"

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//#ifdef FB_SONARKIT_ENABLED
//  InitializeFlipper(application);
//#endif
  
  //存好APPID和APPKEY
  [[NSUserDefaults standardUserDefaults] setValue:APPID forKey:@"TYRZSDKAPPID"];
  [[NSUserDefaults standardUserDefaults] setValue:APPKEY forKey:@"TYRZSDKAPPKEY"];
  [[NSUserDefaults standardUserDefaults] setValue:APPSECRET forKey:@"TYRZSDKAPPSECRET"];

  //注册SDK
  [UASDKLogin.shareLogin registerAppId:APPID AppKey:APPKEY];
  //是否打印日志
  [UASDKLogin.shareLogin printConsoleEnable:YES];
  
  
  .......
  
  
  return YES;
}

//###############资源图片###################################
资源图片

1. 在images.xcassets文件里有几张图片,是必须的要的,也可以替换成其他的图片,但是图片名字不能改变;
