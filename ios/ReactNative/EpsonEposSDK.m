//  Created by react-native-create-bridge

#import "EpsonEposSDK.h"

// import RCTBridge
#if __has_include(<React/RCTBridge.h>)
#import <React/RCTBridge.h>
#elif __has_include(“RCTBridge.h”)
#import “RCTBridge.h”
#else
#import “React/RCTBridge.h” // Required when used as a Pod in a Swift project
#endif

// import RCTEventDispatcher
#if __has_include(<React/RCTEventDispatcher.h>)
#import <React/RCTEventDispatcher.h>
#elif __has_include(“RCTEventDispatcher.h”)
#import “RCTEventDispatcher.h”
#else
#import “React/RCTEventDispatcher.h” // Required when used as a Pod in a Swift project
#endif

//EPSON stuff
#import "ShowMsg.h"
#define KEY_RESULT                  @"Result"
#define KEY_METHOD                  @"Method"
@interface EpsonEposSDK() <Epos2PtrReceiveDelegate,Epos2PtrStatusChangeDelegate,Epos2DiscoveryDelegate>
@end

@implementation EpsonEposSDK
@synthesize bridge = _bridge;

//constructor
-(instancetype)init
{
  self = [super init];
  
  printer_ = nil;
  printerSeries_ = EPOS2_TM_T88;
  lang_ = EPOS2_MODEL_ANK;
  connected_ = false;
  
  return self;
}

// Export a native module
// https://facebook.github.io/react-native/docs/native-modules-ios.html
RCT_EXPORT_MODULE(EpsonEposSDK);

+ (BOOL)requiresMainQueueSetup
{
    return NO;
}

// Export constants
// https://facebook.github.io/react-native/releases/next/docs/native-modules-ios.html#exporting-constants
- (NSDictionary *)constantsToExport
{
  return @{
           @"EPOS2_FONT_A": [NSNumber numberWithUnsignedInteger:EPOS2_FONT_A],
           @"EPOS2_FONT_B": [NSNumber numberWithUnsignedInteger:EPOS2_FONT_B],
           @"EPOS2_ALIGN_LEFT": [NSNumber numberWithUnsignedInteger:EPOS2_ALIGN_LEFT],
           @"EPOS2_ALIGN_CENTER": [NSNumber numberWithUnsignedInteger:EPOS2_ALIGN_CENTER],
           @"EPOS2_ALIGN_RIGHT": [NSNumber numberWithUnsignedInteger:EPOS2_ALIGN_RIGHT],
           @"EPOS2_TM_M10": [NSNumber numberWithUnsignedInteger:EPOS2_TM_M10],
           @"EPOS2_TM_M30": [NSNumber numberWithUnsignedInteger:EPOS2_TM_M30],
           @"EPOS2_TM_P20": [NSNumber numberWithUnsignedInteger:EPOS2_TM_P20],
           @"EPOS2_TM_P60": [NSNumber numberWithUnsignedInteger:EPOS2_TM_P60],
           @"EPOS2_TM_P60II": [NSNumber numberWithUnsignedInteger:EPOS2_TM_P60II],
           @"EPOS2_TM_P80": [NSNumber numberWithUnsignedInteger:EPOS2_TM_P80],
           @"EPOS2_TM_T20": [NSNumber numberWithUnsignedInteger:EPOS2_TM_T20],
           @"EPOS2_TM_T60": [NSNumber numberWithUnsignedInteger:EPOS2_TM_T60],
           @"EPOS2_TM_T70": [NSNumber numberWithUnsignedInteger:EPOS2_TM_T70],
           @"EPOS2_TM_T81": [NSNumber numberWithUnsignedInteger:EPOS2_TM_T81],
           @"EPOS2_TM_T82": [NSNumber numberWithUnsignedInteger:EPOS2_TM_T82],
           @"EPOS2_TM_T83": [NSNumber numberWithUnsignedInteger:EPOS2_TM_T83],
           @"EPOS2_TM_T88": [NSNumber numberWithUnsignedInteger:EPOS2_TM_T88],
           @"EPOS2_TM_T90": [NSNumber numberWithUnsignedInteger:EPOS2_TM_T90],
           @"EPOS2_TM_T90KP": [NSNumber numberWithUnsignedInteger:EPOS2_TM_T90KP],
           @"EPOS2_TM_U220": [NSNumber numberWithUnsignedInteger:EPOS2_TM_U220],
           @"EPOS2_TM_U330": [NSNumber numberWithUnsignedInteger:EPOS2_TM_U330],
           @"EPOS2_TM_L90": [NSNumber numberWithUnsignedInteger:EPOS2_TM_L90],
           @"EPOS2_TM_H6000": [NSNumber numberWithUnsignedInteger:EPOS2_TM_H6000],
           @"EPOS2_MODEL_ANK": [NSNumber numberWithUnsignedInteger:EPOS2_MODEL_ANK],
           @"EPOS2_MODEL_JAPANESE": [NSNumber numberWithUnsignedInteger:EPOS2_MODEL_JAPANESE],
           @"EPOS2_MODEL_CHINESE": [NSNumber numberWithUnsignedInteger:EPOS2_MODEL_CHINESE],
           @"EPOS2_MODEL_TAIWAN": [NSNumber numberWithUnsignedInteger:EPOS2_MODEL_TAIWAN],
           @"EPOS2_MODEL_KOREAN": [NSNumber numberWithUnsignedInteger:EPOS2_MODEL_KOREAN],
           @"EPOS2_MODEL_THAI": [NSNumber numberWithUnsignedInteger:EPOS2_MODEL_THAI],
           @"EPOS2_MODEL_SOUTHASIA": [NSNumber numberWithUnsignedInteger:EPOS2_MODEL_SOUTHASIA],
           @"EPOS2_MODE_MONO": [NSNumber numberWithUnsignedInteger:EPOS2_MODE_MONO],
           @"EPOS2_MODE_GRAY16": [NSNumber numberWithUnsignedInteger:EPOS2_MODE_GRAY16],
           @"EPOS2_HALFTONE_DITHER": [NSNumber numberWithUnsignedInteger:EPOS2_HALFTONE_DITHER],
           @"EPOS2_HALFTONE_ERROR_DIFFUSION": [NSNumber numberWithUnsignedInteger:EPOS2_HALFTONE_ERROR_DIFFUSION],
           @"EPOS2_HALFTONE_THRESHOLD": [NSNumber numberWithUnsignedInteger:EPOS2_HALFTONE_THRESHOLD]
           };
}

// Implement methods that you want to export to the native module
// https://facebook.github.io/react-native/docs/native-modules-ios.html
//RCT_EXPORT_METHOD(exampleMethod)
//{
//  [self emitMessageToRN:@"EXAMPLE_EVENT" :@{@"greeting": @"hi friends!!"}];
//}

//===== ePOS Functions Export =====
RCT_EXPORT_METHOD(discoverPrinters)
{
  [Epos2Discovery stop];
  
  Epos2FilterOption *filteroption  = [[Epos2FilterOption alloc] init];
  [filteroption setDeviceType:EPOS2_TYPE_PRINTER];
  
  [Epos2Discovery start:filteroption delegate:self];
}

RCT_EXPORT_METHOD(connect:(NSString*)target printerSeries:(int)printerSeries language:(int)language timeout:(int)timeout
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  [Epos2Discovery stop];
  if(connected_)
  {
    return;
  }
  
  printerSeries_ = printerSeries;
  
  //Initialize printer object
  printer_ = [[Epos2Printer alloc] initWithPrinterSeries:printerSeries lang:language];
  if (printer_ == nil) {
    reject(@"Error", @"Failed to initialize printer object",nil);
    //[ShowMsg showErrorEpos:EPOS2_ERR_PARAM method:@"initiWithPrinterSeries"];
    return;
  }
  
  //Connect to printer
  int result = [printer_ connect:target timeout:timeout];
  if (result != EPOS2_SUCCESS) {
    reject(@"Error", [NSString stringWithFormat:@"Failed to connect to the printer: %@", [self makeEposErrorMessage:result]],nil);
    //[ShowMsg showErrorEpos:result method:@"connect"];
    return;
  }
  
  //set Callbacks
  [printer_ setReceiveEventDelegate:self];
  [printer_ setInterval:1000];
  [printer_ setStatusChangeEventDelegate:self];
  
  //start monitor status
  [printer_ startMonitor];
  
  connected_ = true;
  resolve([NSNumber numberWithInteger:result]);
}

RCT_EXPORT_METHOD(printText:(NSString*)text font:(int)font alignment:(int)alignment width:(int)width height:(int)height)
{
  [Epos2Discovery stop];
  if(!connected_)
  {
    //reject(@"Error", @"Not connected",nil);
    return;
  }
  
  [printer_ clearCommandBuffer];
  [printer_ addTextFont:font];
  [printer_ addTextAlign:alignment];
  [printer_ addTextSize:width height:height];
  [printer_ addText:text];
  int result = [printer_ sendData:EPOS2_PARAM_DEFAULT];
  if (result != EPOS2_SUCCESS) {
    //[ShowMsg showErrorEpos:result method:@"printText"];
  }
}

RCT_EXPORT_METHOD(printSimpleText:(NSString*)text)
{
  [Epos2Discovery stop];
  if(!connected_)
  {
    //reject(@"Error", @"Not connected",nil);
    return;
  }
  
  [printer_ clearCommandBuffer];
  [printer_ addTextFont:EPOS2_FONT_A];
  [printer_ addTextAlign:EPOS2_ALIGN_LEFT];
  [printer_ addTextSize:1 height:1];
  [printer_ addText:text];
  [printer_ addText:@"\n"];
  [printer_ addCut:EPOS2_CUT_FEED];
  int result = [printer_ sendData:EPOS2_PARAM_DEFAULT];
  if (result != EPOS2_SUCCESS) {
    //[ShowMsg showErrorEpos:result method:@"printSimpleText"];
  }
}

//RCT_EXPORT_METHOD(printImage:(NSString*)fileName x:(int)x y:(int)y width:(int)width height:(int)height)
RCT_EXPORT_METHOD(printImage:(NSString*)fileUrl mode:(int)mode halftone:(int)halftone
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  [Epos2Discovery stop];
  if(!connected_)
  {
    reject(@"Error", @"Not connected",nil);
    return;
  }
  
  //load image from URL
  UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:fileUrl]]];
  if (img == nil) {
    reject(@"Error", @"Failed to load image",nil);
    return;
  }
  
  //scale image to paper width
  int printerWidth = [self getPrinterWidthInDots:printerSeries_];
  float f = printerWidth/img.size.width;
  CGSize size = CGSizeMake(printerWidth, (img.size.height*f));
  UIImage *imgResized = [EpsonEposSDK imageWithImage:img scaledToSize:size];
  img = imgResized;
  
  [printer_ clearCommandBuffer];
  int result = [printer_ addImage:img x:0 y:0 width:img.size.width height:img.size.height color:EPOS2_COLOR_1 mode:mode halftone:halftone brightness:EPOS2_PARAM_DEFAULT compress:EPOS2_COMPRESS_AUTO];
  if (result != EPOS2_SUCCESS) {
    reject(@"Error", [self makeEposErrorMessage:result],nil);
    return;
  }
  
  result = [printer_ sendData:EPOS2_PARAM_DEFAULT];
  if (result != EPOS2_SUCCESS) {
    reject(@"Error", [self makeEposErrorMessage:result],nil);
    return;
  }
  
  resolve([NSNumber numberWithInteger:result]);
}

RCT_EXPORT_METHOD(printBase64Image:(NSString*)base64image mode:(int)mode halftone:(int)halftone
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  [Epos2Discovery stop];
  if(!connected_)
  {
    reject(@"Error", @"Not connected",nil);
    return;
  }
  
  //load image from URL
//  UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:fileUrl]]];
//  if (img == nil) {
//    reject(@"Error", @"Failed to load image",nil);
//    return;
//  }
  
  NSData* decodedData = [[NSData alloc] initWithBase64EncodedString:base64image options:0];
  //NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
  UIImage *img = [UIImage imageWithData:decodedData];
  
  //scale image to paper width
  int printerWidth = [self getPrinterWidthInDots:printerSeries_];
  float f = printerWidth/img.size.width;
  CGSize size = CGSizeMake(printerWidth, (img.size.height*f));
  UIImage *imgResized = [EpsonEposSDK imageWithImage:img scaledToSize:size];
  img = imgResized;
  
  [printer_ clearCommandBuffer];
  int result = [printer_ addImage:img x:0 y:0 width:img.size.width height:img.size.height color:EPOS2_COLOR_1 mode:mode halftone:halftone brightness:EPOS2_PARAM_DEFAULT compress:EPOS2_COMPRESS_AUTO];
  if (result != EPOS2_SUCCESS) {
    reject(@"Error", [self makeEposErrorMessage:result],nil);
    return;
  }
  
  result = [printer_ sendData:EPOS2_PARAM_DEFAULT];
  if (result != EPOS2_SUCCESS) {
    reject(@"Error", [self makeEposErrorMessage:result],nil);
    return;
  }
  
  resolve([NSNumber numberWithInteger:result]);
}
RCT_EXPORT_METHOD(cutPaper)
{
  [Epos2Discovery stop];
  if(!connected_)
  {
    //reject(@"Error", @"Not connected",nil);
    return;
  }
  
  [printer_ clearCommandBuffer];
  [printer_ addCut:EPOS2_CUT_FEED];
  int result = [printer_ sendData:EPOS2_PARAM_DEFAULT];
  if (result != EPOS2_SUCCESS) {
    //[ShowMsg showErrorEpos:result method:@"cutPaper"];
  }
}

RCT_EXPORT_METHOD(openCashDrawer)
{
  [Epos2Discovery stop];
  if(!connected_)
  {
    //reject(@"Error", @"Not connected",nil);
    return;
  }
  
  [printer_ clearCommandBuffer];
  [printer_ addPulse:EPOS2_DRAWER_2PIN time:EPOS2_PULSE_200];
  [printer_ addPulse:EPOS2_DRAWER_5PIN time:EPOS2_PULSE_200];
  int result = [printer_ sendData:EPOS2_PARAM_DEFAULT];
  if (result != EPOS2_SUCCESS) {
    //[ShowMsg showErrorEpos:result method:@"openCashDrawer"];
  }
}

RCT_EXPORT_METHOD(getStatus:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  [Epos2Discovery stop];
  if(!connected_)
  {
    reject(@"Error", @"Not connected",nil);
    return;
  }
  
  Epos2PrinterStatusInfo *status = [printer_ getStatus];
  if (status == nil) {
    reject(@"Error", @"Failed to get status from printer",nil);
  }
  else
  {
    resolve([self makeErrorMessage:status]);
  }
}

RCT_EXPORT_METHOD(disconnect)
{
  [Epos2Discovery stop];
  connected_ = false;
  [printer_ clearCommandBuffer];
  [printer_ stopMonitor];
  [printer_ disconnect];
}


// ----- List all your events here -----
// https://facebook.github.io/react-native/releases/next/docs/native-modules-ios.html#sending-events-to-javascript
- (NSArray<NSString *> *)supportedEvents
{
  return @[
           @"PrinterStatusEvent", //event if the status changes
           @"PrinterResponseEvent", //event when command response comes in
           @"PrinterDiscoveryEvent" //event when a printer was discovered
           ];
}

#pragma mark - Private methods

//Method for dispatching events to ReactNative
- (void) emitMessageToRN:(NSString *)eventName parameters:(NSDictionary *)params {
  // The bridge eventDispatcher is used to send events from native to JS env
  // No documentation yet on DeviceEventEmitter: https://github.com/facebook/react-native/issues/2819
  [self sendEventWithName: eventName body: params];
}

//status callback from printer
- (void) onPtrStatusChange:(Epos2Printer *)EPOS2_Obj eventType:(int) eventType
{
  Epos2PrinterStatusInfo *status = [printer_ getStatus]; //get complete status
  if (status != nil) {
    [self emitMessageToRN:@"PrinterStatusEvent" parameters:@{@"printerStatus": [self makeErrorMessage:status]}];
  }
}

//receive callback from printer
- (void) onPtrReceive:(Epos2Printer *)printerObj code:(int)code status:(Epos2PrinterStatusInfo *)status printJobId:(NSString *)printJobId
{
  [self emitMessageToRN:@"PrinterResponseEvent" parameters:@{@"PrinterResponse": [self makeEposResponseMessage:code]}];
}

- (void) onDiscovery:(Epos2DeviceInfo *)deviceInfo
{
  if([deviceInfo.getDeviceName containsString:@"TM"]==true && [deviceInfo.getTarget containsString:@"["]==false) //don't show KDS boxes or ePOS device printers
  {
    NSNumber* type = [self getPrinterTypeFromName:deviceInfo.getDeviceName];
    [self emitMessageToRN:@"PrinterDiscoveryEvent" parameters:@{@"PrinterName": deviceInfo.getDeviceName, @"PrinterIP": deviceInfo.getIpAddress, @"PrinterType": type, @"PrinterTarget": deviceInfo.getTarget }];
  }
}

//resize image
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
  //UIGraphicsBeginImageContext(newSize);
  // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
  // Pass 1.0 to force exact pixel size.
  UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
  [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return newImage;
}

//----------------------------------------------------------------------------------------------
//     Printer Functions from the Sample Code
//----------------------------------------------------------------------------------------------
//- (void) onPtrReceive:(Epos2Printer *)printerObj code:(int)code status:(Epos2PrinterStatusInfo *)status printJobId:(NSString *)printJobId
//{
//  [self emitMessageToRN:@"PRINT_EVENT" :@{@"printText": @"callback received"}];
//
//  [ShowMsg showResult:code errMsg:[self makeErrorMessage:status]];
//
//  [self dispPrinterWarnings:status];
//
//  [self performSelectorInBackground:@selector(disconnectPrinter) withObject:nil];
//}

- (BOOL)initializeObject
{
  printer_ = [[Epos2Printer alloc] initWithPrinterSeries:printerSeries_ lang:lang_];
  
  if (printer_ == nil) {
    [ShowMsg showErrorEpos:EPOS2_ERR_PARAM method:@"initiWithPrinterSeries"];
    return NO;
  }
  
  [printer_ setReceiveEventDelegate:self];
  
  return YES;
}

- (void)finalizeObject
{
  if (printer_ == nil) {
    return;
  }
  
  [printer_ clearCommandBuffer];
  
  [printer_ setReceiveEventDelegate:nil];
  
  printer_ = nil;
}

-(BOOL)connectPrinter
{
  int result = EPOS2_SUCCESS;
  
  if (printer_ == nil) {
    return NO;
  }
  
  result = [printer_ connect:@"TCP:185.185.185.58" timeout:EPOS2_PARAM_DEFAULT];
  if (result != EPOS2_SUCCESS) {
    [ShowMsg showErrorEpos:result method:@"connect"];
    return NO;
  }
  
  result = [printer_ beginTransaction];
  if (result != EPOS2_SUCCESS) {
    [ShowMsg showErrorEpos:result method:@"beginTransaction"];
    [printer_ disconnect];
    return NO;
  }
  
  return YES;
}

- (BOOL)printData
{
  int result = EPOS2_SUCCESS;
  
  Epos2PrinterStatusInfo *status = nil;
  
  if (printer_ == nil) {
    return NO;
  }
  
  if (![self connectPrinter]) {
    return NO;
  }
  
  status = [printer_ getStatus];
  [self dispPrinterWarnings:status];
  
  if (![self isPrintable:status]) {
    [ShowMsg show:[self makeErrorMessage:status]];
    [printer_ disconnect];
    return NO;
  }
  
  result = [printer_ sendData:EPOS2_PARAM_DEFAULT];
  if (result != EPOS2_SUCCESS) {
    [ShowMsg showErrorEpos:result method:@"sendData"];
    [printer_ disconnect];
    return NO;
  }
  
  return YES;
}

- (void)disconnectPrinter
{
  int result = EPOS2_SUCCESS;
  NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
  
  if (printer_ == nil) {
    return;
  }
  
  result = [printer_ endTransaction];
  if (result != EPOS2_SUCCESS) {
    [dict setObject:[NSNumber numberWithInt:result] forKey:KEY_RESULT];
    [dict setObject:@"endTransaction" forKey:KEY_METHOD];
    [self performSelectorOnMainThread:@selector(showEposErrorFromThread:) withObject:dict waitUntilDone:NO];
  }
  
  result = [printer_ disconnect];
  if (result != EPOS2_SUCCESS) {
    [dict setObject:[NSNumber numberWithInt:result] forKey:KEY_RESULT];
    [dict setObject:@"disconnect" forKey:KEY_METHOD];
    [self performSelectorOnMainThread:@selector(showEposErrorFromThread:) withObject:dict waitUntilDone:NO];
  }
  [self finalizeObject];
}

- (BOOL)isPrintable:(Epos2PrinterStatusInfo *)status
{
  if (status == nil) {
    return NO;
  }
  
  if (status.connection == EPOS2_FALSE) {
    return NO;
  }
  else if (status.online == EPOS2_FALSE) {
    return NO;
  }
  else {
    ;//print available
  }
  
  return YES;
}

- (void)showEposErrorFromThread:(NSDictionary *)dict
{
  int result = EPOS2_SUCCESS;
  NSString *method = @"";
  result = [[dict valueForKey:KEY_RESULT] intValue];
  method = [dict valueForKey:KEY_METHOD];
  [ShowMsg showErrorEpos:result method:method];
}


- (void)dispPrinterWarnings:(Epos2PrinterStatusInfo *)status
{
  NSMutableString *warningMsg = [[NSMutableString alloc] init];
  
  if (status == nil) {
    return;
  }
  
  //_textWarnings.text = @"";
  
  if (status.paper == EPOS2_PAPER_NEAR_END) {
    [warningMsg appendString:NSLocalizedString(@"warn_receipt_near_end", @"")];
  }
  
  if (status.batteryLevel == EPOS2_BATTERY_LEVEL_1) {
    [warningMsg appendString:NSLocalizedString(@"warn_battery_near_end", @"")];
  }
  
  //_textWarnings.text = warningMsg;
}

//----------------------------------------------------------------------------------------------
//     Functions to make string from status, error, etc.
//----------------------------------------------------------------------------------------------
- (NSString *)makeErrorMessage:(Epos2PrinterStatusInfo *)status
{
  NSMutableString *errMsg = [[NSMutableString alloc] initWithString:@""];
  
  if (status.getOnline == EPOS2_FALSE) {
    [errMsg appendString:NSLocalizedString(@"Offline\n", @"")];
  }
  else {
    [errMsg appendString:NSLocalizedString(@"Online\n", @"")];
  }
  if (status.getConnection == EPOS2_FALSE) {
    [errMsg appendString:NSLocalizedString(@"No response\n", @"")];
  }
  if (status.getCoverOpen == EPOS2_TRUE) {
    [errMsg appendString:NSLocalizedString(@"Cover open\n", @"")];
  }
  if (status.getPaper == EPOS2_PAPER_NEAR_END) {
    [errMsg appendString:NSLocalizedString(@"Paper near end\n", @"")];
  }
  if (status.getPaper == EPOS2_PAPER_EMPTY) {
    [errMsg appendString:NSLocalizedString(@"Paper out\n", @"")];
  }
  if (status.getPaperFeed == EPOS2_TRUE || status.getPanelSwitch == EPOS2_SWITCH_ON) {
    [errMsg appendString:NSLocalizedString(@"Paper feed button pressed\n", @"")];
  }
  if (status.getErrorStatus == EPOS2_MECHANICAL_ERR) {
    [errMsg appendString:NSLocalizedString(@"Mechanical error\n", @"")];
  }
  if (status.getErrorStatus == EPOS2_AUTOCUTTER_ERR) {
    [errMsg appendString:NSLocalizedString(@"Autocutter error\n", @"")];
  }
  if (status.getErrorStatus == EPOS2_UNRECOVER_ERR) {
    [errMsg appendString:NSLocalizedString(@"Unrecoverable error\n", @"")];
  }
  if (status.getAutoRecoverError == EPOS2_HEAD_OVERHEAT) {
    [errMsg appendString:NSLocalizedString(@"Head overheat\n", @"")];
  }
  if (status.getAutoRecoverError == EPOS2_MOTOR_OVERHEAT) {
    [errMsg appendString:NSLocalizedString(@"Motor overheat\n", @"")];
  }
  if (status.getAutoRecoverError == EPOS2_BATTERY_OVERHEAT) {
    [errMsg appendString:NSLocalizedString(@"Battery overheat\n", @"")];
  }
  if (status.getAutoRecoverError == EPOS2_WRONG_PAPER) {
    [errMsg appendString:NSLocalizedString(@"Wrong_paper\n", @"")];
  }
  if (status.getBatteryLevel == EPOS2_BATTERY_LEVEL_0) {
    [errMsg appendString:NSLocalizedString(@"Battery empty\n", @"")];
  }
  if (status.getBatteryLevel == EPOS2_BATTERY_LEVEL_1) {
    [errMsg appendString:NSLocalizedString(@"Battery level 1 of 6\n", @"")];
  }
  if (status.getBatteryLevel == EPOS2_BATTERY_LEVEL_2) {
    [errMsg appendString:NSLocalizedString(@"Battery level 2 of 6\n", @"")];
  }
  if (status.getBatteryLevel == EPOS2_BATTERY_LEVEL_3) {
    [errMsg appendString:NSLocalizedString(@"Battery level 3 of 6\n", @"")];
  }
  if (status.getBatteryLevel == EPOS2_BATTERY_LEVEL_4) {
    [errMsg appendString:NSLocalizedString(@"Battery level 4 of 6\n", @"")];
  }
  if (status.getBatteryLevel == EPOS2_BATTERY_LEVEL_5) {
    [errMsg appendString:NSLocalizedString(@"Battery level 5 of 6\n", @"")];
  }
  if (status.getBatteryLevel == EPOS2_BATTERY_LEVEL_6) {
    [errMsg appendString:NSLocalizedString(@"Battery fully charged\n", @"")];
  }
  
  return errMsg;
}

- (NSString *)makeEposErrorMessage:(int)status
{
  NSMutableString *errMsg = [[NSMutableString alloc] initWithString:@""];
  
  if (status == EPOS2_SUCCESS) {
    [errMsg appendString:NSLocalizedString(@"EPOS2_SUCCESS", @"")];
  }
  
  if (status == EPOS2_ERR_PARAM) {
    [errMsg appendString:NSLocalizedString(@"EPOS2_ERR_PARAM", @"")];
  }
  
  if (status == EPOS2_ERR_CONNECT) {
    [errMsg appendString:NSLocalizedString(@"EPOS2_ERR_CONNECT", @"")];
  }
  
  if (status == EPOS2_ERR_TIMEOUT) {
    [errMsg appendString:NSLocalizedString(@"EPOS2_ERR_TIMEOUT", @"")];
  }
  
  if (status == EPOS2_ERR_MEMORY) {
    [errMsg appendString:NSLocalizedString(@"EPOS2_ERR_MEMORY", @"")];
  }
  
  if (status == EPOS2_ERR_ILLEGAL) {
    [errMsg appendString:NSLocalizedString(@"EPOS2_ERR_ILLEGAL", @"")];
  }
  
  if (status == EPOS2_ERR_PROCESSING) {
    [errMsg appendString:NSLocalizedString(@"EPOS2_ERR_PROCESSING", @"")];
  }
  
  if (status == EPOS2_ERR_NOT_FOUND) {
    [errMsg appendString:NSLocalizedString(@"EPOS2_ERR_NOT_FOUND", @"")];
  }
  
  if (status == EPOS2_ERR_IN_USE) {
    [errMsg appendString:NSLocalizedString(@"EPOS2_ERR_IN_USE", @"")];
  }
  
  if (status == EPOS2_ERR_TYPE_INVALID) {
    [errMsg appendString:NSLocalizedString(@"EPOS2_ERR_TYPE_INVALID", @"")];
  }
  
  if (status == EPOS2_ERR_DISCONNECT) {
    [errMsg appendString:NSLocalizedString(@"EPOS2_ERR_DISCONNECT", @"")];
  }
  
  if (status == EPOS2_ERR_ALREADY_OPENED) {
    [errMsg appendString:NSLocalizedString(@"EPOS2_ERR_ALREADY_OPENED", @"")];
  }
  
  if (status == EPOS2_ERR_ALREADY_USED) {
    [errMsg appendString:NSLocalizedString(@"EPOS2_ERR_ALREADY_USED", @"")];
  }
  
  if (status == EPOS2_ERR_BOX_COUNT_OVER) {
    [errMsg appendString:NSLocalizedString(@"EPOS2_ERR_BOX_COUNT_OVER", @"")];
  }
  
  if (status == EPOS2_ERR_UNSUPPORTED) {
    [errMsg appendString:NSLocalizedString(@"EPOS2_ERR_UNSUPPORTED", @"")];
  }
  
  if (status == EPOS2_ERR_FAILURE) {
    [errMsg appendString:NSLocalizedString(@"EPOS2_ERR_FAILURE", @"")];
  }
  
  return errMsg;
}

- (NSString *)makeEposResponseMessage:(int)code
{
  NSMutableString *errMsg = [[NSMutableString alloc] initWithString:@""];
  
  if (code == EPOS2_CODE_SUCCESS) {
    [errMsg appendString:NSLocalizedString(@"EPOS2_CODE_SUCCESS", @"")];
  }
  
  if (code == EPOS2_CODE_PRINTING) {
    [errMsg appendString:NSLocalizedString(@"EPOS2_CODE_PRINTING", @"")];
  }
  
  if (code == EPOS2_CODE_ERR_AUTORECOVER) {
    [errMsg appendString:NSLocalizedString(@"EPOS2_CODE_ERR_AUTORECOVER", @"")];
  }
  
  if (code == EPOS2_CODE_ERR_COVER_OPEN) {
    [errMsg appendString:NSLocalizedString(@"EPOS2_CODE_ERR_COVER_OPEN", @"")];
  }
  
  if (code == EPOS2_CODE_ERR_COVER_OPEN) {
    [errMsg appendString:NSLocalizedString(@"EPOS2_CODE_ERR_COVER_OPEN", @"")];
  }
  
  if (code == EPOS2_CODE_ERR_MECHANICAL) {
    [errMsg appendString:NSLocalizedString(@"EPOS2_CODE_ERR_MECHANICAL", @"")];
  }
  
  if (code == EPOS2_CODE_ERR_EMPTY) {
    [errMsg appendString:NSLocalizedString(@"EPOS2_CODE_ERR_EMPTY", @"")];
  }
  
  if (code == EPOS2_CODE_ERR_UNRECOVERABLE) {
    [errMsg appendString:NSLocalizedString(@"EPOS2_CODE_ERR_UNRECOVERABLE", @"")];
  }
  
  if (code == EPOS2_CODE_ERR_FAILURE) {
    [errMsg appendString:NSLocalizedString(@"EPOS2_CODE_ERR_FAILURE", @"")];
  }
  
  if (code == EPOS2_CODE_ERR_NOT_FOUND) {
    [errMsg appendString:NSLocalizedString(@"EPOS2_CODE_ERR_NOT_FOUND", @"")];
  }
  
  if (code == EPOS2_CODE_ERR_SYSTEM) {
    [errMsg appendString:NSLocalizedString(@"EPOS2_CODE_ERR_SYSTEM", @"")];
  }
  
  if (code == EPOS2_CODE_ERR_PORT) {
    [errMsg appendString:NSLocalizedString(@"EPOS2_CODE_ERR_PORT", @"")];
  }
  
  if (code == EPOS2_CODE_ERR_TIMEOUT) {
    [errMsg appendString:NSLocalizedString(@"EPOS2_CODE_ERR_TIMEOUT", @"")];
  }
  
  if (code == EPOS2_CODE_ERR_JOB_NOT_FOUND) {
    [errMsg appendString:NSLocalizedString(@"EPOS2_CODE_ERR_JOB_NOT_FOUND", @"")];
  }
  
  if (code == EPOS2_CODE_ERR_SPOOLER) {
    [errMsg appendString:NSLocalizedString(@"EPOS2_CODE_ERR_SPOOLER", @"")];
  }
  
  if (code == EPOS2_CODE_ERR_BATTERY_LOW) {
    [errMsg appendString:NSLocalizedString(@"EPOS2_CODE_ERR_BATTERY_LOW", @"")];
  }
  
  if (code == EPOS2_CODE_ERR_TOO_MANY_REQUESTS) {
    [errMsg appendString:NSLocalizedString(@"EPOS2_CODE_ERR_TOO_MANY_REQUESTS", @"")];
  }
  if (code == EPOS2_CODE_ERR_REQUEST_ENTITY_TOO_LARGE) {
    [errMsg appendString:NSLocalizedString(@"EPOS2_CODE_ERR_REQUEST_ENTITY_TOO_LARGE", @"")];
  }
  
  return errMsg;
}

- (int)getPrinterWidthInDots:(int)printerType
{
  int dots=0;
  
  switch (printerType) {
    case EPOS2_TM_M10:
      dots = 420;
      break;
    case EPOS2_TM_M30:
      dots = 576;
      break;
    case EPOS2_TM_P20:
      dots = 384;
      break;
    case EPOS2_TM_P60:
      dots = 432;
      break;
    case EPOS2_TM_P60II:
      dots = 432;
      break;
    case EPOS2_TM_P80:
      dots = 576;
      break;
    case EPOS2_TM_T20:
      dots = 576;
      break;
    case EPOS2_TM_T60:
      dots = 384;
      break;
    case EPOS2_TM_T70:
      dots = 512;
      break;
    case EPOS2_TM_T81:
      dots = 512;
      break;
    case EPOS2_TM_T82:
      dots = 576;
      break;
    case EPOS2_TM_T83:
      dots = 576;
      break;
    case EPOS2_TM_T88:
      dots = 512;
      break;
    case EPOS2_TM_T90:
      dots = 512;
      break;
    case EPOS2_TM_T90KP:
      dots = 512;
      break;
    case EPOS2_TM_U220:
      dots = 200;
      break;
    case EPOS2_TM_U330:
      dots = 300;
      break;
    case EPOS2_TM_L90:
      dots = 576;
      break;
    case EPOS2_TM_H6000:
      dots = 512;
      break;
    default:
      dots = 512; //most common (for T88/H6000)
      break;
  }
  
  return dots;
}

- (NSNumber*)getPrinterTypeFromName:(NSString*)printerName
{
  int type=-1;
  
  if([printerName containsString:@"TM-m10"])
  {
    type = EPOS2_TM_M10;
  }
  else if([printerName containsString:@"TM-m30"])
  {
    type = EPOS2_TM_M30;
  }
  else if([printerName containsString:@"TM-P20"])
  {
    type = EPOS2_TM_P20;
  }
  else if([printerName containsString:@"TM-P60II"])
  {
    type = EPOS2_TM_P60II;
  }
  else if([printerName containsString:@"TM-P60"])
  {
    type = EPOS2_TM_P60;
  }
  else if([printerName containsString:@"TM-P80"])
  {
    type = EPOS2_TM_P80;
  }
  else if([printerName containsString:@"TM-T20"])
  {
    type = EPOS2_TM_T20;
  }
  else if([printerName containsString:@"TM-T60"])
  {
    type = EPOS2_TM_T60;
  }
  else if([printerName containsString:@"TM-T70"])
  {
    type = EPOS2_TM_T70;
  }
  else if([printerName containsString:@"TM-T81"])
  {
    type = EPOS2_TM_T81;
  }
  else if([printerName containsString:@"TM-T82"])
  {
    type = EPOS2_TM_T82;
  }
  else if([printerName containsString:@"TM-T83"])
  {
    type = EPOS2_TM_T83;
  }
  else if([printerName containsString:@"TM-T88"])
  {
    type = EPOS2_TM_T88;
  }
  else if([printerName containsString:@"TM-T90KP"])
  {
    type = EPOS2_TM_T90KP;
  }
  else if([printerName containsString:@"TM-T90"])
  {
    type = EPOS2_TM_T90;
  }
  else if([printerName containsString:@"TM-U220"])
  {
    type = EPOS2_TM_U220;
  }
  else if([printerName containsString:@"TM-U330"])
  {
    type = EPOS2_TM_U330;
  }
  else if([printerName containsString:@"TM-L90"])
  {
    type = EPOS2_TM_L90;
  }
  else if([printerName containsString:@"TM-H6000"])
  {
    type = EPOS2_TM_H6000;
  }
  else
  {
    type = EPOS2_TM_T88;  //assume default
  }
  
  return [NSNumber numberWithInteger:type];
}

@end

