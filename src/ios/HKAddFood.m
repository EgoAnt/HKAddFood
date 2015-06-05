#import "HKAddFood.h"
#import <Cordova/CDV.h>

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


@end