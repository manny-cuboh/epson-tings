  //  Created by react-native-create-bridge

// import RCTBridgeModule
#if __has_include(<React/RCTBridgeModule.h>)
#import <React/RCTBridgeModule.h>
#elif __has_include("RCTBridgeModule.h")
#import “RCTBridgeModule.h”
#else
#import "React/RCTBridgeModule.h" // Required when used as a Pod in a Swift project
#endif


// import RCTEventEmitter
#if __has_include(<React/RCTEventEmitter.h>)
#import <React/RCTEventEmitter.h>
#elif __has_include("RCTEventEmitter.h")
#import "RCTEventEmitter.h"
#else
#import "React/RCTEventEmitter.h" // Required when used as a Pod in a Swift project
#endif

#import "ePOS2.h"

@interface EpsonEposSDK : RCTEventEmitter <RCTBridgeModule>
{
  // Define class properties here with @property
  
  Epos2Printer *printer_;
  int printerSeries_;
  int lang_;
  bool connected_;
}

+ (BOOL)requiresMainQueueSetup;

@end

