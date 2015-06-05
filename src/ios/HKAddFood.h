#import <Cordova/CDV.h>
#import <HealthKit/HealthKit.h>

@interface HKAddFood : CDVPlugin
@property (nonatomic) HKHealthStore *healthStore;
    - (void)hkaddfood:(CDVInvokedUrlCommand*)command;
    - (void)available:(CDVInvokedUrlCommand*)command;
@end