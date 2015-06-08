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

- (void) checkAuthStatus:(CDVInvokedUrlCommand*)command {
	// Note for doc, if status = denied, prompt user to go to settings or the Health app
	NSMutableDictionary *args = [command.arguments objectAtIndex:0];
	NSString *checkType = [args objectForKey:HKPluginKeyType];

	HKObjectType *type = [self getHKObjectType:checkType];
	if (type == nil) {
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"type is an invalid value"];
		[self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
	} else {
		HKAuthorizationStatus status = [self.healthStore authorizationStatusForType:type];
		NSString *result;
		if (status == HKAuthorizationStatusNotDetermined) {
			result = @"undetermined";
		} else if (status == HKAuthorizationStatusSharingDenied) {
			result = @"denied";
		} else if (status == HKAuthorizationStatusSharingAuthorized) {
			result = @"authorized";
		}
		CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
		[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
	}
}

- (void) saveFoodItem:(CDVInvokedUrlCommand*)command {
	NSMutableDictionary *args = [command.arguments objectAtIndex:0];
	NSString *foodName = [args objectForKey:@"foodName"];
	NSString *foodCalories = [args objectForKey:@"foodCalories"];
	NSString *foodProtein = [args objectForKey:@"foodProtein"];
	NSString *foodCarbohydrates = [args objectForKey:@"foodCarbohydrates"];
	NSString *foodFatTotal = [args objectForKey:@"foodFatTotal"];

	double dbCalories = [foodCalories doubleValue];
	double dbProtein = [foodProtein doubleValue];
	double dbCarbohydrates = [foodCarbohydrates doubleValue];
	double dbFatTotal = [foodFatTotal doubleValue];
	
	if ([HKHealthStore isHealthDataAvailable]) {
    NSSet* nutritionTypes = [NSSet setWithObjects:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed],
                    [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCarbohydrates],
                    [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryFatTotal],
                    [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryProtein],
                    nil];

        NSDate* timeFoodWasConsumed = [NSDate date];
        NSDictionary *metadata = @{
                HKMetadataKeyFoodType:@foodName,
                @"HKFoodBrandName":@"Prime Dining", // Restaurant name or packaged food brand name
        };
		
        HKQuantitySample* calories = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed]
                                                                 quantity:[HKQuantity quantityWithUnit:[HKUnit kilocalorieUnit] doubleValue:dbCalories]
                                                                startDate:timeFoodWasConsumed
                                                                  endDate:timeFoodWasConsumed
                                                                 metadata:metadata];

        HKQuantitySample* protein = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryProtein]
                                                                    quantity:[HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:dbProtein]
                                                                   startDate:timeFoodWasConsumed
                                                                     endDate:timeFoodWasConsumed
                                                                    metadata:metadata];


        HKQuantitySample* carbohydrates = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCarbohydrates]
                                                                  quantity:[HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:dbCarbohydrates]
                                                                 startDate:timeFoodWasConsumed
                                                                   endDate:timeFoodWasConsumed
                                                                  metadata:metadata];

        HKQuantitySample* fat = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryFatTotal]
                                                                quantity:[HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:dbFatTotal]
                                                               startDate:timeFoodWasConsumed
                                                                 endDate:timeFoodWasConsumed
                                                                metadata:metadata];

        HKCorrelation* food = [HKCorrelation correlationWithType:[HKCorrelationType correlationTypeForIdentifier:HKCorrelationTypeIdentifierFood]
                                                              startDate:timeFoodWasConsumed
                                                                endDate:timeFoodWasConsumed
                                                                objects:[NSSet setWithObjects:calories, protein, carbohydrates, fat, nil]
                                                               metadata:metadata];

        [healthStore saveObject:food withCompletion:^(BOOL success, NSError *error) {
            if (success) {
				CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully wrote a food to HealthKit"];
				[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            } else {
				CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Failed to write food to HealthKit"];
				[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
        }];

    }];

}

- (void) saveFoodItemCalories:(CDVInvokedUrlCommand*)command {
	NSMutableDictionary *args = [command.arguments objectAtIndex:0];
	NSString *foodName = [args objectForKey:@"foodName"];
	NSString *foodCalories = [args objectForKey:@"foodValue"];

	double calDouble = [foodCalories doubleValue];

	HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
	HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit kilocalorieUnit] doubleValue:calDouble];

	NSDate *objDate = [NSDate date];
	NSDictionary *metaData = @{HKMetadataKeyFoodType:foodName};

	HKQuantitySample *foodItemSample =
	[HKQuantitySample quantitySampleWithType:quantityType
	quantity:quantity
	startDate:objDate
	endDate:objDate
	metadata:metaData];


	[self.healthStore saveObject:foodItemSample withCompletion:^(BOOL success, NSError *error){
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[HKHealthStore isHealthDataAvailable]];
		if(success){
			result = @"saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}else{
			result = @"not saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}
	}];
}

- (void) saveFoodItemFatTotal:(CDVInvokedUrlCommand*)command {
	NSMutableDictionary *args = [command.arguments objectAtIndex:0];
	NSString *foodName = [args objectForKey:@"foodName"];
    NSString *foodValue = [args objectForKey:@"foodValue"];

    double unitDouble = [foodValue doubleValue];

	HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryFatTotal];
	HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];

	NSDate *objDate = [NSDate date];
	NSDictionary *metaData = @{HKMetadataKeyFoodType:foodName};

	HKQuantitySample *foodItemSample =
	[HKQuantitySample quantitySampleWithType:quantityType
	quantity:quantity
	startDate:objDate
	endDate:objDate
	metadata:metaData];


	[self.healthStore saveObject:foodItemSample withCompletion:^(BOOL success, NSError *error){
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[HKHealthStore isHealthDataAvailable]];
		if(success){
			result = @"saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}else{
			result = @"not saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}
	}];
}

- (void) saveFoodItemCalcium:(CDVInvokedUrlCommand*)command {
	NSMutableDictionary *args = [command.arguments objectAtIndex:0];
	NSString *foodName = [args objectForKey:@"foodName"];
    NSString *foodValue = [args objectForKey:@"foodValue"];

    double unitDouble = [foodValue doubleValue];

	HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCalcium];
	HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];

	NSDate *objDate = [NSDate date];
	NSDictionary *metaData = @{HKMetadataKeyFoodType:foodName};

	HKQuantitySample *foodItemSample =
	[HKQuantitySample quantitySampleWithType:quantityType
	quantity:quantity
	startDate:objDate
	endDate:objDate
	metadata:metaData];


	[self.healthStore saveObject:foodItemSample withCompletion:^(BOOL success, NSError *error){
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[HKHealthStore isHealthDataAvailable]];
		if(success){
			result = @"saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}else{
			result = @"not saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}
	}];
}

- (void) saveFoodItemBiotin:(CDVInvokedUrlCommand*)command {
	NSMutableDictionary *args = [command.arguments objectAtIndex:0];
	NSString *foodName = [args objectForKey:@"foodName"];
    NSString *foodValue = [args objectForKey:@"foodValue"];

    double unitDouble = [foodValue doubleValue];

	HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryBiotin];
	HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];

	NSDate *objDate = [NSDate date];
	NSDictionary *metaData = @{HKMetadataKeyFoodType:foodName};

	HKQuantitySample *foodItemSample =
	[HKQuantitySample quantitySampleWithType:quantityType
	quantity:quantity
	startDate:objDate
	endDate:objDate
	metadata:metaData];


	[self.healthStore saveObject:foodItemSample withCompletion:^(BOOL success, NSError *error){
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[HKHealthStore isHealthDataAvailable]];
		if(success){
			result = @"saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}else{
			result = @"not saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}
	}];
}

- (void) saveFoodItemCaffeine:(CDVInvokedUrlCommand*)command {
	NSMutableDictionary *args = [command.arguments objectAtIndex:0];
	NSString *foodName = [args objectForKey:@"foodName"];
    NSString *foodValue = [args objectForKey:@"foodValue"];

    double unitDouble = [foodValue doubleValue];

	HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCaffeine];
	HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];

	NSDate *objDate = [NSDate date];
	NSDictionary *metaData = @{HKMetadataKeyFoodType:foodName};

	HKQuantitySample *foodItemSample =
	[HKQuantitySample quantitySampleWithType:quantityType
	quantity:quantity
	startDate:objDate
	endDate:objDate
	metadata:metaData];


	[self.healthStore saveObject:foodItemSample withCompletion:^(BOOL success, NSError *error){
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[HKHealthStore isHealthDataAvailable]];
		if(success){
			result = @"saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}else{
			result = @"not saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}
	}];
}

- (void) saveFoodItemCarbohydrates:(CDVInvokedUrlCommand*)command {
	NSMutableDictionary *args = [command.arguments objectAtIndex:0];
	NSString *foodName = [args objectForKey:@"foodName"];
    NSString *foodValue = [args objectForKey:@"foodValue"];

    double unitDouble = [foodValue doubleValue];

	HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCarbohydrates];
	HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];

	NSDate *objDate = [NSDate date];
	NSDictionary *metaData = @{HKMetadataKeyFoodType:foodName};

	HKQuantitySample *foodItemSample =
	[HKQuantitySample quantitySampleWithType:quantityType
	quantity:quantity
	startDate:objDate
	endDate:objDate
	metadata:metaData];


	[self.healthStore saveObject:foodItemSample withCompletion:^(BOOL success, NSError *error){
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[HKHealthStore isHealthDataAvailable]];
		if(success){
			result = @"saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}else{
			result = @"not saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}
	}];
}

- (void) saveFoodItemChloride:(CDVInvokedUrlCommand*)command {
	NSMutableDictionary *args = [command.arguments objectAtIndex:0];
	NSString *foodName = [args objectForKey:@"foodName"];
    NSString *foodValue = [args objectForKey:@"foodValue"];

    double unitDouble = [foodValue doubleValue];

	HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryChloride];
	HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];

	NSDate *objDate = [NSDate date];
	NSDictionary *metaData = @{HKMetadataKeyFoodType:foodName};

	HKQuantitySample *foodItemSample =
	[HKQuantitySample quantitySampleWithType:quantityType
	quantity:quantity
	startDate:objDate
	endDate:objDate
	metadata:metaData];


	[self.healthStore saveObject:foodItemSample withCompletion:^(BOOL success, NSError *error){
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[HKHealthStore isHealthDataAvailable]];
		if(success){
			result = @"saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}else{
			result = @"not saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}
	}];
}

- (void) saveFoodItemCholesterol:(CDVInvokedUrlCommand*)command {
	NSMutableDictionary *args = [command.arguments objectAtIndex:0];
	NSString *foodName = [args objectForKey:@"foodName"];
    NSString *foodValue = [args objectForKey:@"foodValue"];

    double unitDouble = [foodValue doubleValue];

	HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCholesterol];
	HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];

	NSDate *objDate = [NSDate date];
	NSDictionary *metaData = @{HKMetadataKeyFoodType:foodName};

	HKQuantitySample *foodItemSample =
	[HKQuantitySample quantitySampleWithType:quantityType
	quantity:quantity
	startDate:objDate
	endDate:objDate
	metadata:metaData];


	[self.healthStore saveObject:foodItemSample withCompletion:^(BOOL success, NSError *error){
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[HKHealthStore isHealthDataAvailable]];
		if(success){
			result = @"saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}else{
			result = @"not saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}
	}];
}

- (void) saveFoodItemChromium:(CDVInvokedUrlCommand*)command {
	NSMutableDictionary *args = [command.arguments objectAtIndex:0];
	NSString *foodName = [args objectForKey:@"foodName"];
    NSString *foodValue = [args objectForKey:@"foodValue"];

    double unitDouble = [foodValue doubleValue];

	HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryChromium];
	HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];

	NSDate *objDate = [NSDate date];
	NSDictionary *metaData = @{HKMetadataKeyFoodType:foodName};

	HKQuantitySample *foodItemSample =
	[HKQuantitySample quantitySampleWithType:quantityType
	quantity:quantity
	startDate:objDate
	endDate:objDate
	metadata:metaData];


	[self.healthStore saveObject:foodItemSample withCompletion:^(BOOL success, NSError *error){
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[HKHealthStore isHealthDataAvailable]];
		if(success){
			result = @"saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}else{
			result = @"not saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}
	}];
}

- (void) saveFoodItemCopper:(CDVInvokedUrlCommand*)command {
	NSMutableDictionary *args = [command.arguments objectAtIndex:0];
	NSString *foodName = [args objectForKey:@"foodName"];
    NSString *foodValue = [args objectForKey:@"foodValue"];

    double unitDouble = [foodValue doubleValue];

	HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCopper];
	HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];

	NSDate *objDate = [NSDate date];
	NSDictionary *metaData = @{HKMetadataKeyFoodType:foodName};

	HKQuantitySample *foodItemSample =
	[HKQuantitySample quantitySampleWithType:quantityType
	quantity:quantity
	startDate:objDate
	endDate:objDate
	metadata:metaData];


	[self.healthStore saveObject:foodItemSample withCompletion:^(BOOL success, NSError *error){
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[HKHealthStore isHealthDataAvailable]];
		if(success){
			result = @"saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}else{
			result = @"not saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}
	}];
}

- (void) saveFoodItemFatMonounsaturated:(CDVInvokedUrlCommand*)command {
	NSMutableDictionary *args = [command.arguments objectAtIndex:0];
	NSString *foodName = [args objectForKey:@"foodName"];
    NSString *foodValue = [args objectForKey:@"foodValue"];

    double unitDouble = [foodValue doubleValue];

	HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryFatMonounsaturated];
	HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];

	NSDate *objDate = [NSDate date];
	NSDictionary *metaData = @{HKMetadataKeyFoodType:foodName};

	HKQuantitySample *foodItemSample =
	[HKQuantitySample quantitySampleWithType:quantityType
	quantity:quantity
	startDate:objDate
	endDate:objDate
	metadata:metaData];


	[self.healthStore saveObject:foodItemSample withCompletion:^(BOOL success, NSError *error){
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[HKHealthStore isHealthDataAvailable]];
		if(success){
			result = @"saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}else{
			result = @"not saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}
	}];
}

- (void) saveFoodItemFatPolyunsaturated:(CDVInvokedUrlCommand*)command {
	NSMutableDictionary *args = [command.arguments objectAtIndex:0];
	NSString *foodName = [args objectForKey:@"foodName"];
    NSString *foodValue = [args objectForKey:@"foodValue"];

    double unitDouble = [foodValue doubleValue];

	HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryFatPolyunsaturated];
	HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];

	NSDate *objDate = [NSDate date];
	NSDictionary *metaData = @{HKMetadataKeyFoodType:foodName};

	HKQuantitySample *foodItemSample =
	[HKQuantitySample quantitySampleWithType:quantityType
	quantity:quantity
	startDate:objDate
	endDate:objDate
	metadata:metaData];


	[self.healthStore saveObject:foodItemSample withCompletion:^(BOOL success, NSError *error){
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[HKHealthStore isHealthDataAvailable]];
		if(success){
			result = @"saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}else{
			result = @"not saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}
	}];
}

- (void) saveFoodItemFatSaturated:(CDVInvokedUrlCommand*)command {
	NSMutableDictionary *args = [command.arguments objectAtIndex:0];
	NSString *foodName = [args objectForKey:@"foodName"];
    NSString *foodValue = [args objectForKey:@"foodValue"];

    double unitDouble = [foodValue doubleValue];

	HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryFatSaturated];
	HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];

	NSDate *objDate = [NSDate date];
	NSDictionary *metaData = @{HKMetadataKeyFoodType:foodName};

	HKQuantitySample *foodItemSample =
	[HKQuantitySample quantitySampleWithType:quantityType
	quantity:quantity
	startDate:objDate
	endDate:objDate
	metadata:metaData];


	[self.healthStore saveObject:foodItemSample withCompletion:^(BOOL success, NSError *error){
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[HKHealthStore isHealthDataAvailable]];
		if(success){
			result = @"saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}else{
			result = @"not saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}
	}];
}

- (void) saveFoodItemFiber:(CDVInvokedUrlCommand*)command {
	NSMutableDictionary *args = [command.arguments objectAtIndex:0];
	NSString *foodName = [args objectForKey:@"foodName"];
    NSString *foodValue = [args objectForKey:@"foodValue"];

    double unitDouble = [foodValue doubleValue];

	HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryFiber];
	HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];

	NSDate *objDate = [NSDate date];
	NSDictionary *metaData = @{HKMetadataKeyFoodType:foodName};

	HKQuantitySample *foodItemSample =
	[HKQuantitySample quantitySampleWithType:quantityType
	quantity:quantity
	startDate:objDate
	endDate:objDate
	metadata:metaData];


	[self.healthStore saveObject:foodItemSample withCompletion:^(BOOL success, NSError *error){
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[HKHealthStore isHealthDataAvailable]];
		if(success){
			result = @"saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}else{
			result = @"not saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}
	}];
}

- (void) saveFoodItemFolate:(CDVInvokedUrlCommand*)command {
	NSMutableDictionary *args = [command.arguments objectAtIndex:0];
	NSString *foodName = [args objectForKey:@"foodName"];
    NSString *foodValue = [args objectForKey:@"foodValue"];

    double unitDouble = [foodValue doubleValue];

	HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryFolate];
	HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];

	NSDate *objDate = [NSDate date];
	NSDictionary *metaData = @{HKMetadataKeyFoodType:foodName};

	HKQuantitySample *foodItemSample =
	[HKQuantitySample quantitySampleWithType:quantityType
	quantity:quantity
	startDate:objDate
	endDate:objDate
	metadata:metaData];


	[self.healthStore saveObject:foodItemSample withCompletion:^(BOOL success, NSError *error){
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[HKHealthStore isHealthDataAvailable]];
		if(success){
			result = @"saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}else{
			result = @"not saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}
	}];
}

- (void) saveFoodItemIodine:(CDVInvokedUrlCommand*)command {
	NSMutableDictionary *args = [command.arguments objectAtIndex:0];
	NSString *foodName = [args objectForKey:@"foodName"];
    NSString *foodValue = [args objectForKey:@"foodValue"];

    double unitDouble = [foodValue doubleValue];

	HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryIodine];
	HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];

	NSDate *objDate = [NSDate date];
	NSDictionary *metaData = @{HKMetadataKeyFoodType:foodName};

	HKQuantitySample *foodItemSample =
	[HKQuantitySample quantitySampleWithType:quantityType
	quantity:quantity
	startDate:objDate
	endDate:objDate
	metadata:metaData];


	[self.healthStore saveObject:foodItemSample withCompletion:^(BOOL success, NSError *error){
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[HKHealthStore isHealthDataAvailable]];
		if(success){
			result = @"saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}else{
			result = @"not saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}
	}];
}

- (void) saveFoodItemIron:(CDVInvokedUrlCommand*)command {
	NSMutableDictionary *args = [command.arguments objectAtIndex:0];
	NSString *foodName = [args objectForKey:@"foodName"];
    NSString *foodValue = [args objectForKey:@"foodValue"];

    double unitDouble = [foodValue doubleValue];

	HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryIron];
	HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];

	NSDate *objDate = [NSDate date];
	NSDictionary *metaData = @{HKMetadataKeyFoodType:foodName};

	HKQuantitySample *foodItemSample =
	[HKQuantitySample quantitySampleWithType:quantityType
	quantity:quantity
	startDate:objDate
	endDate:objDate
	metadata:metaData];


	[self.healthStore saveObject:foodItemSample withCompletion:^(BOOL success, NSError *error){
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[HKHealthStore isHealthDataAvailable]];
		if(success){
			result = @"saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}else{
			result = @"not saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}
	}];
}

- (void) saveFoodItemMagnesium:(CDVInvokedUrlCommand*)command {
	NSMutableDictionary *args = [command.arguments objectAtIndex:0];
	NSString *foodName = [args objectForKey:@"foodName"];
    NSString *foodValue = [args objectForKey:@"foodValue"];

    double unitDouble = [foodValue doubleValue];

	HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryMagnesium];
	HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];

	NSDate *objDate = [NSDate date];
	NSDictionary *metaData = @{HKMetadataKeyFoodType:foodName};

	HKQuantitySample *foodItemSample =
	[HKQuantitySample quantitySampleWithType:quantityType
	quantity:quantity
	startDate:objDate
	endDate:objDate
	metadata:metaData];


	[self.healthStore saveObject:foodItemSample withCompletion:^(BOOL success, NSError *error){
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[HKHealthStore isHealthDataAvailable]];
		if(success){
			result = @"saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}else{
			result = @"not saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}
	}];
}

- (void) saveFoodItemManganese:(CDVInvokedUrlCommand*)command {
	NSMutableDictionary *args = [command.arguments objectAtIndex:0];
	NSString *foodName = [args objectForKey:@"foodName"];
    NSString *foodValue = [args objectForKey:@"foodValue"];

    double unitDouble = [foodValue doubleValue];

	HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryManganese];
	HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];

	NSDate *objDate = [NSDate date];
	NSDictionary *metaData = @{HKMetadataKeyFoodType:foodName};

	HKQuantitySample *foodItemSample =
	[HKQuantitySample quantitySampleWithType:quantityType
	quantity:quantity
	startDate:objDate
	endDate:objDate
	metadata:metaData];


	[self.healthStore saveObject:foodItemSample withCompletion:^(BOOL success, NSError *error){
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[HKHealthStore isHealthDataAvailable]];
		if(success){
			result = @"saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}else{
			result = @"not saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}
	}];
}

- (void) saveFoodItemMolybdenum:(CDVInvokedUrlCommand*)command {
	NSMutableDictionary *args = [command.arguments objectAtIndex:0];
	NSString *foodName = [args objectForKey:@"foodName"];
    NSString *foodValue = [args objectForKey:@"foodValue"];

    double unitDouble = [foodValue doubleValue];

	HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryMolybdenum];
	HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];

	NSDate *objDate = [NSDate date];
	NSDictionary *metaData = @{HKMetadataKeyFoodType:foodName};

	HKQuantitySample *foodItemSample =
	[HKQuantitySample quantitySampleWithType:quantityType
	quantity:quantity
	startDate:objDate
	endDate:objDate
	metadata:metaData];


	[self.healthStore saveObject:foodItemSample withCompletion:^(BOOL success, NSError *error){
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[HKHealthStore isHealthDataAvailable]];
		if(success){
			result = @"saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}else{
			result = @"not saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}
	}];
}

- (void) saveFoodItemNiacin:(CDVInvokedUrlCommand*)command {
	NSMutableDictionary *args = [command.arguments objectAtIndex:0];
	NSString *foodName = [args objectForKey:@"foodName"];
    NSString *foodValue = [args objectForKey:@"foodValue"];

    double unitDouble = [foodValue doubleValue];

	HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryNiacin];
	HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];

	NSDate *objDate = [NSDate date];
	NSDictionary *metaData = @{HKMetadataKeyFoodType:foodName};

	HKQuantitySample *foodItemSample =
	[HKQuantitySample quantitySampleWithType:quantityType
	quantity:quantity
	startDate:objDate
	endDate:objDate
	metadata:metaData];


	[self.healthStore saveObject:foodItemSample withCompletion:^(BOOL success, NSError *error){
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[HKHealthStore isHealthDataAvailable]];
		if(success){
			result = @"saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}else{
			result = @"not saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}
	}];
}

- (void) saveFoodItemPantothenicAcid:(CDVInvokedUrlCommand*)command {
	NSMutableDictionary *args = [command.arguments objectAtIndex:0];
	NSString *foodName = [args objectForKey:@"foodName"];
    NSString *foodValue = [args objectForKey:@"foodValue"];

    double unitDouble = [foodValue doubleValue];

	HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryPantothenicAcid];
	HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];

	NSDate *objDate = [NSDate date];
	NSDictionary *metaData = @{HKMetadataKeyFoodType:foodName};

	HKQuantitySample *foodItemSample =
	[HKQuantitySample quantitySampleWithType:quantityType
	quantity:quantity
	startDate:objDate
	endDate:objDate
	metadata:metaData];


	[self.healthStore saveObject:foodItemSample withCompletion:^(BOOL success, NSError *error){
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[HKHealthStore isHealthDataAvailable]];
		if(success){
			result = @"saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}else{
			result = @"not saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}
	}];
}

- (void) saveFoodItemPhosphorus:(CDVInvokedUrlCommand*)command {
	NSMutableDictionary *args = [command.arguments objectAtIndex:0];
	NSString *foodName = [args objectForKey:@"foodName"];
    NSString *foodValue = [args objectForKey:@"foodValue"];

    double unitDouble = [foodValue doubleValue];

	HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryPhosphorus];
	HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];

	NSDate *objDate = [NSDate date];
	NSDictionary *metaData = @{HKMetadataKeyFoodType:foodName};

	HKQuantitySample *foodItemSample =
	[HKQuantitySample quantitySampleWithType:quantityType
	quantity:quantity
	startDate:objDate
	endDate:objDate
	metadata:metaData];


	[self.healthStore saveObject:foodItemSample withCompletion:^(BOOL success, NSError *error){
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[HKHealthStore isHealthDataAvailable]];
		if(success){
			result = @"saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}else{
			result = @"not saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}
	}];
}

- (void) saveFoodItemPotassium:(CDVInvokedUrlCommand*)command {
	NSMutableDictionary *args = [command.arguments objectAtIndex:0];
	NSString *foodName = [args objectForKey:@"foodName"];
    NSString *foodValue = [args objectForKey:@"foodValue"];

    double unitDouble = [foodValue doubleValue];

	HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryPotassium];
	HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];

	NSDate *objDate = [NSDate date];
	NSDictionary *metaData = @{HKMetadataKeyFoodType:foodName};

	HKQuantitySample *foodItemSample =
	[HKQuantitySample quantitySampleWithType:quantityType
	quantity:quantity
	startDate:objDate
	endDate:objDate
	metadata:metaData];


	[self.healthStore saveObject:foodItemSample withCompletion:^(BOOL success, NSError *error){
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[HKHealthStore isHealthDataAvailable]];
		if(success){
			result = @"saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}else{
			result = @"not saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}
	}];
}

- (void) saveFoodItemProtein:(CDVInvokedUrlCommand*)command {
	NSMutableDictionary *args = [command.arguments objectAtIndex:0];
	NSString *foodName = [args objectForKey:@"foodName"];
    NSString *foodValue = [args objectForKey:@"foodValue"];

    double unitDouble = [foodValue doubleValue];

	HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryProtein];
	HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];

	NSDate *objDate = [NSDate date];
	NSDictionary *metaData = @{HKMetadataKeyFoodType:foodName};

	HKQuantitySample *foodItemSample =
	[HKQuantitySample quantitySampleWithType:quantityType
	quantity:quantity
	startDate:objDate
	endDate:objDate
	metadata:metaData];


	[self.healthStore saveObject:foodItemSample withCompletion:^(BOOL success, NSError *error){
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[HKHealthStore isHealthDataAvailable]];
		if(success){
			result = @"saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}else{
			result = @"not saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}
	}];
}

- (void) saveFoodItemRiboflavin:(CDVInvokedUrlCommand*)command {
	NSMutableDictionary *args = [command.arguments objectAtIndex:0];
	NSString *foodName = [args objectForKey:@"foodName"];
    NSString *foodValue = [args objectForKey:@"foodValue"];

    double unitDouble = [foodValue doubleValue];

	HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryRiboflavin];
	HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];

	NSDate *objDate = [NSDate date];
	NSDictionary *metaData = @{HKMetadataKeyFoodType:foodName};

	HKQuantitySample *foodItemSample =
	[HKQuantitySample quantitySampleWithType:quantityType
	quantity:quantity
	startDate:objDate
	endDate:objDate
	metadata:metaData];


	[self.healthStore saveObject:foodItemSample withCompletion:^(BOOL success, NSError *error){
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[HKHealthStore isHealthDataAvailable]];
		if(success){
			result = @"saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}else{
			result = @"not saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}
	}];
}

- (void) saveFoodItemSelenium:(CDVInvokedUrlCommand*)command {
	NSMutableDictionary *args = [command.arguments objectAtIndex:0];
	NSString *foodName = [args objectForKey:@"foodName"];
    NSString *foodValue = [args objectForKey:@"foodValue"];

    double unitDouble = [foodValue doubleValue];

	HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietarySelenium];
	HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];

	NSDate *objDate = [NSDate date];
	NSDictionary *metaData = @{HKMetadataKeyFoodType:foodName};

	HKQuantitySample *foodItemSample =
	[HKQuantitySample quantitySampleWithType:quantityType
	quantity:quantity
	startDate:objDate
	endDate:objDate
	metadata:metaData];


	[self.healthStore saveObject:foodItemSample withCompletion:^(BOOL success, NSError *error){
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[HKHealthStore isHealthDataAvailable]];
		if(success){
			result = @"saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}else{
			result = @"not saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}
	}];
}

- (void) saveFoodItemSodium:(CDVInvokedUrlCommand*)command {
	NSMutableDictionary *args = [command.arguments objectAtIndex:0];
	NSString *foodName = [args objectForKey:@"foodName"];
    NSString *foodValue = [args objectForKey:@"foodValue"];

    double unitDouble = [foodValue doubleValue];

	HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietarySodium];
	HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];

	NSDate *objDate = [NSDate date];
	NSDictionary *metaData = @{HKMetadataKeyFoodType:foodName};

	HKQuantitySample *foodItemSample =
	[HKQuantitySample quantitySampleWithType:quantityType
	quantity:quantity
	startDate:objDate
	endDate:objDate
	metadata:metaData];


	[self.healthStore saveObject:foodItemSample withCompletion:^(BOOL success, NSError *error){
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[HKHealthStore isHealthDataAvailable]];
		if(success){
			result = @"saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}else{
			result = @"not saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}
	}];
}

- (void) saveFoodItemSugar:(CDVInvokedUrlCommand*)command {
	NSMutableDictionary *args = [command.arguments objectAtIndex:0];
	NSString *foodName = [args objectForKey:@"foodName"];
    NSString *foodValue = [args objectForKey:@"foodValue"];

    double unitDouble = [foodValue doubleValue];

	HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietarySugar];
	HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];

	NSDate *objDate = [NSDate date];
	NSDictionary *metaData = @{HKMetadataKeyFoodType:foodName};

	HKQuantitySample *foodItemSample =
	[HKQuantitySample quantitySampleWithType:quantityType
	quantity:quantity
	startDate:objDate
	endDate:objDate
	metadata:metaData];


	[self.healthStore saveObject:foodItemSample withCompletion:^(BOOL success, NSError *error){
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[HKHealthStore isHealthDataAvailable]];
		if(success){
			result = @"saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}else{
			result = @"not saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}
	}];
}

- (void) saveFoodItemThiamin:(CDVInvokedUrlCommand*)command {
	NSMutableDictionary *args = [command.arguments objectAtIndex:0];
	NSString *foodName = [args objectForKey:@"foodName"];
    NSString *foodValue = [args objectForKey:@"foodValue"];

    double unitDouble = [foodValue doubleValue];

	HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryThiamin];
	HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];

	NSDate *objDate = [NSDate date];
	NSDictionary *metaData = @{HKMetadataKeyFoodType:foodName};

	HKQuantitySample *foodItemSample =
	[HKQuantitySample quantitySampleWithType:quantityType
	quantity:quantity
	startDate:objDate
	endDate:objDate
	metadata:metaData];


	[self.healthStore saveObject:foodItemSample withCompletion:^(BOOL success, NSError *error){
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[HKHealthStore isHealthDataAvailable]];
		if(success){
			result = @"saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}else{
			result = @"not saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}
	}];
}

- (void) saveFoodItemVitaminA:(CDVInvokedUrlCommand*)command {
	NSMutableDictionary *args = [command.arguments objectAtIndex:0];
	NSString *foodName = [args objectForKey:@"foodName"];
    NSString *foodValue = [args objectForKey:@"foodValue"];

    double unitDouble = [foodValue doubleValue];

	HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryVitaminA];
	HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];

	NSDate *objDate = [NSDate date];
	NSDictionary *metaData = @{HKMetadataKeyFoodType:foodName};

	HKQuantitySample *foodItemSample =
	[HKQuantitySample quantitySampleWithType:quantityType
	quantity:quantity
	startDate:objDate
	endDate:objDate
	metadata:metaData];


	[self.healthStore saveObject:foodItemSample withCompletion:^(BOOL success, NSError *error){
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[HKHealthStore isHealthDataAvailable]];
		if(success){
			result = @"saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}else{
			result = @"not saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}
	}];
}

- (void) saveFoodItemVitaminB12:(CDVInvokedUrlCommand*)command {
	NSMutableDictionary *args = [command.arguments objectAtIndex:0];
	NSString *foodName = [args objectForKey:@"foodName"];
    NSString *foodValue = [args objectForKey:@"foodValue"];

    double unitDouble = [foodValue doubleValue];

	HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryVitaminB12];
	HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];

	NSDate *objDate = [NSDate date];
	NSDictionary *metaData = @{HKMetadataKeyFoodType:foodName};

	HKQuantitySample *foodItemSample =
	[HKQuantitySample quantitySampleWithType:quantityType
	quantity:quantity
	startDate:objDate
	endDate:objDate
	metadata:metaData];


	[self.healthStore saveObject:foodItemSample withCompletion:^(BOOL success, NSError *error){
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[HKHealthStore isHealthDataAvailable]];
		if(success){
			result = @"saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}else{
			result = @"not saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}
	}];
}

- (void) saveFoodItemVitaminB6:(CDVInvokedUrlCommand*)command {
	NSMutableDictionary *args = [command.arguments objectAtIndex:0];
	NSString *foodName = [args objectForKey:@"foodName"];
    NSString *foodValue = [args objectForKey:@"foodValue"];

    double unitDouble = [foodValue doubleValue];

	HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryVitaminB6];
	HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];

	NSDate *objDate = [NSDate date];
	NSDictionary *metaData = @{HKMetadataKeyFoodType:foodName};

	HKQuantitySample *foodItemSample =
	[HKQuantitySample quantitySampleWithType:quantityType
	quantity:quantity
	startDate:objDate
	endDate:objDate
	metadata:metaData];


	[self.healthStore saveObject:foodItemSample withCompletion:^(BOOL success, NSError *error){
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[HKHealthStore isHealthDataAvailable]];
		if(success){
			result = @"saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}else{
			result = @"not saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}
	}];
}

- (void) saveFoodItemVitaminC:(CDVInvokedUrlCommand*)command {
	NSMutableDictionary *args = [command.arguments objectAtIndex:0];
	NSString *foodName = [args objectForKey:@"foodName"];
    NSString *foodValue = [args objectForKey:@"foodValue"];

    double unitDouble = [foodValue doubleValue];

	HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryVitaminC];
	HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];

	NSDate *objDate = [NSDate date];
	NSDictionary *metaData = @{HKMetadataKeyFoodType:foodName};

	HKQuantitySample *foodItemSample =
	[HKQuantitySample quantitySampleWithType:quantityType
	quantity:quantity
	startDate:objDate
	endDate:objDate
	metadata:metaData];


	[self.healthStore saveObject:foodItemSample withCompletion:^(BOOL success, NSError *error){
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[HKHealthStore isHealthDataAvailable]];
		if(success){
			result = @"saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}else{
			result = @"not saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}
	}];
}

- (void) saveFoodItemVitaminD:(CDVInvokedUrlCommand*)command {
	NSMutableDictionary *args = [command.arguments objectAtIndex:0];
	NSString *foodName = [args objectForKey:@"foodName"];
    NSString *foodValue = [args objectForKey:@"foodValue"];

    double unitDouble = [foodValue doubleValue];

	HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryVitaminD];
	HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];

	NSDate *objDate = [NSDate date];
	NSDictionary *metaData = @{HKMetadataKeyFoodType:foodName};

	HKQuantitySample *foodItemSample =
	[HKQuantitySample quantitySampleWithType:quantityType
	quantity:quantity
	startDate:objDate
	endDate:objDate
	metadata:metaData];


	[self.healthStore saveObject:foodItemSample withCompletion:^(BOOL success, NSError *error){
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[HKHealthStore isHealthDataAvailable]];
		if(success){
			result = @"saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}else{
			result = @"not saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}
	}];
}

- (void) saveFoodItemVitaminE:(CDVInvokedUrlCommand*)command {
	NSMutableDictionary *args = [command.arguments objectAtIndex:0];
	NSString *foodName = [args objectForKey:@"foodName"];
    NSString *foodValue = [args objectForKey:@"foodValue"];

    double unitDouble = [foodValue doubleValue];

	HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryVitaminE];
	HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];

	NSDate *objDate = [NSDate date];
	NSDictionary *metaData = @{HKMetadataKeyFoodType:foodName};

	HKQuantitySample *foodItemSample =
	[HKQuantitySample quantitySampleWithType:quantityType
	quantity:quantity
	startDate:objDate
	endDate:objDate
	metadata:metaData];


	[self.healthStore saveObject:foodItemSample withCompletion:^(BOOL success, NSError *error){
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[HKHealthStore isHealthDataAvailable]];
		if(success){
			result = @"saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}else{
			result = @"not saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}
	}];
}

- (void) saveFoodItemVitaminK:(CDVInvokedUrlCommand*)command {
	NSMutableDictionary *args = [command.arguments objectAtIndex:0];
	NSString *foodName = [args objectForKey:@"foodName"];
    NSString *foodValue = [args objectForKey:@"foodValue"];

    double unitDouble = [foodValue doubleValue];

	HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryVitaminK];
	HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];

	NSDate *objDate = [NSDate date];
	NSDictionary *metaData = @{HKMetadataKeyFoodType:foodName};

	HKQuantitySample *foodItemSample =
	[HKQuantitySample quantitySampleWithType:quantityType
	quantity:quantity
	startDate:objDate
	endDate:objDate
	metadata:metaData];


	[self.healthStore saveObject:foodItemSample withCompletion:^(BOOL success, NSError *error){
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[HKHealthStore isHealthDataAvailable]];
		if(success){
			result = @"saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}else{
			result = @"not saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}
	}];
}

- (void) saveFoodItemZinc:(CDVInvokedUrlCommand*)command {
	NSMutableDictionary *args = [command.arguments objectAtIndex:0];
	NSString *foodName = [args objectForKey:@"foodName"];
    NSString *foodValue = [args objectForKey:@"foodValue"];

    double unitDouble = [foodValue doubleValue];

	HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryZinc];
	HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];

	NSDate *objDate = [NSDate date];
	NSDictionary *metaData = @{HKMetadataKeyFoodType:foodName};

	HKQuantitySample *foodItemSample =
	[HKQuantitySample quantitySampleWithType:quantityType
	quantity:quantity
	startDate:objDate
	endDate:objDate
	metadata:metaData];


	[self.healthStore saveObject:foodItemSample withCompletion:^(BOOL success, NSError *error){
		CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[HKHealthStore isHealthDataAvailable]];
		if(success){
			result = @"saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}else{
			result = @"not saved";
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}
	}];
}

- (void) requestAuthorization:(CDVInvokedUrlCommand*)command {
  NSMutableDictionary *args = [command.arguments objectAtIndex:0];
  
  // read types
  NSArray *readTypes = [args objectForKey:HKPluginKeyReadTypes];
  NSSet *readDataTypes = [[NSSet alloc] init];
  for (int i=0; i<[readTypes count]; i++) {
    NSString *elem = [readTypes objectAtIndex:i];
    HKObjectType *type = [self getHKObjectType:elem];
    if (type == nil) {
      CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"readTypes contains an invalid value"];
      [result setKeepCallbackAsBool:YES];
      [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
      // not returning deliberately to be future proof; other permissions are still asked
    } else {
      readDataTypes = [readDataTypes setByAddingObject:type];
    }
  }
  
  // write types
  NSArray *writeTypes = [args objectForKey:HKPluginKeyWriteTypes];
  NSSet *writeDataTypes = [[NSSet alloc] init];
  for (int i=0; i<[writeTypes count]; i++) {
    NSString *elem = [writeTypes objectAtIndex:i];
    HKObjectType *type = [self getHKObjectType:elem];
    if (type == nil) {
      CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"writeTypes contains an invalid value"];
      [result setKeepCallbackAsBool:YES];
      [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
      // not returning deliberately to be future proof; other permissions are still asked
    } else {
      writeDataTypes = [writeDataTypes setByAddingObject:type];
    }
  }
  
  [self.healthStore requestAuthorizationToShareTypes:writeDataTypes readTypes:readDataTypes completion:^(BOOL success, NSError *error) {
    if (success) {
      dispatch_sync(dispatch_get_main_queue(), ^{
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
      });
    } else {
      dispatch_sync(dispatch_get_main_queue(), ^{
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
      });
    }
  }];
}

#pragma mark - helper methods
- (HKUnit*) getUnit:(NSString*) type : (NSString*) expected {
  HKUnit *localUnit;
  @try {
    localUnit = [HKUnit unitFromString:type];
    if ([[[localUnit class] description] isEqualToString:expected]) {
      return localUnit;
    } else {
      return nil;
    }
  }
  @catch(NSException *e) {
    return nil;
  }
}

- (HKObjectType*) getHKObjectType:(NSString*) elem {
  HKObjectType *type = [HKObjectType quantityTypeForIdentifier:elem];
  if (type == nil) {
    type = [HKObjectType characteristicTypeForIdentifier:elem];
  }
  if (type == nil){
    type = [self getHKSampleType:elem];
  }
  return type;
}

- (HKQuantityType*) getHKQuantityType:(NSString*) elem {
  HKQuantityType *type = [HKQuantityType quantityTypeForIdentifier:elem];
  return type;
}

- (HKSampleType*) getHKSampleType:(NSString*) elem {
  HKSampleType *type = [HKObjectType quantityTypeForIdentifier:elem];
  if (type == nil) {
    type = [HKObjectType categoryTypeForIdentifier:elem];
  }
  if (type == nil) {
    type = [HKObjectType quantityTypeForIdentifier:elem];
  }
  if (type == nil) {
    type = [HKObjectType correlationTypeForIdentifier:elem];
  }
  if (type == nil && [elem isEqualToString:@"workoutType"]) {
    type = [HKObjectType workoutType];
  }
  return type;
}

//Helper to parse out a quantity sample from a dictionary and perform error checking
- (HKQuantitySample*) loadHKQuantitySampleFromInputDictionary:(NSDictionary*) inputDictionary error:(NSError**) error {
  //Load quantity sample from args to command
  if (![self inputDictionary:inputDictionary hasRequiredKey:HKPluginKeyStartDate error:error]) return nil;
  NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:[[inputDictionary objectForKey:HKPluginKeyStartDate] longValue]];
  
  if (![self inputDictionary:inputDictionary hasRequiredKey:HKPluginKeyEndDate error:error]) return nil;
  NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:[[inputDictionary objectForKey:HKPluginKeyEndDate] longValue]];
  
  if (![self inputDictionary:inputDictionary hasRequiredKey:HKPluginKeySampleType error:error]) return nil;
  NSString *sampleTypeString = [inputDictionary objectForKey:HKPluginKeySampleType];
  
  if (![self inputDictionary:inputDictionary hasRequiredKey:HKPluginKeyUnit error:error]) return nil;
  NSString *unitString = [inputDictionary objectForKey:HKPluginKeyUnit];
  
  if (![self inputDictionary:inputDictionary hasRequiredKey:HKPluginKeyAmount error:error]) return nil;
  double value = [[inputDictionary objectForKey:HKPluginKeyAmount] doubleValue];
  
  //Load optional metadata key
  NSDictionary* metadata = [inputDictionary objectForKey:HKPluginKeyMetadata];
  if (metadata == nil)
    metadata = @{};
  
  return [self getHKQuantitySampleWithStartDate:startDate endDate:endDate sampleTypeString:sampleTypeString unitTypeString:unitString value:value metadata:metadata error:error];
}

//Helper to parse out a correlation from a dictionary and perform error checking
- (HKCorrelation*) loadHKCorrelationFromInputDictionary:(NSDictionary*) inputDictionary error:(NSError**) error {
  //Load correlation from args to command
  if (![self inputDictionary:inputDictionary hasRequiredKey:HKPluginKeyStartDate error:error]) return nil;
  NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:[[inputDictionary objectForKey:HKPluginKeyStartDate] longValue]];
  
  if (![self inputDictionary:inputDictionary hasRequiredKey:HKPluginKeyEndDate error:error]) return nil;
  NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:[[inputDictionary objectForKey:HKPluginKeyEndDate] longValue]];
  
  if (![self inputDictionary:inputDictionary hasRequiredKey:HKPluginKeyCorrelationType error:error]) return nil;
  NSString *correlationTypeString = [inputDictionary objectForKey:HKPluginKeyCorrelationType];
  
  if (![self inputDictionary:inputDictionary hasRequiredKey:HKPluginKeyObjects error:error]) return nil;
  NSArray* objectDictionaries = [inputDictionary objectForKey:HKPluginKeyObjects];
  
  NSMutableSet* objects = [NSMutableSet set];
  for (NSDictionary* objectDictionary in objectDictionaries) {
    HKQuantitySample* sample = [self loadHKQuantitySampleFromInputDictionary:objectDictionary error:error];
    if (sample == nil)
      return nil;
    [objects addObject:sample];
  }
  NSDictionary *metadata = [inputDictionary objectForKey:HKPluginKeyMetadata];
  if (metadata == nil)
    metadata = @{};
  return [self getHKCorrelationWithStartDate:startDate endDate:endDate correlationTypeString:correlationTypeString objects:objects metadata:metadata error:error];
}

//Helper to isolate error checking on inputs for plugin
-(BOOL) inputDictionary:(NSDictionary*) inputDictionary hasRequiredKey:(NSString*) key error:(NSError**) error {
  if ([inputDictionary objectForKey:key] == nil) {
    *error = [NSError errorWithDomain:HKPluginError code:0 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"required value -%@- was missing from dictionary %@",key,[inputDictionary description]]}];
    return false;
  }
  return true;
}

// Helper to handle the functionality with HealthKit to get a quantity sample
- (HKQuantitySample*) getHKQuantitySampleWithStartDate:(NSDate*) startDate endDate:(NSDate*) endDate sampleTypeString:(NSString*) sampleTypeString unitTypeString:(NSString*) unitTypeString value:(double) value metadata:(NSDictionary*) metadata error:(NSError**) error {
  HKQuantityType *type = [self getHKQuantityType:sampleTypeString];
  if (type==nil) {
    *error = [NSError errorWithDomain:HKPluginError code:0 userInfo:@{NSLocalizedDescriptionKey:@"quantity type string was invalid"}];
    return nil;
  }
  HKUnit *unit;
  @try {
    unit = unitTypeString!=nil ? [HKUnit unitFromString:unitTypeString] : nil;
    if (unit==nil) {
      *error = [NSError errorWithDomain:HKPluginError code:0 userInfo:@{NSLocalizedDescriptionKey:@"unit was invalid"}];
      return nil;
    }
  }
  @catch(NSException *e) {
    *error = [NSError errorWithDomain:HKPluginError code:0 userInfo:@{NSLocalizedDescriptionKey:@"unit was invalid"}];
    return nil;
  }
  HKQuantity *quantity = [HKQuantity quantityWithUnit:unit doubleValue:value];
  if (![quantity isCompatibleWithUnit:unit]) {
    *error = [NSError errorWithDomain:HKPluginError code:0 userInfo:@{NSLocalizedDescriptionKey:@"unit was not compatible with quantity"}];
    return nil;
  }
  
  return [HKQuantitySample quantitySampleWithType:type quantity:quantity startDate:startDate endDate:endDate metadata:metadata];
}

- (HKCorrelation*) getHKCorrelationWithStartDate:(NSDate*) startDate endDate:(NSDate*) endDate correlationTypeString:(NSString*) correlationTypeString objects:(NSSet*) objects metadata:(NSDictionary*) metadata error:(NSError**) error {
  NSLog(@"correlation type is %@",HKCorrelationTypeIdentifierBloodPressure);
  HKCorrelationType *correlationType = [HKCorrelationType correlationTypeForIdentifier:correlationTypeString];
  if (correlationType == nil) {
    *error = [NSError errorWithDomain:HKPluginError code:0 userInfo:@{NSLocalizedDescriptionKey:@"correlation type string was invalid"}];
    return nil;
  }
  return [HKCorrelation correlationWithType:correlationType startDate:startDate endDate:endDate objects:objects metadata:metadata];
}

@end