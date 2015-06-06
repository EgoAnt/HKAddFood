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
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Saved food item"];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}else{
			CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Error saving food item"];
			[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		}
	}]
}

- (void) requestAuthorization:(CDVInvokedUrlCommand*)command {
	NSMutableDictionary *args = [command.arguments objectAtIndex:0];
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

    return type;
}
@end