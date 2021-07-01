package com.flutter.notifyvisitors;

import android.app.Activity;
import android.app.Application;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.notifyvisitors.notifyvisitors.NotifyVisitorsApi;
import com.notifyvisitors.notifyvisitors.NotifyVisitorsApplication;
import com.notifyvisitors.notifyvisitors.interfaces.NotificationCountInterface;
import com.notifyvisitors.notifyvisitors.interfaces.NotificationListDetailsCallback;
import com.notifyvisitors.notifyvisitors.interfaces.OnEventTrackListener;
import com.notifyvisitors.notifyvisitors.interfaces.OnNotifyBotClickListener;
import com.notifyvisitors.notifyvisitors.push.NVNotificationChannels;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Set;

import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.NewIntentListener;


/**
 * NotifyvisitorsPlugin
 * Author - Neeraj Sharma
 */
public class NotifyvisitorsPlugin extends BroadcastReceiver implements FlutterPlugin, MethodCallHandler, ActivityAware, NewIntentListener {
    private MethodChannel channel;

    private static final String TAG = "NotifyVisitors-Flutter";
    private Context flutterContext;
    private Activity mainActivity;

    Result showCallback, eventCallback, commonCallback;

    private ArrayList<Result> _handlers = new ArrayList<Result>();
    private String lastEvent = null;

    @Override
    public void onAttachedToEngine(FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), "flutter_notifyvisitors");
        channel.setMethodCallHandler(this);
        flutterContext = binding.getApplicationContext();
        init(flutterContext);

        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction(Intent.ACTION_VIEW);

        LocalBroadcastManager manager = LocalBroadcastManager.getInstance(binding.getApplicationContext());
        manager.registerReceiver(this, intentFilter);
    }

    private void init(Context context) {
        Log.i(TAG, "INIT !!");
        try {
            fetchEventSurvey(context);
            showCallback = null;
            eventCallback = null;
            commonCallback = null;
        } catch (Exception e) {
            Log.i(TAG, "INIT ERROR : " + e);
        }

    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else if (call.method.equals("initialize")) {
            Log.i(TAG, "INITIALIZE !!");
            this.initialize(call, result);
        } else if (call.method.equals("show")) {
            Log.i(TAG, "SHOW !!");
            this.showInApp(call, result);
        } else if (call.method.equals("showNotifications")) {
            Log.i(TAG, "SHOW NOTIFICATIONS!!");
            this.openNotificationCenter(call, result);
        } else if (call.method.equals("event")) {
            Log.i(TAG, "EVENT !!");
            this.event(call, result);
        } else if (call.method.equals("stopNotifications")) {
            Log.i(TAG, "STOP NOTIFICATIONS !!");
            this.stopNotifications(call, result);
        } else if (call.method.equals("stopPushNotifications")) {
            Log.i(TAG, "STOP PUSH NOTIFICATIONS !!");
            this.stopPushNotifications(call, result);
        } else if (call.method.equals("notificationDataListener")) {
            Log.i(TAG, "GET NOTIFICATION DATA LISTENER !!");
            this.getNotificationData(call, result);
        } else if (call.method.equals("notificationCount")) {
            Log.i(TAG, "GET NOTIFICATION COUNT !!");
            this.getNotificationCount(call, result);
        } else if (call.method.equals("scheduleNotification")) {
            Log.i(TAG, "SCHEDULE NOTIFICATION !!");
            this.schedulePushNotification(call, result);
        } else if (call.method.equals("userIdentifier")) {
            Log.i(TAG, "USER IDENTIFIER !!");
            this.userIdentifier(call, result);
        } else if (call.method.equals("stopGeofencePushforDateTime")) {
            Log.i(TAG, "STOP GEOFENCE PUSH FOR DATE TIME !!");
            this.stopGeofencePushforDateTime(call, result);
        } else if (call.method.equals("getLinkInfo")) {
            Log.i(TAG, "GET LINK INFO !!");
            this.getLinkInfo(call, result);
        } else if (call.method.equals("scrollViewDidScroll_IOS")) {
            Log.i(TAG, "FOR IOS ONLY !!");
        } else if (call.method.equals("autoStartPermission")) {
            Log.i(TAG, "AUTOSTART PERMISSION !!");
            this.autoStartPermission(call, result);
        } else if (call.method.equals("startChatBot")) {
            Log.i(TAG, "START CHAT BOT !!");
            this.startChatBot(call, result);
        } else if (call.method.equals("getNvUID")) {
            Log.i(TAG, "GET NV UID !!");
            this.getNvUID(call, result);
        } else if (call.method.equals("createNotificationChannel")) {
            Log.i(TAG, "CREATE NOTIFICATION CHANNEL !!");
            this.createNotificationChannel(call, result);
        } else if (call.method.equals("deleteNotificationChannel")) {
            Log.i(TAG, "DELETE NOTIFICATION CHANNEL !! ");
            this.deleteNotificationChannel(call, result);
        } else if (call.method.equals("createNotificationChannelGroup")) {
            Log.i(TAG, "CREATE NOTIFICATION CHANNEL GROUP !!");
            this.createNotificationChannelGroup(call, result);
        } else if (call.method.equals("deleteNotificationChannelGroup")) {
            Log.i(TAG, "DELETE NOTIFICATION CHANNEL GROUP !!");
            this.deleteNotificationChannelGroup(call, result);
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        Log.i(TAG, "ON DETACHED FROM ENGINE !!");
        channel.setMethodCallHandler(null);
        LocalBroadcastManager.getInstance(binding.getApplicationContext()).unregisterReceiver(this);
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        Log.i(TAG, "ON ATTACHED TO ACTIVITY !!");
        binding.addOnNewIntentListener(this);
        mainActivity = binding.getActivity();
        Intent mIntent = binding.getActivity().getIntent();
        try {
            if (mIntent != null) {
                handleIntent(mIntent);
            }
        } catch (Exception e) {
            Log.i(TAG, "ON NEW INTENT ERROR : " + e);
        }

    }

    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
        Log.i(TAG, "ON REATTACHED TO ACTIVITY FOR CONFIG CHANGES !!");
        binding.addOnNewIntentListener(this);
        this.mainActivity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivity() {
        Log.i(TAG, "ON DETACHED FROM ACTIVITY !!");
        this.mainActivity = null;
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        Log.i(TAG, "ON DETACHED FROM ACTIVITY FOR CONFIG CHANGES !!");
        this.mainActivity = null;
    }

    @Override
    public boolean onNewIntent(Intent intent) {
        Log.i(TAG, "ON NEW INTENT !!");
        Toast.makeText(flutterContext, "ON NEW INTENT : ", Toast.LENGTH_LONG).show();
        try {
            if (intent != null) {
                handleIntent(intent);
            }
        } catch (Exception e) {
            Log.i(TAG, "ON NEW INTENT ERROR : " + e);
        }
        return false;
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        Log.i(TAG, "ON RECEIVE !!");
        handleIntent(intent);
    }

    /* handleIntent method start */
    private void handleIntent(Intent intent) {
        Log.i(TAG, "INSIDE HANDLE INTENT !!!!");

        JSONObject dataInfo, finalDataInfo;
        String action = intent.getAction();
        Uri url = intent.getData();
        finalDataInfo = new JSONObject();

        // if app was not launched by the url - ignore
        if (!Intent.ACTION_VIEW.equals(action) || url == null) {
            if (intent.hasExtra("source") && intent.getStringExtra("source").equalsIgnoreCase("nv")) {
                try {
                    Bundle bundle = intent.getExtras();
                    if (bundle != null) {
                        dataInfo = new JSONObject();
                        String nv_type = "push";
                        for (String key : bundle.keySet()) {
                            try {
                                dataInfo.put(key, JSONObject.wrap(bundle.get(key)));
                                if (key.equals("nv_type")) {
                                    try {
                                        nv_type = bundle.get(key).toString();
                                    } catch (Exception e) {
                                        //e.printStackTrace();
                                    }
                                }

                            } catch (Exception e) {
                                //e.printStackTrace();
                            }
                        }
                        dataInfo.put("type", nv_type);
                        finalDataInfo.put("parameters", dataInfo);
                        lastEvent = finalDataInfo.toString();
                        consumeEvents();
                    }
                } catch (Exception e) {
                    Log.i(TAG, "HANDLE INTENT PARSE DATA ERROR : " + e);
                }
            }
        } else {
            try {
                Set<String> queryParameter = url.getQueryParameterNames();
                dataInfo = new JSONObject();
                for (String s : queryParameter) {
                    String mValue = url.getQueryParameter(s);
                    dataInfo.put(s, mValue);
                }
                finalDataInfo.put("parameters", dataInfo);
            } catch (Exception e) {
                Log.i(TAG, "QUERY PARAMETER ERROR : " + e);
            }

            try {
                JSONObject info = new JSONObject();
                String mSchema = url.getScheme();
                String host = url.getHost();
                String path = url.getPath();
                info.put("scheme", mSchema);
                info.put("host", host);
                info.put("path", path);
                info.put("source", "nv");

                finalDataInfo.put("url", info);
                lastEvent = finalDataInfo.toString();
                consumeEvents();

                //Log.e(TAG, "lastEvent = "+lastEvent);
            } catch (Exception e) {
                Log.i(TAG, "JSON OBJECT ERROR : " + e);
            }
        }
    }
    /* handleIntent method end */

    public static void register(Context context) {
        Log.i(TAG, "REGISTER !!");
        try {
            NotifyVisitorsApplication.register((Application) context.getApplicationContext());
        } catch (Exception e) {
            Log.i(TAG, "REGISTER ERROR : " + e.toString());
        }
    }

    private void initialize(MethodCall call, Result reply) {
        try {
            NotifyVisitorsApplication.register((Application) flutterContext.getApplicationContext());
            reply.success("success");
        } catch (Exception e) {
            Log.i(TAG, "INITIALIZE ERROR : " + e);
        }

    }

    private void showInApp(MethodCall call, Result reply) {
        showCallback = reply;
        try {
            JSONObject tokens = null;
            JSONObject customRules = null;
            String fragmentName = null;

            try {
                HashMap<String, Object> hToken = call.argument("tokens");
                if (hToken != null)
                    tokens = new JSONObject(hToken);
            } catch (Exception e) {
                Log.i(TAG, "TOKENS ERROR : " + e);
            }

            try {
                HashMap<String, Object> hCustomRules = call.argument("customRules");
                if (hCustomRules != null)
                    customRules = new JSONObject(hCustomRules);
            } catch (Exception e) {
                Log.i(TAG, "CUSTOM RULES ERROR : " + e);
            }

            try {
                HashMap<String, Object> hFragmentName = call.argument("fragmentName");
                if (hFragmentName != null) {
                    JSONObject jFragmentName = new JSONObject(hFragmentName);
                    fragmentName = jFragmentName.getString("fragmentName");
                }

            } catch (Exception e) {
                Log.i(TAG, "FRAGMENT NAME ERROR : " + e);
            }

            NotifyVisitorsApi.getInstance(mainActivity).show(tokens, customRules, fragmentName);

        } catch (Exception e) {
            Log.i(TAG, "ERROR : " + e);
        }

    }

    private void openNotificationCenter(MethodCall call, Result reply) {
        try {
            int iDismissValue = 0;
            try {
                iDismissValue = call.argument("dismissValue");
            } catch (Exception e) {
                Log.i(TAG, "DISMISS VALUE ERROR : " + e);
            }
            NotifyVisitorsApi.getInstance(flutterContext).showNotifications(iDismissValue);
        } catch (Exception e) {
            Log.i(TAG, "ERROR : " + e);
        }
    }

    private void event(MethodCall call, Result reply) {
        eventCallback = reply;
        try {
            String eventName = null;
            String lifeTimeValue = null;
            String scope = null;
            JSONObject attributes = null;

            try {
                eventName = call.argument("eventName");
            } catch (Exception e) {
                Log.i(TAG, "EVENT NAME ERROR : " + e);
            }

            try {
                HashMap<String, Object> hAttributes = call.argument("attributes");
                if (hAttributes != null) {
                    attributes = new JSONObject(hAttributes);
                }
            } catch (Exception e) {
                Log.i(TAG, "EVENT ATTRIBUTES ERROR : " + e);
            }

            try {
                lifeTimeValue = call.argument("lifeTimeValue");
            } catch (Exception e) {
                Log.i(TAG, "EVENT LTV ERROR : " + e);
            }

            try {
                scope = call.argument("scope");
            } catch (Exception e) {
                Log.i(TAG, "ERROR : " + e);
            }

            NotifyVisitorsApi.getInstance(flutterContext).event(eventName, attributes, lifeTimeValue, scope);
        } catch (Exception e) {
            Log.i(TAG, "ERROR : " + e);
        }
    }

    private void stopNotifications(MethodCall call, Result reply) {
        try {
            NotifyVisitorsApi.getInstance(flutterContext).stopNotification();
            reply.success("success");
        } catch (Exception e) {
            Log.i(TAG, "STOP NOTIFICATIONS ERROR : " + e);
            reply.success("fail");
        }
    }

    private void stopPushNotifications(MethodCall call, Result reply) {
        try {
            boolean bValue = true;
            try {
                bValue = call.argument("value");
            } catch (Exception e) {
                Log.i(TAG, "ERROR IN GET BOOLEAN VALUE : " + e);
                Log.i(TAG, "TRUE VALUE PASSED ");
            }
            NotifyVisitorsApi.getInstance(flutterContext).stopPushNotification(bValue);
        } catch (Exception e) {
            Log.i(TAG, "STOP PUSH NOTIFICATIONS ERROR : " + e);
        }
    }

    private void getNotificationData(MethodCall call, final Result reply) {
        try {
            NotifyVisitorsApi.getInstance(flutterContext).getNotificationDataListener(new NotificationListDetailsCallback() {
                @Override
                public void getNotificationData(JSONArray notificationListResponse) {
                    Log.i(TAG, "RESPONSE : " + notificationListResponse);
                    reply.success(notificationListResponse.toString());
                }
            }, 0);

        } catch (Exception e) {
            Log.i(TAG, "GET NOTIFICATION DATA LISTENER ERROR : " + e);
        }
    }

    private void getNotificationCount(MethodCall call, final Result reply) {
        try {
            NotifyVisitorsApi.getInstance(flutterContext).getNotificationCount(new NotificationCountInterface() {
                @Override
                public void getCount(int count) {
                    Log.i(TAG, "COUNT : " + count);
                    String strI = String.valueOf(count);
                    reply.success(strI);
                }
            });
        } catch (Exception e) {
            Log.i(TAG, "GET NOTIFICATION COUNT ERROR : " + e);
        }
    }

    private void schedulePushNotification(MethodCall call, Result reply) {
        try {
            String nid;
            String tag;
            String time;
            String title;
            String message;
            String url;
            String icon;


            try {
                nid = call.argument("nid");
            } catch (Exception e) {
                Log.i(TAG, "NID ERROR : " + e);
                nid = null;
            }

            try {
                tag = call.argument("tag");
            } catch (Exception e) {
                Log.i(TAG, " TAG ERROR : " + e);
                tag = null;
            }

            try {
                time = call.argument("time");
            } catch (Exception e) {
                Log.i(TAG, "TIME ERROR : " + e);
                time = null;
            }

            try {
                title = call.argument("title");
            } catch (Exception e) {
                Log.i(TAG, "TITLE ERROR : " + e);
                title = null;
            }

            try {
                message = call.argument("msg");
            } catch (Exception e) {
                Log.i(TAG, "MSG ERROR : " + e);
                message = null;
            }

            try {
                url = call.argument("url");
            } catch (Exception e) {
                Log.i(TAG, "URL ERROR : " + e);
                url = null;
            }

            try {
                icon = call.argument("icon");
            } catch (Exception e) {
                Log.i(TAG, "ICON ERROR : " + e);
                icon = null;
            }

            NotifyVisitorsApi.getInstance(flutterContext).scheduleNotification(nid, tag, time, title, message, url, icon);
        } catch (Exception e) {
            Log.i(TAG, "SCHEDULE NOTIFICATION ERROR : " + e);
        }
    }

    private void userIdentifier(MethodCall call, Result reply) {
        try {
            String userId = null;
            JSONObject attributes = null;

            try {
                userId = call.argument("userId");
            } catch (Exception e) {
                Log.i(TAG, "USER-ID ERROR : " + e);
            }

            try {
                HashMap<String, Object> hAttributes = call.argument("attributes");
                if (hAttributes != null) {
                    attributes = new JSONObject(hAttributes);
                }
            } catch (Exception e) {
                Log.i(TAG, "ATTRIBUTES ERROR : " + e);
            }

            NotifyVisitorsApi.getInstance(flutterContext).userIdentifier(userId, attributes);
            reply.success("success");
        } catch (Exception e) {
            Log.i(TAG, "USER IDENTIFIER ERROR : " + e);
        }
    }

    private void stopGeofencePushforDateTime(MethodCall call, Result reply) {
        try {
            String dateTime = null;
            String additionalHours;
            int jAdditionalHours;
            boolean lock = true;

            try {
                dateTime = call.argument("dateTime");
                if (dateTime == null || dateTime.length() == 0) {
                    Log.i(TAG, "DATETIME CAN NOT BE NULL OR EMPTY");
                    lock = false;
                }
            } catch (Exception e) {
                Log.i(TAG, "DATE-TIME ERROR : " + e);
            }

            try {
                additionalHours = call.argument("additionalHours");
                if (additionalHours == null || additionalHours.length() == 0) {
                    jAdditionalHours = 0;
                } else {
                    jAdditionalHours = Integer.parseInt(additionalHours);
                }
            } catch (Exception e) {
                Log.i(TAG, "ADDITIONAL-HOURS ERROR : " + e);
                jAdditionalHours = 0;
            }


            if (lock) {
                NotifyVisitorsApi.getInstance(flutterContext).stopGeofencePushforDateTime(dateTime, jAdditionalHours);
                lock = true;
            }

        } catch (Exception e) {
            Log.i(TAG, "STOP GEOFENCE PUSH FOR DATE TIME ERROR : " + e);
        }

    }

    private void autoStartPermission(MethodCall call, Result reply) {
        try {
            NotifyVisitorsApi.getInstance(flutterContext).setAutoStartPermission(mainActivity);
        } catch (Exception e) {
            Log.i(TAG, "SET AUTOSTART PERMISSION ERROR : " + e);
        }
    }

    private void startChatBot(MethodCall call, final Result reply) {
        try {
            String screenName;
            screenName = call.argument("screenName");

            if (screenName == null || screenName.equalsIgnoreCase("empty")) {
                Log.i(TAG, "SCREEN NAME IS MISSING");
            } else {
                NotifyVisitorsApi.getInstance(mainActivity).startChatBot(screenName, new OnNotifyBotClickListener() {
                    @Override
                    public void onInAppRedirection(JSONObject data) {
                        String chatBotButtonClick = data.toString();
                        reply.success(chatBotButtonClick);
                    }
                });
            }

        } catch (Exception e) {
            Log.i(TAG, "START CHAT BOT ERROR : " + e);
        }
    }

    private void getNvUID(MethodCall call, Result reply) {
        try {
            String nvUid = NotifyVisitorsApi.getInstance(flutterContext).getNvUid();
            reply.success(nvUid);
        } catch (Exception e) {
            Log.i(TAG, "GET NV UID ERROR : " + e);
        }
    }

    private void createNotificationChannel(MethodCall call, Result reply) {
        try {
            String chId = "";
            String chName = "";
            String chDescription = "";
            String chImportance = null;
            boolean enableLights = true;
            boolean shouldVibrate = true;
            String lightColor = null;
            String soundFileName = null;

            try {
                chId = call.argument("channelId");
            } catch (Exception e) {
                Log.i(TAG, "CHANNEL-ID ERROR : " + e);
            }

            try {
                chName = call.argument("channelName");
            } catch (Exception e) {
                Log.i(TAG, "CHANNEL-NAME ERROR : " + e);
            }

            try {
                chDescription = call.argument("channelDescription");
            } catch (Exception e) {
                Log.i(TAG, "CHANNEL-DESCRIPTION ERROR : " + e);
            }

            try {
                chImportance = call.argument("channelImportance");
            } catch (Exception e) {
                Log.i(TAG, "CHANNEL-IMPORTANCE ERROR : " + e);
            }

            try {
                enableLights = call.argument("enableLights");
            } catch (Exception e) {
                Log.i(TAG, "ENABLE-LIGHTS ERROR : " + e);
            }

            try {
                shouldVibrate = call.argument("shouldVibrate");
            } catch (Exception e) {
                Log.i(TAG, "SHOULD-VIBRATE ERROR : " + e);
            }

            try {
                lightColor = call.argument("lightColor");
            } catch (Exception e) {
                Log.i(TAG, "LIGHT-COLOR ERROR : " + e);
            }

            try {
                soundFileName = call.argument("soundFileName");
            } catch (Exception e) {
                Log.i(TAG, "SOUND-FILE-NAME ERROR : " + e);
            }

            int iChImportance = 3;


            if (lightColor == null || lightColor.isEmpty()) {
                lightColor = "#ffffff";
            }

            if (soundFileName == null || soundFileName.isEmpty()) {
                soundFileName = "";
            }
            if (chImportance != null && !chImportance.isEmpty()) {
                iChImportance = Integer.parseInt(chImportance);
            }


            NVNotificationChannels.Builder builder1 = new NVNotificationChannels.Builder();
            builder1.setChannelID(chId);
            builder1.setChannelName(chName);
            builder1.setImportance(iChImportance);
            builder1.setChannelDescription(chDescription);
            builder1.setEnableLights(enableLights);
            builder1.setLightColor(Color.parseColor(lightColor));
            builder1.setSoundFileName(soundFileName);
            builder1.setShouldVibrate(shouldVibrate);
            builder1.setVibrationPattern(new long[]{1000, 1000, 1000, 1000, 1000});
            builder1.build();

            Set<NVNotificationChannels.Builder> nChannelSets = new HashSet<>();
            nChannelSets.add(builder1);

            NotifyVisitorsApi.getInstance(flutterContext).createNotificationChannel(nChannelSets);
        } catch (Exception e) {
            Log.i(TAG, "CREATE NOTIFICATION CHANNEL ERROR : " + e);
        }
    }

    private void deleteNotificationChannel(MethodCall call, Result reply) {
        try {
            String channelId = "";
            try {
                channelId = call.argument("channelId");
            } catch (Exception e) {
                Log.i(TAG, "CHANNEL-id ERROR : " + e);
            }
            NotifyVisitorsApi.getInstance(flutterContext).deleteNotificationChannel(channelId);
            reply.success("success");
        } catch (Exception e) {
            Log.i(TAG, "DELETE NOTIFICATION CHANNEL ERROR : " + e);
        }
    }

    private void createNotificationChannelGroup(MethodCall call, Result reply) {
        try {
            String groupId = "";
            String groupName = "";

            try {
                groupId = call.argument("groupId");
            } catch (Exception e) {
                Log.i(TAG, "GROUP-ID ERROR : " + e);
            }

            try {
                groupName = call.argument("groupName");
            } catch (Exception e) {
                Log.i(TAG, "GROUP-NAME ERROR : " + e);
            }


            NotifyVisitorsApi.getInstance(flutterContext).createNotificationChannelGroup(groupId, groupName);
            reply.success("success");
        } catch (Exception e) {
            Log.i(TAG, "CREATE NOTIFICATION CHANNEL GROUP ERROR : " + e);
        }
    }

    private void deleteNotificationChannelGroup(MethodCall call, Result reply) {
        try {
            String groupId = "";
            try {
                groupId = call.argument("groupId");
            } catch (Exception e) {
                Log.i(TAG, "GROUP-ID ERROR : " + e);
            }

            NotifyVisitorsApi.getInstance(flutterContext).deleteNotificationChannelGroup(groupId);
            reply.success("success");
        } catch (Exception e) {
            Log.i(TAG, "DELETE NOTIFICATION CHANNEL GROUP ERROR " + e);
        }
    }

    public void getLinkInfo(MethodCall call, Result reply) {
        try {
            try {
                addHandler(reply);
            } catch (Exception e) {
                //e.printStackTrace();
            }
        } catch (Exception e) {
            Log.i(TAG, "GET LINK INFO ERROR : " + e);
        }
    }

    private void addHandler(final Result result) {
        this._handlers.add(result);
        this.consumeEvents();
    }

    private void consumeEvents() {
        if (this._handlers.size() == 0 || lastEvent == null) {
            return;
        }

        for (Result callback : this._handlers) {
            sendToDart(lastEvent, callback);
        }
        lastEvent = null;
    }

    private void sendToDart(String event, Result result) {
        Log.i(TAG, "SEND DATA TO DART FILE !! ");
        try {
            channel.invokeMethod("GetLinkInfo", event);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void fetchEventSurvey(Context context) {
        Log.i(TAG, "FETCH EVENT SURVEY RESPONSE !!");
        try {
            NotifyVisitorsApi.getInstance(context).getEventResponse(new OnEventTrackListener() {
                @Override
                public void onResponse(JSONObject response) {
                    sendResponse(response);
                }
            });
        } catch (Exception e) {
            Log.i(TAG, "FETCH EVENT SURVEY ERROR : " + e);
        }

    }

    private void sendResponse(JSONObject response) {
        try {
            if (response != null) {
                String eventName = response.getString("eventName");
                String result = response.toString();

                // check clicked is banner or survey
                if (eventName.equalsIgnoreCase("Survey Submit") ||
                        eventName.equalsIgnoreCase("Survey Attempt") ||
                        eventName.equalsIgnoreCase("Banner Clicked")) {
                    if (showCallback != null) {
                        channel.invokeMethod("ShowResponse", result);
                    } else {
                        Log.i(TAG, "SHOW CALLBACK CONTEXT IS NULL !!");
                    }
                } else {
                    if (eventCallback != null) {
                        channel.invokeMethod("EventResponse", result);
                    } else {
                        Log.i(TAG, "EVENT CALLBACK CONTEXT IS NULL !!");
                    }
                }

                // send commom callback
                if (commonCallback != null) {
                    channel.invokeMethod("EventSurveyCallback", result);
                } else {
                    Log.i(TAG, "EVENT-SURVEY CALLBACK CONTEXT IS NULL !!");
                }
            } else {
                Log.i(TAG, "RESPONSE IS NULL !!");
            }

        } catch (Exception e) {
            Log.i(TAG, "SURVEY SEND RESPONSE ERROR : " + e);
        }
    }
}
