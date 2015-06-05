#import <Cordova/CDV.h>
#import "HKAddFood.h"

@implementation HKAddFood
- (void) hkaddfood:(CDVInvokedUrlCommand*)command {
    
    NSMutableDictionary *args = [command.arguments objectAtIndex:0];
    NSString *foodName = [args objectForKey:@"foodName"];
    NSString *foodCalories = [args objectForKey:@"Calories"];
    
    BOOL requestReadPermission = [args objectForKey:@"requestReadPermission"] == nil ? YES : [[args objectForKey:@"requestReadPermission"] boolValue];
    
    HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:
                                    HKQuantityTypeIdentifierDietaryCalories];
    HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit kiloCalorieUnit] doubleValue:(double)];
    
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
        
    }]
    
}