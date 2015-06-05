#import "HKAddFood.h"
#import <Cordova/CDV.h>

@implementation HKAddFood

- (CDVPlugin*) initWithWebView:(UIWebView*)theWebView {
    self = (HealthKit*)[super initWithWebView:theWebView];
    if (self) {
    _healthStore = [HKHealthStore new];
    }
    return self;
}

- (void) available:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[HKHealthStore isHealthDataAvailable]];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}


- (void) hkaddfood:(CDVInvokedUrlCommand*)command {
    
    NSMutableDictionary *args = [command.arguments objectAtIndex:0];
    NSString *foodName = [args objectForKey:@"foodName"];
    NSString *foodCalories = [args objectForKey:@"Calories"];
    
    BOOL requestReadPermission = [args objectForKey:@"requestReadPermission"] == nil ? YES : [[args objectForKey:@"requestReadPermission"] boolValue];
    
    HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:
                                    HKQuantityTypeIdentifierDietaryCalories];
                                    HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit kiloCalorieUnit] doubleValue:foodCalories];
    
    NSDate *objDate = [NSDate date];
    NSDictionary *metaData = @{HKMetadataKeyFoodType:foodName};
    
    HKQuantityType *foodItemSample =
    [HKQuantitySample quantitySampleWithType:quantityType
                                    quantity:quantity
                                   startDate:objDate
                                     endDate:objDate
                                    metadata:metaData]
    
    
    [self.healthStore saveObject:foodItemSample withCompletion:^(BOOL success, NSError *error){
        if(success){
            NSLog(@"Saved food!");
        }
    }];
    
}
@end