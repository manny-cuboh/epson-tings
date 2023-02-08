package com.epsonepossdk.ReactNative;

import static com.epson.epos2.Epos2CallbackCode.*;
import static com.epson.epos2.Epos2Exception.*;
import static com.epson.epos2.Epos2CallbackCode.*;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Base64;
import android.widget.ImageView;

import androidx.annotation.Nullable;

import com.epson.epos2.discovery.DeviceInfo;
import com.epson.epos2.discovery.Discovery;
import com.epson.epos2.discovery.DiscoveryListener;
import com.epson.epos2.discovery.FilterOption;
import com.epson.epos2.printer.StatusChangeListener;
import com.epsonepossdk.MainApplication;
import com.facebook.react.ReactInstanceManager;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.Arguments;

import java.io.IOException;
import java.net.URL;
import java.util.Map;
import java.util.HashMap;

import com.epson.epos2.Epos2Exception;
import com.epson.epos2.Log;
import com.epson.epos2.printer.Printer;
import com.epson.epos2.printer.PrinterStatusInfo;
import com.epson.epos2.printer.ReceiveListener;
import com.epson.epos2.discovery.DeviceInfo;
import com.epson.epos2.discovery.Discovery;
import com.epson.epos2.discovery.DiscoveryListener;
import com.epson.epos2.discovery.FilterOption;
import com.facebook.react.bridge.WritableMap;

import org.json.JSONObject;

public class EpsonEposSDK extends ReactContextBaseJavaModule implements ReceiveListener, StatusChangeListener {
    private Context mContext = null;
    private ReactApplicationContext mReactApplicationContext = null;

    private static Printer printer_;
    private static Integer printerSeries_;
    private static Integer lang_;
    private static Boolean connected_;

    public EpsonEposSDK(ReactApplicationContext context) {
        super(context);

        mContext = context.getApplicationContext();
        mReactApplicationContext = context;

        // Setup general items
        printer_ = null;
        printerSeries_ = Printer.TM_T88;
        lang_ = Printer.MODEL_ANK;
        connected_ = false;
    }

    @Override
    public String getName() {
        return "EpsonEposSDK";
    }

    @ReactMethod
    public void addListener(String eventName) {
        // Set up any upstream listeners or background tasks as necessary
    }

    @ReactMethod
    public void removeListeners(Integer count) {
        // Remove upstream listeners, stop unnecessary background tasks
    }

    @Override
    public Map<String, Object> getConstants() {
        final Map<String, Object> constants = new HashMap<>();
        constants.put("EPOS2_FONT_A", Printer.FONT_A);
        constants.put("EPOS2_FONT_B", Printer.FONT_B);
        constants.put("EPOS2_ALIGN_LEFT", Printer.ALIGN_LEFT);
        constants.put("EPOS2_ALIGN_CENTER", Printer.ALIGN_CENTER);
        constants.put("EPOS2_ALIGN_RIGHT", Printer.ALIGN_RIGHT);
        constants.put("EPOS2_TM_M10", Printer.TM_M10);
        constants.put("EPOS2_TM_M30", Printer.TM_M30);
        constants.put("EPOS2_TM_P20", Printer.TM_P20);
        constants.put("EPOS2_TM_P60", Printer.TM_P60);
        constants.put("EPOS2_TM_P60II", Printer.TM_P60II);
        constants.put("EPOS2_TM_P80", Printer.TM_P80);
        constants.put("EPOS2_TM_T20", Printer.TM_T20);
        constants.put("EPOS2_TM_T60", Printer.TM_T60);
        constants.put("EPOS2_TM_T70", Printer.TM_T70);
        constants.put("EPOS2_TM_T81", Printer.TM_T81);
        constants.put("EPOS2_TM_T82", Printer.TM_T82);
        constants.put("EPOS2_TM_T83", Printer.TM_T83);
        constants.put("EPOS2_TM_T88", Printer.TM_T88);
        constants.put("EPOS2_TM_T90", Printer.TM_T90);
        constants.put("EPOS2_TM_T90KP", Printer.TM_T90KP);
        constants.put("EPOS2_TM_U220", Printer.TM_U220);
        constants.put("EPOS2_TM_U330", Printer.TM_U330);
        constants.put("EPOS2_TM_L90", Printer.TM_L90);
        constants.put("EPOS2_TM_H6000", Printer.TM_H6000);
        constants.put("EPOS2_MODEL_ANK", Printer.MODEL_ANK);
        constants.put("EPOS2_MODEL_JAPANESE", Printer.MODEL_JAPANESE);
        constants.put("EPOS2_MODEL_CHINESE", Printer.MODEL_CHINESE);
        constants.put("EPOS2_MODEL_TAIWAN", Printer.MODEL_TAIWAN);
        constants.put("EPOS2_MODEL_KOREAN", Printer.MODEL_KOREAN);
        constants.put("EPOS2_MODEL_THAI", Printer.MODEL_THAI);
        constants.put("EPOS2_MODEL_SOUTHASIA", Printer.MODEL_SOUTHASIA);
        constants.put("EPOS2_MODE_MONO", Printer.MODE_MONO);
        constants.put("EPOS2_MODE_GRAY16", Printer.MODE_GRAY16);
        constants.put("EPOS2_HALFTONE_DITHER", Printer.HALFTONE_DITHER);
        constants.put("EPOS2_HALFTONE_ERROR_DIFFUSION", Printer.HALFTONE_ERROR_DIFFUSION);
        constants.put("EPOS2_HALFTONE_THRESHOLD", Printer.HALFTONE_THRESHOLD);
        return constants;
    }

    private DiscoveryListener mDiscoveryListener = new DiscoveryListener() {
        @Override
        public void onDiscovery(final DeviceInfo deviceInfo) {
//            runOnUiThread(new Runnable() {
//                @Override
//                public synchronized void run() {
//                    HashMap<String, String> item = new HashMap<String, String>();
//                    item.put("PrinterName", deviceInfo.getDeviceName());
//                    item.put("Target", deviceInfo.getTarget());
//                    mPrinterList.add(item);
//                    mPrinterListAdapter.notifyDataSetChanged();
//                }
//            });
            if (deviceInfo.getDeviceName().contains("TM")==true && deviceInfo.getTarget().contains("[")==false) //don't show KDS boxes or ePOS device printers
            {
                int type = getPrinterTypeFromName(deviceInfo.getDeviceName());

                // Create map for params
                WritableMap params = Arguments.createMap();

                // Put data to map
                params.putString("PrinterName", deviceInfo.getDeviceName());
                params.putString("PrinterIP",deviceInfo.getIpAddress());
                params.putInt("PrinterType", type);
                params.putString("PrinterTarget", deviceInfo.getTarget());

                emitMessageToRN(mReactApplicationContext,"PrinterDiscoveryEvent", params);
            }

        }
    };

    //===== ePOS Functions Export =====
    @ReactMethod
    public void discoverPrinters()
    {
        try {
            Discovery.stop();
         }
        catch (Exception e) {
            //ShowMsg.showException(e, "stop", mContext);
        }

        FilterOption filterOption = null;

        filterOption = new FilterOption();

        filterOption.setPortType(Discovery.PORTTYPE_TCP);
        filterOption.setBroadcast("255.255.255.255");
        filterOption.setDeviceModel(Discovery.MODEL_ALL);
        filterOption.setEpsonFilter(Discovery.FILTER_NAME);
        filterOption.setDeviceType(Discovery.TYPE_ALL);

        try {
            Discovery.start(mContext, filterOption, mDiscoveryListener);

            //mBtnStart.setEnabled(false);
            //mBtnStop.setEnabled(true);
        }
        catch (Exception e) {
            ShowMsg.showException(e, "start", mContext);
        }
    }

    @ReactMethod
    public void connect(String target, Integer printerSeries, Integer language, Integer timeout, Promise promise)
    {
        try {
            Discovery.stop();
        }
        catch (Exception e) {
            //ShowMsg.showException(e, "stop", mContext);
        }

        if (connected_)
        {
            return;
        }

        printerSeries_ = printerSeries;

        //Initialize printer object
//        printer_ = [[Epos2Printer alloc] initWithPrinterSeries:printerSeries lang:language];
//        if (printer_ == nil) {
//            reject(@"Error", @"Failed to initialize printer object",nil);
//            //[ShowMsg showErrorEpos:EPOS2_ERR_PARAM method:@"initiWithPrinterSeries"];
//            return;
//        }
        try {
            printer_ = new Printer(printerSeries, language, mContext);
        }
        catch (Exception e) {
            promise.reject("Failed to initialize printer object", e);
            //ShowMsg.showException(e, "Printer", mContext);
            return;
        }

        try {
            printer_.setReceiveEventListener(this);
            printer_.setStatusChangeEventListener(this);
            printer_.setInterval(1000);
        } catch (Epos2Exception e) {
            e.printStackTrace();
            promise.reject(String.format("Failed to connect to the printer: %s", makeEposErrorMessage(e.getErrorStatus())), e);
        }

//        //Connect to printer
//        int result = [printer_ connect:target timeout:timeout];
//        if (result != EPOS2_SUCCESS) {
//            reject(@"Error", [NSString stringWithFormat:@"Failed to connect to the printer: %@", [self makeEposErrorMessage:result]],nil);
//            //[ShowMsg showErrorEpos:result method:@"connect"];
//            return;
//        }

        // Connect to printer
        try {
            printer_.connect(target, timeout);
        }
        catch (Epos2Exception e) {
            promise.reject(String.format("Failed to connect to the printer: %s", makeEposErrorMessage(e.getErrorStatus())), e);
            //ShowMsg.showException(e, "connect", mContext);
            return;
        }


//        //set Callbacks
//        [printer_ setReceiveEventDelegate:self];
//        [printer_ setInterval:1000];
//        [printer_ setStatusChangeEventDelegate:self];

        //start monitor status
        try {
            printer_.startMonitor();
        } catch (Epos2Exception e) {
            e.printStackTrace();
        }

        connected_ = true;
        //resolve([NSNumber numberWithInteger:result]);
        //Double result = Double.valueOf(CODE_SUCCESS);
        promise.resolve(CODE_SUCCESS);
    }

    @ReactMethod
    public void printText(String text, Integer font, Integer alignment, Integer width, Integer height)
    {
        try {
            Discovery.stop();
        }
        catch (Exception e) {
            //ShowMsg.showException(e, "stop", mContext);
        }

        if (!connected_)
        {
            return;
        }

        try {
            printer_.clearCommandBuffer();
            printer_.addTextFont(font);
            printer_.addTextAlign(alignment);
            printer_.addTextSize(width, height);
            printer_.addText(text);
            printer_.sendData(Printer.PARAM_DEFAULT);
        } catch (Epos2Exception e) {
            e.printStackTrace();
        }
    }

    @ReactMethod
    public void printSimpleText(String text)
    {
        try {
            Discovery.stop();
        }
        catch (Exception e) {
            //ShowMsg.showException(e, "stop", mContext);
        }

        if (!connected_)
        {
            return;
        }

        try {
            printer_.clearCommandBuffer();
            printer_.addTextFont(Printer.FONT_A);
            printer_.addTextAlign(Printer.ALIGN_LEFT);
            printer_.addTextSize(1, 1);
            printer_.addText(text);
            printer_.addText("\n");
            printer_.addCut(Printer.CUT_FEED);
            printer_.sendData(Printer.PARAM_DEFAULT);
        } catch (Epos2Exception e) {
            e.printStackTrace();
        }
    }

    @ReactMethod
    public void printImage(String fileUrl, Integer mode, Integer halftone, Promise promise)
    {
        URL url;
        Bitmap img;

        try {
            Discovery.stop();
        }
        catch (Exception e) {
            //ShowMsg.showException(e, "stop", mContext);
        }

        if (!connected_)
        {
            promise.reject("Not connected");
            return;
        }

        //load image from URL
//        UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:fileUrl]]];
//        if (img == nil) {
//            reject(@"Error", @"Failed to load image",nil);
//            return;
//        }
        try {
            url = new URL(fileUrl);
            img = BitmapFactory.decodeStream(url.openConnection().getInputStream());
        } catch (IOException e) {
            e.printStackTrace();
            return;
        }

//        //scale image to paper width
//        int printerWidth = [self getPrinterWidthInDots:printerSeries_];
//        float f = printerWidth/img.size.width;
//        CGSize size = CGSizeMake(printerWidth, (img.size.height*f));
//        UIImage *imgResized = [EpsonEposSDK imageWithImage:img scaledToSize:size];
//        img = imgResized;

        int printerWidth = getPrinterWidthInDots(printerSeries_);
        double f = printerWidth/img.getWidth();
        img = Bitmap.createScaledBitmap(img, printerWidth, img.getHeight(), false);


//            [printer_ clearCommandBuffer];
//            int result = [printer_ addImage:img x:0 y:0 width:img.size.width height:img.size.height color:EPOS2_COLOR_1 mode:mode halftone:halftone brightness:EPOS2_PARAM_DEFAULT compress:EPOS2_COMPRESS_AUTO];
//            if (result != EPOS2_SUCCESS) {
//                reject(@"Error", [self makeEposErrorMessage:result],nil);
//                return;
//            }
//
//            result = [printer_ sendData:EPOS2_PARAM_DEFAULT];
//            if (result != EPOS2_SUCCESS) {
//                reject(@"Error", [self makeEposErrorMessage:result],nil);
//                return;
//            }

        try {
            printer_.clearCommandBuffer();
            printer_.addImage(img, 0, 0, img.getWidth(), img.getHeight(), Printer.COLOR_1,mode, halftone, Printer.PARAM_DEFAULT, Printer.COMPRESS_AUTO);
            printer_.addCut(Printer.CUT_FEED);
            printer_.sendData(Printer.PARAM_DEFAULT);

            promise.resolve(CODE_SUCCESS);

        } catch (Epos2Exception e) {
            e.printStackTrace();
            promise.reject("Failed to print image", e);
        }
    }

    @ReactMethod
    public void printBase64Image(String base64image, Integer mode, Integer halftone, Promise promise)
    {
        Bitmap img;

        try {
            Discovery.stop();
        }
        catch (Exception e) {
            //ShowMsg.showException(e, "stop", mContext);
        }

        if (!connected_)
        {
            promise.reject("Not connected");
            return;
        }

        //load image from URL
//        UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:fileUrl]]];
//        if (img == nil) {
//            reject(@"Error", @"Failed to load image",nil);
//            return;
//        }

        byte[] bitmapdata = Base64.decode(base64image, Base64.DEFAULT);
        img = BitmapFactory.decodeByteArray(bitmapdata, 0, bitmapdata.length);

//        //scale image to paper width
//        int printerWidth = [self getPrinterWidthInDots:printerSeries_];
//        float f = printerWidth/img.size.width;
//        CGSize size = CGSizeMake(printerWidth, (img.size.height*f));
//        UIImage *imgResized = [EpsonEposSDK imageWithImage:img scaledToSize:size];
//        img = imgResized;

        int printerWidth = getPrinterWidthInDots(printerSeries_);
        double f = printerWidth/img.getWidth();
        img = Bitmap.createScaledBitmap(img, printerWidth, img.getHeight(), false);


//            [printer_ clearCommandBuffer];
//            int result = [printer_ addImage:img x:0 y:0 width:img.size.width height:img.size.height color:EPOS2_COLOR_1 mode:mode halftone:halftone brightness:EPOS2_PARAM_DEFAULT compress:EPOS2_COMPRESS_AUTO];
//            if (result != EPOS2_SUCCESS) {
//                reject(@"Error", [self makeEposErrorMessage:result],nil);
//                return;
//            }
//
//            result = [printer_ sendData:EPOS2_PARAM_DEFAULT];
//            if (result != EPOS2_SUCCESS) {
//                reject(@"Error", [self makeEposErrorMessage:result],nil);
//                return;
//            }

        try {
            printer_.clearCommandBuffer();
            printer_.addImage(img, 0, 0, img.getWidth(), img.getHeight(), Printer.COLOR_1,mode, halftone, Printer.PARAM_DEFAULT, Printer.COMPRESS_AUTO);
            printer_.addCut(Printer.CUT_FEED);
            printer_.sendData(Printer.PARAM_DEFAULT);

            promise.resolve(CODE_SUCCESS);

        } catch (Epos2Exception e) {
            e.printStackTrace();
            promise.reject("Failed to print image", e);
        }
    }

    @ReactMethod
    public void cutPaper()
    {
        try {
            Discovery.stop();
        }
        catch (Exception e) {
            //ShowMsg.showException(e, "stop", mContext);
        }

        if (!connected_)
        {
            return;
        }

        try {
            printer_.clearCommandBuffer();
            printer_.addCut(Printer.CUT_FEED);
            printer_.sendData(Printer.PARAM_DEFAULT);
        } catch (Epos2Exception e) {
            e.printStackTrace();
        }
    }

    @ReactMethod
    public void openCashDrawer()
    {
        try {
            Discovery.stop();
        }
        catch (Exception e) {
            //ShowMsg.showException(e, "stop", mContext);
        }

        if (!connected_)
        {
            return;
        }

        try {
            printer_.clearCommandBuffer();
            printer_.addPulse(Printer.DRAWER_2PIN, Printer.PULSE_200);
            printer_.addPulse(Printer.DRAWER_5PIN, Printer.PULSE_200);
            printer_.sendData(Printer.PARAM_DEFAULT);
        } catch (Epos2Exception e) {
            e.printStackTrace();
        }
    }

    @ReactMethod
    public void getStatus(Promise promise)
    {
        PrinterStatusInfo status = null;

        try {
            Discovery.stop();
        }
        catch (Exception e) {
            //ShowMsg.showException(e, "stop", mContext);
        }


        try {
            if(connected_)
            {
                status = printer_.getStatus();
                if (status != null) {
                    promise.resolve((Object)makeErrorMessage(status));
                }
            }
        } catch(Exception e) {
            if (!connected_)
            {
                promise.reject("Not connected", e);
            }
            else if (status == null)
            {
                promise.reject("Failed to get status from printer", e);
            }
            else
            {
                promise.reject("Unknown getStatus error", e);
            }
        }
    }

    @ReactMethod
    public void disconnect()
    {
//        [Epos2Discovery stop];
//        connected_ = false;
//        [printer_ clearCommandBuffer];
//        [printer_ stopMonitor];
//        [printer_ disconnect];
        try {
            Discovery.stop();
        }
        catch (Exception e) {
            //ShowMsg.showException(e, "stop", mContext);
        }

        connected_ = false;

        printer_.clearCommandBuffer();

        try {
            printer_.stopMonitor();
        } catch (Epos2Exception e) {
            e.printStackTrace();
        }

        try {
            printer_.disconnect();
        } catch (Epos2Exception e) {
            e.printStackTrace();
        }
    }

    //Method for dispatching events to ReactNative
    void emitMessageToRN(ReactContext reactContext, String eventName, @Nullable WritableMap params)
    {
        // The bridge eventDispatcher is used to send events from native to JS env
        // No documentation yet on DeviceEventEmitter: https://github.com/facebook/react-native/issues/2819

        // Get EventEmitter from context and send event thanks to it
        reactContext
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(eventName, params);
    }

    int getPrinterTypeFromName(String printerName)
    {
        int type=-1;

        if(printerName.contains("TM-m10"))
        {
            type = Printer.TM_M10;
        }
        else if(printerName.contains("TM-m30"))
        {
            type = Printer.TM_M30;
        }
        else if(printerName.contains("TM-P20"))
        {
            type = Printer.TM_P20;
        }
        else if(printerName.contains("TM-P60II"))
        {
            type = Printer.TM_P60II;
        }
        else if(printerName.contains("TM-P60"))
        {
            type = Printer.TM_P60;
        }
        else if(printerName.contains("TM-P80"))
        {
            type = Printer.TM_P80;
        }
        else if(printerName.contains("TM-T20"))
        {
            type = Printer.TM_T20;
        }
        else if(printerName.contains("TM-T60"))
        {
            type = Printer.TM_T60;
        }
        else if(printerName.contains("TM-T70"))
        {
            type = Printer.TM_T70;
        }
        else if(printerName.contains("TM-T81"))
        {
            type = Printer.TM_T81;
        }
        else if(printerName.contains("TM-T82"))
        {
            type = Printer.TM_T82;
        }
        else if(printerName.contains("TM-T83"))
        {
            type = Printer.TM_T83;
        }
        else if(printerName.contains("TM-T88"))
        {
            type = Printer.TM_T88;
        }
        else if(printerName.contains("TM-T90KP"))
        {
            type = Printer.TM_T90KP;
        }
        else if(printerName.contains("TM-T90"))
        {
            type = Printer.TM_T90;
        }
        else if(printerName.contains("TM-U220"))
        {
            type = Printer.TM_U220;
        }
        else if(printerName.contains("TM-U330"))
        {
            type = Printer.TM_U330;
        }
        else if(printerName.contains("TM-L90"))
        {
            type = Printer.TM_L90;
        }
        else if(printerName.contains("TM-H6000"))
        {
            type = Printer.TM_H6000;
        }
        else
        {
            type = Printer.TM_T88;  //assume default
        }

        return type;
    }

    @Override
    public void onPtrReceive(final Printer printerObj, final int code, final PrinterStatusInfo status, final String printJobId) {
        // Create map for params
        WritableMap params = Arguments.createMap();

        // Put data to map
        params.putString("PrinterResponse", makeEposResponseMessage(code));

        emitMessageToRN(mReactApplicationContext,"PrinterResponseEvent", params);
    }

    @Override
    public void onPtrStatusChange(Printer printerObj, int eventType) {
        PrinterStatusInfo status = printer_.getStatus(); //get complete status
        if (status != null) {
            // Create map for params
            WritableMap params = Arguments.createMap();

            // Put data to map
            params.putString("printerStatus", makeErrorMessage(status));

            emitMessageToRN(mReactApplicationContext,"PrinterStatusEvent", params);
        }
    }

    String makeErrorMessage(PrinterStatusInfo status)
    {
        String errMsg = "";

        if (status.getOnline() == Printer.FALSE) {
            errMsg = errMsg + "Offline\n";
        }
        else {
            errMsg = errMsg + "Online\n";
        }
        if (status.getConnection() == Printer.FALSE) {
            errMsg = errMsg + "No response\n";
        }
        if (status.getCoverOpen() == Printer.TRUE) {
            errMsg = errMsg + "Cover open\n";
        }
        if (status.getPaper() == Printer.PAPER_NEAR_END) {
            errMsg = errMsg + "Paper near end\n";
        }
        if (status.getPaper() == Printer.PAPER_EMPTY) {
            errMsg = errMsg + "Paper out\n";
        }
        if (status.getPaperFeed() == Printer.TRUE || status.getPanelSwitch() == Printer.SWITCH_ON) {
            errMsg = errMsg + "Paper feed button pressed\n";
        }
        if (status.getErrorStatus() == Printer.MECHANICAL_ERR) {
            errMsg = errMsg + "Mechanical error\n";
        }
        if (status.getErrorStatus() == Printer.AUTOCUTTER_ERR) {
            errMsg = errMsg + "Autocutter error\n";
        }
        if (status.getErrorStatus() == Printer.UNRECOVER_ERR) {
            errMsg = errMsg + "Unrecoverable error\n";
        }
        if (status.getAutoRecoverError() == Printer.HEAD_OVERHEAT) {
            errMsg = errMsg + "Head overheat\n";
        }
        if (status.getAutoRecoverError() == Printer.MOTOR_OVERHEAT) {
            errMsg = errMsg + "Motor overheat\n";
        }
        if (status.getAutoRecoverError() == Printer.BATTERY_OVERHEAT) {
            errMsg = errMsg + "Battery overheat\n";
        }
        if (status.getAutoRecoverError() == Printer.WRONG_PAPER) {
            errMsg = errMsg + "Wrong_paper\n";
        }
        if (status.getBatteryLevel() == Printer.BATTERY_LEVEL_0) {
            errMsg = errMsg + "Battery empty\n";
        }
        if (status.getBatteryLevel() == Printer.BATTERY_LEVEL_1) {
            errMsg = errMsg + "Battery level 1 of 6\n";
        }
        if (status.getBatteryLevel() == Printer.BATTERY_LEVEL_2) {
            errMsg = errMsg + "Battery level 2 of 6\n";
        }
        if (status.getBatteryLevel() == Printer.BATTERY_LEVEL_3) {
            errMsg = errMsg + "Battery level 3 of 6\n";
        }
        if (status.getBatteryLevel() == Printer.BATTERY_LEVEL_4) {
            errMsg = errMsg + "Battery level 4 of 6\n";
        }
        if (status.getBatteryLevel() == Printer.BATTERY_LEVEL_5) {
            errMsg = errMsg + "Battery level 5 of 6\n";
        }
        if (status.getBatteryLevel() == Printer.BATTERY_LEVEL_6) {
            errMsg = errMsg + "Battery fully charged\n";
        }

        return errMsg;
    }

    String makeEposErrorMessage(Integer status)
    {
        String errMsg = "";

        if (status == CODE_SUCCESS) {
            errMsg = errMsg + "EPOS2_SUCCESS";
        }

        if (status == CODE_ERR_PARAM) {
            errMsg = errMsg + "EPOS2_ERR_PARAM";
        }

        if (status == CODE_ERR_CONNECT) {
            errMsg = errMsg + "EPOS2_ERR_CONNECT";
        }

        if (status == CODE_ERR_TIMEOUT) {
            errMsg = errMsg + "EPOS2_ERR_TIMEOUT";
        }

        if (status == CODE_ERR_MEMORY) {
            errMsg = errMsg + "EPOS2_ERR_MEMORY";
        }

        if (status == CODE_ERR_ILLEGAL) {
            errMsg = errMsg + "EPOS2_ERR_ILLEGAL";
        }

        if (status == CODE_ERR_PROCESSING) {
            errMsg = errMsg + "EPOS2_ERR_PROCESSING";
        }

        if (status == CODE_ERR_NOT_FOUND) {
            errMsg = errMsg + "EPOS2_ERR_NOT_FOUND";
        }

        if (status == CODE_ERR_IN_USE) {
            errMsg = errMsg + "EPOS2_ERR_IN_USE";
        }

        if (status == ERR_TYPE_INVALID) {
            errMsg = errMsg + "EPOS2_ERR_TYPE_INVALID";
        }

        if (status == CODE_ERR_DISCONNECT) {
            errMsg = errMsg + "EPOS2_ERR_DISCONNECT";
        }

        if (status == ERR_ALREADY_OPENED) {
            errMsg = errMsg + "EPOS2_ERR_ALREADY_OPENED";
        }

        if (status == ERR_ALREADY_USED) {
            errMsg = errMsg + "EPOS2_ERR_ALREADY_USED";
        }

        if (status == ERR_BOX_COUNT_OVER) {
            errMsg = errMsg + "EPOS2_ERR_BOX_COUNT_OVER";
        }

        if (status == ERR_UNSUPPORTED) {
            errMsg = errMsg + "EPOS2_ERR_UNSUPPORTED";
        }

        if (status == ERR_FAILURE) {
            errMsg = errMsg + "EPOS2_ERR_FAILURE";
        }

        return errMsg;
    }

    String makeEposResponseMessage(Integer code)
    {
        String errMsg = "";

        if (code == CODE_SUCCESS) {
            errMsg = errMsg + "EPOS2_ERR_FAILURE";
        }

        if (code == CODE_PRINTING) {
            errMsg = errMsg + "EPOS2_CODE_PRINTING";
        }

        if (code == CODE_ERR_AUTORECOVER) {
            errMsg = errMsg + "EPOS2_CODE_ERR_AUTORECOVER";
        }

        if (code == CODE_ERR_COVER_OPEN) {
            errMsg = errMsg + "EPOS2_CODE_ERR_COVER_OPEN";
        }

        if (code == CODE_ERR_COVER_OPEN) {
            errMsg = errMsg + "EPOS2_CODE_ERR_COVER_OPEN";
        }

        if (code == CODE_ERR_MECHANICAL) {
            errMsg = errMsg + "EPOS2_CODE_ERR_COVER_OPEN";
        }

        if (code == CODE_ERR_EMPTY) {
            errMsg = errMsg + "EPOS2_CODE_ERR_EMPTY";
        }

        if (code == CODE_ERR_UNRECOVERABLE) {
            errMsg = errMsg + "EPOS2_CODE_ERR_UNRECOVERABLE";
        }

        if (code == CODE_ERR_FAILURE) {
            errMsg = errMsg + "EPOS2_CODE_ERR_FAILURE";
        }

        if (code == CODE_ERR_NOT_FOUND) {
            errMsg = errMsg + "EPOS2_CODE_ERR_NOT_FOUND";
        }

        if (code == CODE_ERR_SYSTEM) {
            errMsg = errMsg + "EPOS2_CODE_ERR_SYSTEM";
        }

        if (code == CODE_ERR_PORT) {
            errMsg = errMsg + "EPOS2_CODE_ERR_PORT";
        }

        if (code == CODE_ERR_TIMEOUT) {
            errMsg = errMsg + "EPOS2_CODE_ERR_TIMEOUT";
        }

        if (code == CODE_ERR_JOB_NOT_FOUND) {
            errMsg = errMsg + "EPOS2_CODE_ERR_JOB_NOT_FOUND";
        }

        if (code == CODE_ERR_SPOOLER) {
            errMsg = errMsg + "EPOS2_CODE_ERR_SPOOLER";
        }

        if (code == CODE_ERR_BATTERY_LOW) {
            errMsg = errMsg + "EPOS2_CODE_ERR_BATTERY_LOW";
        }

        if (code == CODE_ERR_TOO_MANY_REQUESTS) {
            errMsg = errMsg + "EPOS2_CODE_ERR_TOO_MANY_REQUESTS";
        }
        if (code == CODE_ERR_REQUEST_ENTITY_TOO_LARGE) {
            errMsg = errMsg + "EPOS2_CODE_ERR_REQUEST_ENTITY_TOO_LARGE";
        }

        return errMsg;
    }

    Integer getPrinterWidthInDots(Integer printerType)
    {
        int dots=0;

        switch (printerType) {
            case Printer.TM_M10:
                dots = 420;
                break;
            case Printer.TM_M30:
                dots = 576;
                break;
            case Printer.TM_P20:
                dots = 384;
                break;
            case Printer.TM_P60:
                dots = 432;
                break;
            case Printer.TM_P60II:
                dots = 432;
                break;
            case Printer.TM_P80:
                dots = 576;
                break;
            case Printer.TM_T20:
                dots = 576;
                break;
            case Printer.TM_T60:
                dots = 384;
                break;
            case Printer.TM_T70:
                dots = 512;
                break;
            case Printer.TM_T81:
                dots = 512;
                break;
            case Printer.TM_T82:
                dots = 576;
                break;
            case Printer.TM_T83:
                dots = 576;
                break;
            case Printer.TM_T88:
                dots = 512;
                break;
            case Printer.TM_T90:
                dots = 512;
                break;
            case Printer.TM_T90KP:
                dots = 512;
                break;
            case Printer.TM_U220:
                dots = 200;
                break;
            case Printer.TM_U330:
                dots = 300;
                break;
            case Printer.TM_L90:
                dots = 576;
                break;
            case Printer.TM_H6000:
                dots = 512;
                break;
            default:
                dots = 512; //most common (for T88/H6000)
                break;
        }

        return dots;
    }

}
