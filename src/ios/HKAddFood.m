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
	double foodCalories = [[args objectForKey:@"foodCalories"] doubleValue];
	double foodBiotin = [[args objectForKey:@"foodBiotin"] doubleValue];
	double foodCaffeine = [[args objectForKey:@"foodCaffeine"] doubleValue];
	double foodCalcium = [[args objectForKey:@"foodCalcium"] doubleValue];
	double foodCarbohydrates = [[args objectForKey:@"foodCarbohydrates"] doubleValue];
	double foodChloride = [[args objectForKey:@"foodChloride"] doubleValue];
	double foodCholesterol = [[args objectForKey:@"foodCholesterol"] doubleValue];
	double foodChromium = [[args objectForKey:@"foodChromium"] doubleValue];
	double foodCopper = [[args objectForKey:@"foodCopper"] doubleValue];
	double foodFatMonounsaturated = [[args objectForKey:@"foodFatMonounsaturated"] doubleValue];
	double foodFatPolyunsaturated = [[args objectForKey:@"foodFatPolyunsaturated"] doubleValue];
	double foodFatSaturated = [[args objectForKey:@"foodFatSaturated"] doubleValue];
	double foodFatTotal = [[args objectForKey:@"foodFatTotal"] doubleValue];
	double foodFiber = [[args objectForKey:@"foodFiber"] doubleValue];
	double foodFolate = [[args objectForKey:@"foodFolate"] doubleValue];
	double foodIodine = [[args objectForKey:@"foodIodine"] doubleValue];
	double foodIron = [[args objectForKey:@"foodIron"] doubleValue];
	double foodMagnesium = [[args objectForKey:@"foodMagnesium"] doubleValue];
	double foodManganese = [[args objectForKey:@"foodManganese"] doubleValue];
	double foodMolybdenum = [[args objectForKey:@"foodMolybdenum"] doubleValue];
	double foodNiacin = [[args objectForKey:@"foodNiacin"] doubleValue];
	double foodPantothenicAcid = [[args objectForKey:@"foodPantothenicAcid"] doubleValue];
	double foodPhosphorus = [[args objectForKey:@"foodPhosphorus"] doubleValue];
	double foodPotassium = [[args objectForKey:@"foodPotassium"] doubleValue];
	double foodProtein = [[args objectForKey:@"foodProtein"] doubleValue];
	double foodRiboflavin = [[args objectForKey:@"foodRiboflavin"] doubleValue];
	double foodSelenium = [[args objectForKey:@"foodSelenium"] doubleValue];
	double foodSodium = [[args objectForKey:@"foodSodium"] doubleValue];
	double foodSugar = [[args objectForKey:@"foodSugar"] doubleValue];
	double foodThiamin = [[args objectForKey:@"foodThiamin"] doubleValue];
	double foodVitaminA = [[args objectForKey:@"foodVitaminA"] doubleValue];
	double foodVitaminB12 = [[args objectForKey:@"foodVitaminB12"] doubleValue];
	double foodVitaminB6 = [[args objectForKey:@"foodVitaminB6"] doubleValue];
	double foodVitaminC = [[args objectForKey:@"foodVitaminC"] doubleValue];
	double foodVitaminD = [[args objectForKey:@"foodVitaminD"] doubleValue];
	double foodVitaminE = [[args objectForKey:@"foodVitaminE"] doubleValue];
	double foodVitaminK = [[args objectForKey:@"foodVitaminK"] doubleValue];
	double foodZinc = [[args objectForKey:@"foodZinc"] doubleValue];

    NSSet* nutritionTypes = [NSSet setWithObjects:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed],
                    [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCarbohydrates],
                    [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryFatTotal],
                    [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryProtein],
                    nil];

        NSDate* timeFoodWasConsumed = [NSDate date];
        NSDictionary *metadata = @{
                HKMetadataKeyFoodType:foodName,
                @"HKFoodBrandName":@"Prime Dining", // Restaurant name or packaged food brand name
        };
		
        HKQuantitySample* Calories = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed]
                                                                 quantity:[HKQuantity quantityWithUnit:[HKUnit kilocalorieUnit] doubleValue:foodCalories]
                                                                startDate:timeFoodWasConsumed
                                                                  endDate:timeFoodWasConsumed
                                                                 metadata:metadata];
        
		HKQuantitySample* Biotin = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryBiotin] quantity:[HKQuantity quantityWithUnit:[HKUnit gramUnitWithMetricPrefix:HKMetricPrefixMicro] doubleValue:foodBiotin] startDate:timeFoodWasConsumed endDate:timeFoodWasConsumed metadata:metadata];
		HKQuantitySample* Caffeine = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryBiotin] quantity:[HKQuantity quantityWithUnit:[HKUnit gramUnitWithMetricPrefix:HKMetricPrefixMilli] doubleValue:foodCaffeine] startDate:timeFoodWasConsumed endDate:timeFoodWasConsumed metadata:metadata];
		HKQuantitySample* Calcium = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryBiotin] quantity:[HKQuantity quantityWithUnit:[HKUnit gramUnitWithMetricPrefix:HKMetricPrefixMilli] doubleValue:foodCalcium] startDate:timeFoodWasConsumed endDate:timeFoodWasConsumed metadata:metadata];
		HKQuantitySample* Carbohydrates = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryBiotin] quantity:[HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:foodCarbohydrates] startDate:timeFoodWasConsumed endDate:timeFoodWasConsumed metadata:metadata];
		HKQuantitySample* Chloride = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryBiotin] quantity:[HKQuantity quantityWithUnit:[HKUnit gramUnitWithMetricPrefix:HKMetricPrefixMilli] doubleValue:foodChloride] startDate:timeFoodWasConsumed endDate:timeFoodWasConsumed metadata:metadata];
		HKQuantitySample* Cholesterol = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryBiotin] quantity:[HKQuantity quantityWithUnit:[HKUnit gramUnitWithMetricPrefix:HKMetricPrefixMilli] doubleValue:foodCholesterol] startDate:timeFoodWasConsumed endDate:timeFoodWasConsumed metadata:metadata];
		HKQuantitySample* Chromium = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryBiotin] quantity:[HKQuantity quantityWithUnit:[HKUnit gramUnitWithMetricPrefix:HKMetricPrefixMicro] doubleValue:foodChromium] startDate:timeFoodWasConsumed endDate:timeFoodWasConsumed metadata:metadata];
		HKQuantitySample* Copper = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryBiotin] quantity:[HKQuantity quantityWithUnit:[HKUnit gramUnitWithMetricPrefix:HKMetricPrefixMilli] doubleValue:foodCopper] startDate:timeFoodWasConsumed endDate:timeFoodWasConsumed metadata:metadata];
		HKQuantitySample* FatMonounsaturated = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryBiotin] quantity:[HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:foodFatMonounsaturated] startDate:timeFoodWasConsumed endDate:timeFoodWasConsumed metadata:metadata];
		HKQuantitySample* FatPolyunsaturated = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryBiotin] quantity:[HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:foodFatPolyunsaturated] startDate:timeFoodWasConsumed endDate:timeFoodWasConsumed metadata:metadata];
		HKQuantitySample* FatSaturated = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryBiotin] quantity:[HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:foodFatSaturated] startDate:timeFoodWasConsumed endDate:timeFoodWasConsumed metadata:metadata];
		HKQuantitySample* FatTotal = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryBiotin] quantity:[HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:foodFatTotal] startDate:timeFoodWasConsumed endDate:timeFoodWasConsumed metadata:metadata];
		HKQuantitySample* Fiber = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryBiotin] quantity:[HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:foodFiber] startDate:timeFoodWasConsumed endDate:timeFoodWasConsumed metadata:metadata];
		HKQuantitySample* Folate = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryBiotin] quantity:[HKQuantity quantityWithUnit:[HKUnit gramUnitWithMetricPrefix:HKMetricPrefixMicro] doubleValue:foodFolate] startDate:timeFoodWasConsumed endDate:timeFoodWasConsumed metadata:metadata];
		HKQuantitySample* Iodine = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryBiotin] quantity:[HKQuantity quantityWithUnit:[HKUnit gramUnitWithMetricPrefix:HKMetricPrefixMicro] doubleValue:foodIodine] startDate:timeFoodWasConsumed endDate:timeFoodWasConsumed metadata:metadata];
		HKQuantitySample* Iron = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryBiotin] quantity:[HKQuantity quantityWithUnit:[HKUnit gramUnitWithMetricPrefix:HKMetricPrefixMilli] doubleValue:foodIron] startDate:timeFoodWasConsumed endDate:timeFoodWasConsumed metadata:metadata];
		HKQuantitySample* Magnesium = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryBiotin] quantity:[HKQuantity quantityWithUnit:[HKUnit gramUnitWithMetricPrefix:HKMetricPrefixMilli] doubleValue:foodMagnesium] startDate:timeFoodWasConsumed endDate:timeFoodWasConsumed metadata:metadata];
		HKQuantitySample* Manganese = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryBiotin] quantity:[HKQuantity quantityWithUnit:[HKUnit gramUnitWithMetricPrefix:HKMetricPrefixMilli] doubleValue:foodManganese] startDate:timeFoodWasConsumed endDate:timeFoodWasConsumed metadata:metadata];
		HKQuantitySample* Molybdenum = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryBiotin] quantity:[HKQuantity quantityWithUnit:[HKUnit gramUnitWithMetricPrefix:HKMetricPrefixMicro] doubleValue:foodMolybdenum] startDate:timeFoodWasConsumed endDate:timeFoodWasConsumed metadata:metadata];
		HKQuantitySample* Niacin = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryBiotin] quantity:[HKQuantity quantityWithUnit:[HKUnit gramUnitWithMetricPrefix:HKMetricPrefixMilli] doubleValue:foodNiacin] startDate:timeFoodWasConsumed endDate:timeFoodWasConsumed metadata:metadata];
		HKQuantitySample* PantothenicAcid = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryBiotin] quantity:[HKQuantity quantityWithUnit:[HKUnit gramUnitWithMetricPrefix:HKMetricPrefixMilli] doubleValue:foodPantothenicAcid] startDate:timeFoodWasConsumed endDate:timeFoodWasConsumed metadata:metadata];
		HKQuantitySample* Phosphorus = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryBiotin] quantity:[HKQuantity quantityWithUnit:[HKUnit gramUnitWithMetricPrefix:HKMetricPrefixMilli] doubleValue:foodPhosphorus] startDate:timeFoodWasConsumed endDate:timeFoodWasConsumed metadata:metadata];
		HKQuantitySample* Potassium = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryBiotin] quantity:[HKQuantity quantityWithUnit:[HKUnit gramUnitWithMetricPrefix:HKMetricPrefixMilli] doubleValue:foodPotassium] startDate:timeFoodWasConsumed endDate:timeFoodWasConsumed metadata:metadata];
		HKQuantitySample* Protein = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryBiotin] quantity:[HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:foodProtein] startDate:timeFoodWasConsumed endDate:timeFoodWasConsumed metadata:metadata];
		HKQuantitySample* Riboflavin = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryBiotin] quantity:[HKQuantity quantityWithUnit:[HKUnit gramUnitWithMetricPrefix:HKMetricPrefixMilli] doubleValue:foodRiboflavin] startDate:timeFoodWasConsumed endDate:timeFoodWasConsumed metadata:metadata];
		HKQuantitySample* Selenium = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryBiotin] quantity:[HKQuantity quantityWithUnit:[HKUnit gramUnitWithMetricPrefix:HKMetricPrefixMicro] doubleValue:foodSelenium] startDate:timeFoodWasConsumed endDate:timeFoodWasConsumed metadata:metadata];
		HKQuantitySample* Sodium = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryBiotin] quantity:[HKQuantity quantityWithUnit:[HKUnit gramUnitWithMetricPrefix:HKMetricPrefixMilli] doubleValue:foodSodium] startDate:timeFoodWasConsumed endDate:timeFoodWasConsumed metadata:metadata];
		HKQuantitySample* Sugar = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryBiotin] quantity:[HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:foodSugar] startDate:timeFoodWasConsumed endDate:timeFoodWasConsumed metadata:metadata];
		HKQuantitySample* Thiamin = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryBiotin] quantity:[HKQuantity quantityWithUnit:[HKUnit gramUnitWithMetricPrefix:HKMetricPrefixMilli] doubleValue:foodThiamin] startDate:timeFoodWasConsumed endDate:timeFoodWasConsumed metadata:metadata];
		HKQuantitySample* VitaminA = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryBiotin] quantity:[HKQuantity quantityWithUnit:[HKUnit gramUnitWithMetricPrefix:HKMetricPrefixMicro] doubleValue:foodVitaminA] startDate:timeFoodWasConsumed endDate:timeFoodWasConsumed metadata:metadata];
		HKQuantitySample* VitaminB12 = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryBiotin] quantity:[HKQuantity quantityWithUnit:[HKUnit gramUnitWithMetricPrefix:HKMetricPrefixMicro] doubleValue:foodVitaminB12] startDate:timeFoodWasConsumed endDate:timeFoodWasConsumed metadata:metadata];
		HKQuantitySample* VitaminB6 = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryBiotin] quantity:[HKQuantity quantityWithUnit:[HKUnit gramUnitWithMetricPrefix:HKMetricPrefixMicro] doubleValue:foodVitaminB6] startDate:timeFoodWasConsumed endDate:timeFoodWasConsumed metadata:metadata];
		HKQuantitySample* VitaminC = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryBiotin] quantity:[HKQuantity quantityWithUnit:[HKUnit gramUnitWithMetricPrefix:HKMetricPrefixMilli] doubleValue:foodVitaminC] startDate:timeFoodWasConsumed endDate:timeFoodWasConsumed metadata:metadata];
		HKQuantitySample* VitaminD = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryBiotin] quantity:[HKQuantity quantityWithUnit:[HKUnit gramUnitWithMetricPrefix:HKMetricPrefixMicro] doubleValue:foodVitaminD] startDate:timeFoodWasConsumed endDate:timeFoodWasConsumed metadata:metadata];
		HKQuantitySample* VitaminE = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryBiotin] quantity:[HKQuantity quantityWithUnit:[HKUnit gramUnitWithMetricPrefix:HKMetricPrefixMilli] doubleValue:foodVitaminE] startDate:timeFoodWasConsumed endDate:timeFoodWasConsumed metadata:metadata];
		HKQuantitySample* VitaminK = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryBiotin] quantity:[HKQuantity quantityWithUnit:[HKUnit gramUnitWithMetricPrefix:HKMetricPrefixMicro] doubleValue:foodVitaminK] startDate:timeFoodWasConsumed endDate:timeFoodWasConsumed metadata:metadata];
		HKQuantitySample* Zinc = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryBiotin] quantity:[HKQuantity quantityWithUnit:[HKUnit gramUnitWithMetricPrefix:HKMetricPrefixMilli] doubleValue:foodZinc] startDate:timeFoodWasConsumed endDate:timeFoodWasConsumed metadata:metadata];

        HKCorrelation* food = [HKCorrelation correlationWithType:[HKCorrelationType correlationTypeForIdentifier:HKCorrelationTypeIdentifierFood]
                                                              startDate:timeFoodWasConsumed
                                                                endDate:timeFoodWasConsumed
                                                                objects:[NSSet setWithObjects:Calories,Biotin,Caffeine,Calcium,Carbohydrates,Chloride,Cholesterol,Chromium,Copper,EnergyConsumed,FatMonounsaturated,FatPolyunsaturated,FatSaturated,FatTotal,Fiber,Folate,Iodine,Iron,Magnesium,Manganese,Molybdenum,Niacin,PantothenicAcid,Phosphorus,Potassium,Protein,Riboflavin,Selenium,Sodium,Sugar,Thiamin,VitaminA,VitaminB12,VitaminB6,VitaminC,VitaminD,VitaminE,VitaminK,Zinc,nil]
                                                               metadata:metadata];

        [self.healthStore saveObject:food withCompletion:^(BOOL success, NSError *error) {
            if (success) {
				CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfully wrote a food to HealthKit"];
				[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            } else {
				CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Failed to write food to HealthKit"];
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