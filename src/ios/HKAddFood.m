#import "HKAddFood.h"
#import <Cordova/CDV.h>

static NSString *const HKPluginError = @"HKPluginError";

static NSString *const HKPluginKeyReadTypes = @"readTypes";
static NSString *const HKPluginKeyWriteTypes = @"writeTypes";
static NSString *const HKPluginKeyType = @"type";

static NSString *const HKPluginKeyStartDate = @"startDate";
static NSString *const HKPluginKeyEndDate = @"endDate";
static NSString *const HKPluginKeySampleType = @"sampleType";
static NSString *const HKPluginKeyUnit = @"unit";
static NSString *const HKPluginKeyAmount = @"amount";
static NSString *const HKPluginKeyValue = @"value";
static NSString *const HKPluginKeyCorrelationType = @"correlationType";
static NSString *const HKPluginKeyObjects = @"samples";
static NSString *const HKPluginKeyMetadata = @"metadata";
static NSString *const HKPluginKeyUUID = @"UUID";


@implementation HKAddFood

- (CDVPlugin*) initWithWebView:(UIWebView*)theWebView {
self = (HKAddFood*)[super initWithWebView:theWebView];
if (self) {
_healthStore = [HKHealthStore new];
}
return self;
}

- (void) available:(CDVInvokedUrlCommand*)command {
CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[HKHealthStore isHealthDataAvailable]];
[self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void) requestAuthorization:(CDVInvokedUrlCommand*)command {
NSMutableDictionary *args = [command.arguments objectAtIndex:0];
}
@end