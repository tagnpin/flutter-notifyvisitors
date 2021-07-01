import 'dart:async';

import 'package:flutter/services.dart';

// Handlers for various events
typedef void ShowCallback(String response);
typedef void EventCallback(String response);
typedef void GetClickInfo(String response);
typedef void ChatBotClick(String response);
typedef void EventSurvryInfo(String response);


class Notifyvisitors {

  static Notifyvisitors shared = new Notifyvisitors();

  MethodChannel _channel = const MethodChannel('flutter_notifyvisitors');

  // event handlers
  ShowCallback _showCallback;
  EventCallback _eventCallback;
  GetClickInfo _getClickInfo;
  ChatBotClick _chatBotClick;
  EventSurvryInfo _eventSurvryInfo;

  Notifyvisitors() {
    this._channel.setMethodCallHandler(_handleMethod);
  }

  Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  Future<void> show(var tokens, var customRules, var fragmentName,
      ShowCallback handler) async {
    _showCallback = handler;
    var inAppInfo = {
      'tokens': tokens,
      'customRules': customRules,
      'fragmentName': fragmentName
    };
    await _channel.invokeMethod('show', inAppInfo);
  }

  Future<void> showNotifications(int dismiss) async {
    var showInfo = {'dismissValue': dismiss};
    await _channel.invokeMethod('showNotifications', showInfo);
  }

  Future<void> event(String eventName, var attributes, String lifeTimeValue,
      String scope, EventCallback handler) async {
    _eventCallback = handler;
    var eventInfo = {
      'eventName': eventName,
      'attributes': attributes,
      'lifeTimeValue': lifeTimeValue,
      'scope': scope
    };
    await _channel.invokeMethod('event', eventInfo);
  }

  Future<void> userIdentifier(String userId, var attributes) async {
    var userInfo = {
      'userId': userId,
      'attributes': attributes
    };
    await _channel.invokeMethod('userIdentifier', userInfo);
  }

  Future<void> stopNotifications() async {
    await _channel.invokeMethod('stopNotifications');
  }

  Future<void> stopPushNotifications(bool value) async {
    var valueInfo = {"value": value};
    await _channel.invokeMethod('stopPushNotifications', valueInfo);
  }

  Future<String> getNotificationData() async {
    String info = await _channel.invokeMethod('notificationDataListener');
    return info;
  }

  Future<String> getNotificationCount() async {
    String count = await _channel.invokeMethod('notificationCount');
    return count;
  }

  Future<void> scheduleNotification(String nid, String tag, 
      String time, String title, String msg, String url, String icon) async {
      var notificationInfo = {
        'nid' : nid,
        'tag' : tag,
        'time' : time,
        'title' : title,
        'msg' : msg,
        'url' : url,
        'icon' : icon
      };  
    await _channel.invokeMethod('scheduleNotification', notificationInfo);
  }

  Future<void> stopGeofencePushforDateTime(String dateTime, String additionalHours) async {
    var timeInfo = {'dateTime' : dateTime, 'additionalHours' : additionalHours};
    await _channel.invokeMethod('stopGeofencePushforDateTime', timeInfo);
  }

  Future<void> getLinkInfo(GetClickInfo handler) async {
    _getClickInfo = handler;
    await _channel.invokeMethod('getLinkInfo');
  }

  Future<void> autoStartPermission() async {
    await _channel.invokeMethod('autoStartPermission');
  }

  Future<void> startChatBot(String screenName, ChatBotClick handler) async {
    _chatBotClick = handler;
    var botInfo = {"screenName": screenName};
    await _channel.invokeMethod('startChatBot', botInfo);
  }

  Future<String> getNvUID() async {
    String nvUdid = await _channel.invokeMethod('getNvUID');
    return nvUdid;
  }

  Future<void> createNotificationChannel(String channelId, String channelName,
      String channelDescription, String channelImportance, bool enableLights,
      bool shouldVibrate, String lightColor, String soundFileName) async {
    var channelInfo = {
      'channelId': channelId,
      'channelName': channelName,
      'channelDescription': channelDescription,
      'channelImportance': channelImportance,
      'enableLights': enableLights,
      'shouldVibrate': shouldVibrate,
      'lightColor': lightColor,
      'soundFileName': soundFileName
    };
    await _channel.invokeMethod('createNotificationChannel', channelInfo);
  }

  Future<void> deleteNotificationChannel(String channelId) async {
    var channelInfo = {
      'channelId': channelId,
    };
    await _channel.invokeMethod('deleteNotificationChannel', channelInfo);
  }

  Future<void> createNotificationChannelGroup(String groupId,
      String groupName) async {
    var channelInfo = {
      'groupId': groupId,
      'groupName': groupName
    };
    await _channel.invokeMethod('createNotificationChannelGroup', channelInfo);
  }

  Future<void> deleteNotificationChannelGroup(String groupId) async {
    var channelInfo = {
      'groupId': groupId
    };
    await _channel.invokeMethod('deleteNotificationChannelGroup', channelInfo);
  }

  Future<void> getEventSurveyInfo(EventSurvryInfo handler) async {
    _eventSurvryInfo = handler;
    await _channel.invokeMethod('getEventSurveyInfo');
  }

  Future<void> scrollViewDidScrollIOS() async {
    await _channel.invokeMethod('scrollViewDidScroll_IOS');
  }

  // Private function that gets called by ObjC/Java
  Future<Null> _handleMethod(MethodCall call) async {
    if (call.method == "GetLinkInfo") {
      this._getClickInfo(call.arguments.toString());
    } else if (call.method == "ShowResponse") {
      this._showCallback(call.arguments.toString());
    } else if (call.method == "EventResponse") {
      this._eventCallback(call.arguments.toString());
    } else if (call.method == "ChatBotResponse") {
      this._chatBotClick(call.arguments.toString());
    } else if (call.method == "EventSurveyResponse") {
      this._eventSurvryInfo(call.arguments.toString());
    }
    return null;
  }

}
