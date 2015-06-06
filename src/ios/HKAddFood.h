#import <Cordova/CDV.h>
#import <HealthKit/HealthKit.h>

@interface HKAddFood :CDVPlugin

@property (nonatomic) HKHealthStore *healthStore;

- (void) available:(CDVInvokedUrlCommand*)command;
- (void) checkAuthStatus:(CDVInvokedUrlCommand*)command;
- (void) requestAuthorization:(CDVInvokedUrlCommand*)command;
- (void) saveFoodItem:(CDVInvokedUrlCommand*)command;

@end