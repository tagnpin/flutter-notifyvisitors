#import "NotifyvisitorsPlugin.h"

BOOL nvDismissNCenterOnAction;

BOOL nvPushObserverReady;

//BOOL nvPushObserverReady;
typedef void (^nvPushClickCheckRepeatHandler)(BOOL isnvPushActionRepeat);
typedef void (^nvPushClickCheckRepeatBlock)(nvPushClickCheckRepeatHandler completionHandler);
int nvCheckPushClickTimeCounter = 0;

FlutterResult chatBotCallback;
FlutterResult showCallback = NULL;
FlutterResult eventCallback = NULL;
FlutterResult commonCallback = NULL;

@implementation NotifyvisitorsPlugin


+ (instancetype)sharedInstance {
    static NotifyvisitorsPlugin *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [NotifyvisitorsPlugin new];
    });
    return sharedInstance;
}


+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    NSLog(@"%@ REGISTER WITH REGISTRAR !!", TAG);
    NSLog(@"FLUTTER-NOTIFYVISITORS PLUGIN_VERSION : %@ !!", PLUGIN_VERSION);
    NotifyvisitorsPlugin.sharedInstance.channel = [FlutterMethodChannel
                                                   methodChannelWithName:@"flutter_notifyvisitors"
                                                   binaryMessenger:[registrar messenger]];
    //NotifyvisitorsPlugin* instance = [[NotifyvisitorsPlugin alloc] init];
    
    [registrar addMethodCallDelegate:NotifyvisitorsPlugin.sharedInstance channel:NotifyvisitorsPlugin.sharedInstance.channel];
    
    // initialize variables
    [NotifyvisitorsPlugin.sharedInstance nvInit];
}

- (void) nvInit{
    NSLog(@"%@ NV INIT !!", TAG);
    [self setNvDeepLinkObserver];
    _handlers = [[NSMutableArray alloc] init];
    [notifyvisitors sharedInstance].delegate = self;
}



- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    } else if([SHOW isEqualToString:call.method]){
        [self show:call withResult:result];
    } else if([NOTIFICATION_CENTER isEqualToString:call.method]){
        [self notificationCanter:call withResult:result];
    } else if([EVENT isEqualToString:call.method]){
        [self event:call withResult:result];
    } else if([STOP_SHOW_INAPP isEqualToString:call.method]){
        [self stopShowInapp:call withResult:result];
    } else if([STOP_PUSH isEqualToString:call.method]){
        [self stopPushNotification:call withResult:result];
    } else if([GET_NOTIFICATION_DATA isEqualToString:call.method]){
        [self notificationCenterData:call withResult:result];
    } else if([NOTIFICATION_COUNT isEqualToString:call.method]){
        [self notificationCount:call withResult:result];
    } else if([SCHEDULE_NOTIFICATION isEqualToString:call.method]){
        [self scheduleNotification:call withResult:result];
    } else if([HIT_USER isEqualToString:call.method]){
        [self userIdentifier:call withResult:result];
    } else if([STOP_GEOFENCE isEqualToString:call.method]){
        [self stopGeofence:call withResult:result];
    } else if([PUSH_CLICK isEqualToString:call.method]){
        [self getLinkInfo:call withResult:result];
    } else if([EVENT_SURVEY_INFO isEqualToString:call.method]){
        [self getEventSurveyInfo:call withResult:result];
    } else if([SCROLL_VIEW_DID_SCROLL isEqualToString:call.method]){
        [self scrollViewDidScroll:call withResult:result];
    } else if([ANDROID_AUTO_START isEqualToString:call.method]){
        NSLog(@"%@ : NOT AWAILABLE IN IOS !!", TAG);
    } else if([CHAT_BOT isEqualToString:call.method]){
        [self startChatBot:call withResult:result];
    } else if([NV_UID isEqualToString:call.method]){
        [self getNvUid:call withResult:result];
    } else if([ANDROID_DUMMMY1 isEqualToString:call.method]){
        NSLog(@"%@ : NOT AWAILABLE IN IOS !!", TAG);
    } else if([ANDROID_DUMMMY2 isEqualToString:call.method]){
        NSLog(@"%@ : NOT AWAILABLE IN IOS !!", TAG);
    } else if([ANDROID_DUMMMY3 isEqualToString:call.method]){
        NSLog(@"%@ : NOT AWAILABLE IN IOS !!", TAG);
    } else if([ANDROID_DUMMMY4 isEqualToString:call.method]){
        NSLog(@"%@ : NOT AWAILABLE IN IOS !!", TAG);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

/* */
- (void) show:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSLog(@"%@ : SHOW  !!", TAG);
    @try{
        showCallback = result;
        NSMutableDictionary *mUserToken = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *mCustomRule = [[NSMutableDictionary alloc] init];
        
        NSDictionary *userToken ;
        @try{
            userToken = call.arguments[@"tokens"];
            if (![userToken isEqual:[NSNull null]]){
                mUserToken = [userToken mutableCopy];
            } else{
                mUserToken = nil;
            }
        }
        @catch(NSException *exception){
            NSLog(@"TOKENS ERROR : %@", exception.reason);
        }
        
        
        NSDictionary *customRule;
        @try{
            customRule = call.arguments[@"customRules"];
            if (![customRule isEqual:[NSNull null]]){
                mCustomRule = [customRule mutableCopy];
            } else{
                mCustomRule = nil;
            }
        }
        @catch(NSException *exception){
            NSLog(@"TOKENS ERROR : %@", exception.reason);
        }
        
        NSLog(@"%@ : CALL NATIVE FUNCTION !!", TAG);
        [notifyvisitors Show:mUserToken CustomRule:mCustomRule];
        
    }
    @catch(NSException *exception){
        NSLog(@" SHOW ERROR : %@", exception.reason);
    }
}

/* */
- (void) notificationCanter:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSLog(@"%@ : NOTIFICATION CENTER !!", TAG);
    @try{
        [notifyvisitors NotifyVisitorsNotificationCentre];
        NSString *nvResourcePlistPath = [[NSBundle mainBundle] pathForResource: @"nvResourceValues" ofType: @"plist"];
        if ([[NSFileManager defaultManager] fileExistsAtPath: nvResourcePlistPath]) {
            NSDictionary *nvResourceData = [NSDictionary dictionaryWithContentsOfFile: nvResourcePlistPath];
            if ([nvResourceData count] > 0) {
                NSDictionary *nvResourceBooleans = [nvResourceData objectForKey: @"nvBooleans"];
                
                if ([nvResourceBooleans count] > 0) {
                    if (nvResourceBooleans [@"DismissNotificationCenterOnAction"]) {
                        nvDismissNCenterOnAction = [nvResourceBooleans [@"DismissNotificationCenterOnAction"] boolValue];
                    } else {
                        nvDismissNCenterOnAction = YES;
                    }
                    NSLog(@"NV DISMISS NOTIFICATION CENTER ON ACTION = %@", nvDismissNCenterOnAction ? @"YES" : @"NO");
                    
                } else {
                    NSLog(@"NV RESOURCE BOOLEANS NOT FOUND !!");
                }
                
            } else {
                NSLog(@"NV RESOURCE DATA NOT FOUND !!");
            }
            
        } else {
            NSLog(@"NV RESOURCE VALUES PLIST NOT FOUND !!");
        }
        
    }
    @catch(NSException *exception){
        NSLog(@" NOTIFICATION CENTER ERROR : %@", exception.reason);
    }
}

/* */
- (void) event:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSLog(@"%@ : EVENT !!", TAG);
    @try{
        eventCallback = result;
        NSMutableDictionary *jAttributes = [[NSMutableDictionary alloc] init];
        int nvScope = 0;
        
        NSString *eventName;
        @try{
            eventName = call.arguments[@"eventName"];
            if([eventName isEqual:[NSNull null]] || [eventName length] == 0){
                eventName = nil;
            }
        }
        @catch(NSException *exception){
            NSLog(@"EVENT-NAME ERROR : %@", exception.reason);
        }
        
        NSDictionary *attributes = call.arguments[@"customRules"];
        if (![attributes isEqual:[NSNull null]]){
            jAttributes = [attributes mutableCopy];
        }else{
            jAttributes = nil;
        }
        
        
        NSString *lifeTimeValue = call.arguments[@"lifeTimeValue"];
        if([lifeTimeValue isEqual:[NSNull null]] || [lifeTimeValue length] == 0){
            lifeTimeValue = nil;
        }
        
        NSString *scope = call.arguments[@"scope"];
        if([scope isEqual:[NSNull null]] ){
            nvScope = 0;
        } else if([scope length] == 0){
            nvScope = 0;
        }else{
            nvScope = [scope intValue];
        }
        
        //NSLog(@"Dictionary: %@",jAttributes);
        NSLog(@"%@ : CALL NATIVE FUNCTION !!", TAG);
        [notifyvisitors trackEvents:eventName Attributes:jAttributes lifetimeValue:lifeTimeValue Scope:nvScope];
    }
    @catch(NSException *exception){
        NSLog(@"EVENT ERROR : %@", exception.reason);
    }
}

/* */
- (void) stopShowInapp:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSLog(@"%@ : STOP-SHOW-INAPP !!", TAG);
    @try{
        [notifyvisitors DismissAllNotifyvisitorsInAppNotifications];
    }
    @catch(NSException *exception){
        NSLog(@"STOP-SHOW-INAPP ERROR : %@", exception.reason);
    }
}

/* */
- (void) stopPushNotification:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSLog(@"%@ : STOP-PUSH-NOTIFICTION !!", TAG);
    @try{
        BOOL value = call.arguments[@"value"];
        [notifyvisitors stopPushNotification:value];
    }
    @catch(NSException *exception){
        NSLog(@"STOP-PUSH-NOTIFICTION ERROR : %@", exception.reason);
    }
}

/* */
- (void) notificationCount:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSLog(@"%@ : NOTIFICATION COUNT !!", TAG);
    @try{
        [notifyvisitors GetUnreadPushNotification:^(NSInteger nvUnreadPushCount) {
            NSString *jCount = nil;
            jCount = [@(nvUnreadPushCount) stringValue];
            result(jCount);
        }];
    }
    @catch(NSException *exception){
        NSLog(@"NOTIFICATION COUNT ERROR : %@", exception.reason);
    }
}

/* */
- (void) notificationCenterData:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSLog(@"%@ : NOTIFICATION-CENTER-DATA !!", TAG);
    @try{
        [notifyvisitors GetNotificationCentreData:^(NSMutableArray * nvNotificationCenterData) {
            if([nvNotificationCenterData count] > 0){
                NSError *nvError = nil;
                NSData *nvJsonData = [NSJSONSerialization dataWithJSONObject: nvNotificationCenterData options:NSJSONWritingPrettyPrinted error: &nvError];
                NSString *nvJsonString = [[NSString alloc] initWithData: nvJsonData encoding: NSUTF8StringEncoding];
                result(nvJsonString);
            }else{
                result(@"null");
            }
        }];
    }
    @catch(NSException *exception){
        NSLog(@"NOTIFICATION-CENTER-DATA ERROR : %@", exception.reason);
    }
}

/* */
- (void) scheduleNotification:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSLog(@"%@ : SCHEDULE-NOTIFICATION !!", TAG);
    @try{
        
        NSString * nId;
        @try{
            nId = call.arguments[@"nid"];
            if([nId isEqual:[NSNull null]] || [nId length] == 0){
                nId = nil;
            }
        }
        @catch(NSException *exception){
            NSLog(@"NID ERROR : %@", exception.reason);
        }
       
        NSString * tag;
        @try{
            tag = call.arguments[@"tag"];
            if([tag isEqual:[NSNull null]] || [tag length] == 0){
                tag = nil;
            }
        }
        @catch(NSException *exception){
            NSLog(@"TAG ERROR : %@", exception.reason);
        }
        
        NSString * time;
        @try{
            time = call.arguments[@"time"];
            if([time isEqual:[NSNull null]] || [time length] == 0){
                time = nil;
            }
        }
        @catch(NSException *exception){
            NSLog(@"TIME ERROR : %@", exception.reason);
        }
        
        NSString * title;
        @try{
            title = call.arguments[@"title"];
            if([title isEqual:[NSNull null]] || [title length] == 0){
                title = nil;
            }
        }
        @catch(NSException *exception){
            NSLog(@"TITLE ERROR : %@", exception.reason);
        }
        
        NSString * message;
        @try{
            message = call.arguments[@"msg"];
            if([message isEqual:[NSNull null]] || [message length] == 0){
                message = nil;
            }
        }
        @catch(NSException *exception){
            NSLog(@"MSG ERROR : %@", exception.reason);
        }
        
        NSString * url;
        @try{
            url = call.arguments[@"url"];
            if([url isEqual:[NSNull null]] || [url length] == 0){
                url = nil;
            }
        }
        @catch(NSException *exception){
            NSLog(@"URL ERROR : %@", exception.reason);
        }
        
        NSString * icon;
        @try{
            icon = call.arguments[@"icon"];
            if([icon isEqual:[NSNull null]] || [icon length] == 0){
                icon = nil;
            }
        }
        @catch(NSException *exception){
            NSLog(@"ICON ERROR : %@", exception.reason);
        }
        
        [notifyvisitors schedulePushNotificationwithNotificationID:nId Tag:tag TimeinSecond:time Title:title Message:message URL:url Icon:icon];
        
    }
    @catch(NSException *exception){
        NSLog(@"SCHEDULE-NOTIFICATION ERROR : %@", exception.reason);
    }
}

/* */
- (void) userIdentifier:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSLog(@"%@ : USER-IDENTIFIER !!", TAG);
    @try{
        NSMutableDictionary *mUserParams = [[NSMutableDictionary alloc] init];
        
        NSString *userId;
        @try{
            userId = call.arguments[@"userId"];
            if([userId isEqual:[NSNull null]] || [userId length] == 0){
                userId = nil;
            }
        }
        @catch(NSException *exception){
            NSLog(@"USER-ID ERROR : %@", exception.reason);
        }
        
        NSDictionary *attributes;
        @try{
            attributes = call.arguments[@"attributes"];
            if (![attributes isEqual:[NSNull null]]){
                mUserParams = [attributes mutableCopy];
            } else{
                mUserParams = nil;
            }
        }
        @catch(NSException *exception){
            NSLog(@"ATTRIBUTES ERROR : %@", exception.reason);
        }
        
        NSLog(@"%@ : CALL NATIVE FUNCTION !!", TAG);
        [notifyvisitors UserIdentifier: userId UserParams: mUserParams];
    }
    @catch(NSException *exception){
        NSLog(@"USER-IDENTIFIER ERROR : %@", exception.reason);
    }
}

/* */
- (void) stopGeofence:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSLog(@"%@ : STOP-GEOFENCE !!", TAG);
    @try{
        NSInteger nvAdditionalHours = 0;
        
        NSString * nvDateTime;
        @try{
            nvDateTime = call.arguments[@"dateTime"];
            if ([nvDateTime isEqual:[NSNull null]] || [nvDateTime length] == 0){
                nvDateTime = nil;
            }
            
        }
        @catch(NSException *exception){
            NSLog(@"DATE TIME ERROR : %@", exception.reason);
        }
        
        NSString * additionalHours;
        @try{
            additionalHours = call.arguments[@"additionalHours"];;
            if ([additionalHours isEqual:[NSNull null]] || [additionalHours length] == 0){
                nvAdditionalHours = 0;
            }else{
                nvAdditionalHours  = [additionalHours intValue];
            }
        }
        @catch(NSException *exception){
            NSLog(@"ADDITIONAL HOURS ERROR : %@", exception.reason);
        }
        
        NSLog(@"%@ : CALL NATIVE FUNCTION !!", TAG);
        [notifyvisitors stopGeofencePushforDateTime: nvDateTime additionalHours: nvAdditionalHours];
    }
    @catch(NSException *exception){
        NSLog(@"STOP-GEOFENCE ERROR : %@", exception.reason);
    }
}

/* */
- (void) getLinkInfo:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSLog(@"%@ : GET LINK INFO !!", TAG);
    @try{
        nvPushObserverReady = YES;
        [[NSNotificationCenter defaultCenter] addObserverForName: @"NVInAppViewConroller" object:nil queue:nil usingBlock:^(NSNotification *notification) {
            NSDictionary *nvUserInfo = [notification userInfo];
            if ([nvUserInfo count] > 0) {
                NSError * err;
                NSData * jsonData = [NSJSONSerialization dataWithJSONObject:nvUserInfo options:0 error:&err];
                NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                [self.channel invokeMethod:@"GetLinkInfo" arguments:myString];
            }else{
                NSLog(@"%@ : NOTIFICATION DATA IS NULL  !!", TAG);
            }
        }];
    }
    @catch(NSException *exception){
        NSLog(@" ERROR : %@", exception.reason);
    }
}



/* */
- (void) getEventSurveyInfo:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSLog(@"%@ : GET EVENT SURVEY INF0  !!", TAG);
    @try{
        commonCallback = result;
    }
    @catch(NSException *exception){
        NSLog(@" ERROR : %@", exception.reason);
    }
}

/* */
- (void) scrollViewDidScroll:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSLog(@"%@ : SCROLLVIEW DID SCROLL !!", TAG);
    @try{
        UIScrollView *nvScrollview;
        [notifyvisitors scrollViewDidScroll: nvScrollview];
    }
    @catch(NSException *exception){
        NSLog(@"SCROLLVIEW-DID-SCROLL ERROR : %@", exception.reason);
    }
}

/* */
- (void) startChatBot:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSLog(@"%@ : START CHAT BOT !!", TAG);
    @try{
        NSString *screenName = call.arguments[@"screenName"];
        [notifyvisitors startChatBotWithScreenName: screenName];
    }
    @catch(NSException *exception){
        NSLog(@"START CHAT-BOT ERROR : %@", exception.reason);
    }
}

/* */
- (void) getNvUid:(FlutterMethodCall *)call withResult:(FlutterResult)result {
    NSLog(@"%@ : GET NV-UID  !!", TAG);
    @try{
        [notifyvisitors getNvUid:^(NSString *nv_UIDStr){
            //NSLog(@"notifyvisitors uid = %@", nv_UIDStr);
            if([nv_UIDStr length] > 0){
                result(nv_UIDStr);
            }else{
                result(@"null");
            }
        }];
    }
    @catch(NSException *exception){
        NSLog(@"GET NV-UID ERROR : %@", exception.reason);
    }
}

- (void)setNvDeepLinkObserver{
    @try{
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"nvDeepLinkData" object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(sendLinkInfo:) name: @"nvDeepLinkData" object: nil];
    }@catch (NSException *exception) {
        NSLog(@"SEND-LINK-INFO ERROR : %@", exception);
    }
}

- (void)NotifyvisitorsChatBotActionCallbackWithUserInfo:(NSDictionary *)userInfo{
    NSLog(@"CHAT-BOT ACTION CALLBACK !!");
    @try {
        if ([userInfo count] > 0) {
            NSError *nvError = nil;
            NSData *nvJsonData = [NSJSONSerialization dataWithJSONObject: userInfo options: NSJSONWritingPrettyPrinted error: &nvError];
            NSString *nvJsonString = [[NSString alloc] initWithData: nvJsonData encoding: NSUTF8StringEncoding];
            [self.channel invokeMethod:@"ChatBotResponse" arguments:nvJsonString];
        }else{
            NSLog(@"%@ : CHAT-BOT DATA IS NULL  !!", TAG);
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"CHAT-BOT ACTION CALLBACK ERROR : %@", exception);
    }
    
}


- (void)NotifyvisitorsGetEventResponseWithUserInfo:(NSDictionary *)userInfo{
    NSLog(@"%@ : GET EVENT RESPONSE WITH USER INFO  !!", TAG);
    @try {
        if([userInfo count] > 0){
            NSError *nvError = nil;
            NSData *nvJsonData = [NSJSONSerialization dataWithJSONObject: userInfo options: NSJSONWritingPrettyPrinted error: &nvError];
            NSString *nvJsonString = [[NSString alloc] initWithData: nvJsonData encoding: NSUTF8StringEncoding];
            
            NSString * eventName = userInfo[@"eventName"];
            // clicked is event or survey
            if([eventName isEqualToString:@"Survey Submit"] || [eventName isEqualToString:@"Survey Attempt"] || [eventName isEqualToString:@"Banner Clicked"] ){
                if(showCallback != NULL){
                    [self.channel invokeMethod:@"ShowResponse" arguments:nvJsonString];
                } else{
                    NSLog(@"%@ : SHOW CALLBACK CONTEXT IS NULL !!", TAG);
                }
            }else{
                if(eventCallback != NULL){
                    [self.channel invokeMethod:@"EventResponse" arguments:nvJsonString];
                }  else{
                    NSLog(@"%@ : EVENT CALLBACK CONTEXT IS NULL  !!", TAG);
                }
            }
            
            if(commonCallback != NULL){
                [self.channel invokeMethod:@"EventSurveyCallback" arguments:nvJsonString];
            }  else{
                NSLog(@"%@ : EVENT-SURVEY CALLBACK CONTEXT IS NULL !!", TAG);
            }
            
        }
    }
    @catch (NSException *exception) {
        NSLog(@"GET EVENT RESPONSE WITH USER INFO ERROR : %@", exception);
    }
}

//- (void)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler{
//    NSLog(@"CONTINUE USER ACTIVITY FROM OTHER PLUGIN !*!");
//    @try{
//        if ([userActivity.activityType isEqualToString: NSUserActivityTypeBrowsingWeb]) {
//             NSURL *nvAppULinkUrl = [userActivity webpageURL];
//            if(nvAppULinkUrl != nil){
//                NSString *nvUrl = nvAppULinkUrl.absoluteString;
//                NSMutableDictionary * nvlinkInfo = [[NSMutableDictionary alloc] init] ;
//                nvlinkInfo = [notifyvisitors OpenUrlGetDataWithApplication:application Url:nvAppULinkUrl];
//                [nvlinkInfo setValue:nvUrl forKey:@"url"];
//                [nvlinkInfo setValue:@"nv" forKey:@"source"];
//                [[NSNotificationCenter defaultCenter] postNotificationName: @"nvDeepLinkData"  object: 0 userInfo:nvlinkInfo];
//            }
//         }
//    }@catch (NSException *exception) {
//       NSLog(@"exception in continueUserActivity");
//    }
//}





/*  app delegate methods */

+(void)Initialize{
    NSLog(@"%@ INITIALIZE !!", TAG);
    NSString *nvMode = nil;
#if DEBUG
    nvMode = @"debug";
#else
    nvMode = @"live";
#endif
    [notifyvisitors Initialize:nvMode];
    
}

+(void)RegisterPushWithDelegate:(id _Nullable)delegate App:(UIApplication * _Nullable)application launchOptions:(NSDictionary *_Nullable)launchOptions{
    NSLog(@"%@ REGISTER PUSH WITH DELEGATE !!", TAG);
    @try{
        [notifyvisitors RegisterPushWithDelegate: delegate App: application launchOptions: launchOptions];
    } @catch(NSException *exception){
        NSLog(@"FLUTTER-NOTIFYVISITORS ERROR : %@", exception.reason);
    }
}


//for simple push

+(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken  {
    NSLog(@"%@ DID REGISTER FOR REMOTE NOTIFICATIONS WITH DEVICE TOKEN !!", TAG);
    @try{
        [notifyvisitors DidRegisteredNotification: application deviceToken: deviceToken];
    }
    @catch(NSException *exception){
        NSLog(@"FLUTTER-NOTIFYVISITORS ERROR : %@", exception.reason);
    }
    
}


+(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    @try{
        NSLog(@"RN-NotifyVisitors : DID FAIL TO REGISTER FOR REMOTE NOTIFICATIONS WITH ERROR = %@", error);
    }
    @catch(NSException *exception){
        NSLog(@"FLUTTER-NOTIFYVISITORS ERROR : %@", exception.reason);
    }
    
}

+(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    @try{
        NSLog(@"%@ DID RECEIVE REMOTE NOTIFICATION !!", TAG);
        [notifyvisitors didReceiveRemoteNotificationWithUserInfo: userInfo];
    }
    @catch(NSException *exception){
        NSLog(@"FLUTTER-NOTIFYVISITORS ERROR : %@", exception.reason);
    }
}

+(void)applicationWillTerminate{
    @try{
        NSLog(@"%@ APPLICATION WILL TERMINATE !!", TAG);
        [notifyvisitors applicationWillTerminate];
    }
    @catch(NSException *exception){
        NSLog(@"FLUTTER-NOTIFYVISITORS ERROR : %@", exception.reason);
    }
    
}



//open Url Function

+(void)openUrl:(UIApplication *_Nullable)application openURL:(NSURL*)url{
    NSLog(@"%@ OPEN URL !!", TAG);
    @try{
        [notifyvisitors OpenUrlWithApplication:application Url:url];
    }
    @catch(NSException *exception){
        NSLog(@"FLUTTER-NOTIFYVISITORS ERROR : %@", exception.reason);
    }
}


+(void)willPresentNotification:(UNNotification *_Nullable)notification withCompletionHandler:(void (^_Nullable)(UNNotificationPresentationOptions options))completionHandler  API_AVAILABLE(ios(10.0)){
    NSLog(@"%@ WILL PRESENT NOTIFICATION !!", TAG);
    @try{
        [notifyvisitors willPresentNotification: notification withCompletionHandler: completionHandler];
    }
    @catch(NSException *exception){
        NSLog(@"FLUTTER-NOTIFYVISITORS ERROR : %@", exception.reason);
    }
}



+(void)didReceiveNotificationResponse:(UNNotificationResponse *_Nullable)response  API_AVAILABLE(ios(10.0)){
    NSLog(@"%@ DID RECEIVE NOTIFICATION RESPONSE !!", TAG);
    @try{
        //  NSLog(@"didReceiveNotificationResponse triggered with nvPushObserverReady value = %@", nvPushObserverReady ? @"YES" : @"NO");
        if(!nvPushObserverReady) {
            [self nvPushClickCheckInSeconds: 1 withBlock: ^(nvPushClickCheckRepeatHandler completionHandler) {
                [notifyvisitors didReceiveNotificationResponse: response];
            }];
        } else {
            [notifyvisitors didReceiveNotificationResponse: response];
        }
        
    }
    @catch(NSException *exception){
        NSLog(@"FLUTTER-NOTIFYVISITORS ERROR : %@", exception.reason);
        
    }
}


+(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"%@ DID RECEIVE REMOTE NOTIFICATION !!", TAG);
    @try{
        [notifyvisitors didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
    }
    @catch(NSException *exception){
        NSLog(@"FLUTTER-NOTIFYVISITORS ERROR : %@", exception.reason);
    }
    
}


//Geofencing Methods

+(void)applicationDidEnterBackground:(UIApplication *)application{
    @try{
        NSLog(@"%@ APPLICATION DID ENTER BACKGROUND !!", TAG);
        [notifyvisitors applicationDidEnterBackground: application];
        
    }@catch(NSException *exception){
        NSLog(@"FLUTTER-NOTIFYVISITORS ERROR : %@", exception.reason);
    }
}


+(void)applicationDidBecomeActive:(UIApplication *)application{
    @try{
        NSLog(@"%@ APPLICATION DID BECOME ACTIVE !!", TAG);
        [notifyvisitors applicationDidBecomeActive: application];
        
    }@catch(NSException *exception){
        NSLog(@"FLUTTER-NOTIFYVISITORS ERROR : %@", exception.reason);
    }
    
}


+(void)NotifyVisitorsGeofencingReceivedNotificationWithApplication:(UIApplication *)application  localNotification:(UILocalNotification *) notification{
    @try{
        NSLog(@"%@ NOTIFYVISITORS GEOFENCING RECEIVED NOTIFICATION WITH APPLICATION !!", TAG);
        [notifyvisitors NotifyVisitorsGeofencingReceivedNotificationWithApplication:application window:[UIApplication sharedApplication].keyWindow didReceiveGeofencingNotification:notification];
        
    }@catch(NSException *exception){
        NSLog(@"FLUTTER-NOTIFYVISITORS ERROR : %@", exception.reason);
    }
    
}


+(void)nvPushClickCheckInSeconds:(int)seconds withBlock: (nvPushClickCheckRepeatBlock) nvPushCheckBlock {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        nvCheckPushClickTimeCounter = nvCheckPushClickTimeCounter + seconds;
        if(!nvPushObserverReady) {
            if (nvCheckPushClickTimeCounter < 20) {
                return [self nvPushClickCheckInSeconds: seconds withBlock: nvPushCheckBlock];
                //[self irDispatchReatforTrackingDataInSeconds: seconds withBlock: irBlock];
            } else {
                //irTempTrackResponse = @{@"Authentication" : @"failed",@"http_code": @"408"};
                nvPushCheckBlock(^(BOOL isRepeat) {
                    if (isRepeat) {
                        if (nvCheckPushClickTimeCounter < 20) {
                            return [self nvPushClickCheckInSeconds: seconds withBlock: nvPushCheckBlock];
                        }
                    }
                });
            }
        } else {
            nvPushCheckBlock(^(BOOL isRepeat) {
                if (isRepeat) {
                    if (nvCheckPushClickTimeCounter < 20) {
                        return [self nvPushClickCheckInSeconds: seconds withBlock: nvPushCheckBlock];
                    }
                }
            });
        }
    });
}


@end
