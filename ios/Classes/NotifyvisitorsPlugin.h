#import <Flutter/Flutter.h>
#import <notifyvisitors/notifyvisitors.h>
#if __has_include(<UserNotifications/UserNotifications.h>)
#import <UserNotifications/UserNotifications.h>
#else
#import "UserNotifications.h"
#endif

#define TAG @"FLUTTER-NOTIFYVISITORS"
#define PLUGIN_VERSION @"1.0.0"
#define SHOW @"show"
#define NOTIFICATION_CENTER @"showNotifications"
#define EVENT @"event"
#define STOP_SHOW_INAPP @"stopNotifications"
#define STOP_PUSH @"stopPushNotifications"
#define GET_NOTIFICATION_DATA @"notificationDataListener"
#define NOTIFICATION_COUNT @"notificationCount"
#define SCHEDULE_NOTIFICATION @"scheduleNotification"
#define HIT_USER @"userIdentifier"
#define STOP_GEOFENCE @"stopGeofencePushforDateTime"
#define PUSH_CLICK @"getLinkInfo"
#define SCROLL_VIEW_DID_SCROLL @"scrollViewDidScroll_IOS"
#define ANDROID_AUTO_START @"autoStartPermission"
#define CHAT_BOT @"startChatBot"
#define NV_UID @"getNvUID"
#define EVENT_SURVEY_INFO @"getEventSurveyInfo"
#define ANDROID_DUMMMY1 @"createNotificationChannel"
#define ANDROID_DUMMMY2 @"deleteNotificationChannel"
#define ANDROID_DUMMMY3 @"createNotificationChannelGroup"
#define ANDROID_DUMMMY4 @"deleteNotificationChannelGroup"


@interface NotifyvisitorsPlugin : NSObject<FlutterPlugin, notifyvisitorsDelegate, UNUserNotificationCenterDelegate>{
    NSMutableArray *_handlers;
    FlutterResult _lastEvent;
}

@property (strong, nonatomic) FlutterMethodChannel * channel;

+ (instancetype)sharedInstance;


// SDK initialization
+(void)Initialize;

+(void)RegisterPushWithDelegate:(id _Nullable)delegate App:(UIApplication * _Nullable)application launchOptions:(NSDictionary *_Nullable)launchOptions;


//for simple push

+(void)application:(UIApplication *_Nullable)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *_Nullable)deviceToken;

+(void)application:(UIApplication *_Nullable)application didFailToRegisterForRemoteNotificationsWithError:(NSError *_Nullable)error;
    
+(void)application:(UIApplication *_Nullable)application didReceiveRemoteNotification:(NSDictionary *_Nullable)userInfo;

// app termination

+(void)applicationWillTerminate;


// ios 10 push methods
+(void)willPresentNotification:(UNNotification *_Nullable)notification withCompletionHandler:(void (^_Nullable)(UNNotificationPresentationOptions options))completionHandler API_AVAILABLE(ios(10.0));

+(void)didReceiveNotificationResponse:(UNNotificationResponse *_Nullable)response API_AVAILABLE(ios(10.0));

+(void)application:(UIApplication *_Nullable)application didReceiveRemoteNotification:(NSDictionary *_Nullable)userInfo
fetchCompletionHandler:(void (^_Nullable)(UIBackgroundFetchResult))completionHandler;


//Geofencing methods

+(void)applicationDidEnterBackground:(UIApplication *_Nullable)application;
+(void)applicationDidBecomeActive:(UIApplication *_Nullable)application;
+(void)NotifyVisitorsGeofencingReceivedNotificationWithApplication:(UIApplication *_Nullable)application localNotification:(UILocalNotification *_Nullable) notification;


//open Url Application

+(void)openUrl:(UIApplication *_Nullable)application openURL:(NSURL *_Nullable)url;

@end
