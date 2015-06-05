#import <Cordova/CDV.h>
#import <HealthKit/HealthKit.h>

@interface HKAddFood : CDVPlugin
@property (nonatomic) HKHealthStore *healthStore;
    - (void)available:(CDVInvokedUrlCommand*)command;
@end