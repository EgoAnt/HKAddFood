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
    NSString *foodValue = [args objectForKey:@"foodValue"];
    NSString *foodUnit = [args objectForKey:@"foodUnit"];

    double unitDouble = [foodValue doubleValue];

	HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit kiloCalorieUnit] doubleValue:unitDouble];
	HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
	
	if(foodUnit == "Biotin"){
		quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];
		quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryBiotin];
	}else if(foodUnit == "Caffeine"){
		quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];
		quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCaffeine];
	}else if(foodUnit == "Calcium"){
		quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];
		quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCalcium];
	}else if(foodUnit == "Carbohydrates"){
		quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];
		quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCarbohydrates];
	}else if(foodUnit == "Chloride"){
		quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];
		quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryChloride];
	}else if(foodUnit == "Cholesterol"){
		quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];
		quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCholesterol];
	}else if(foodUnit == "Chromium"){
		quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];
		quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryChromium];
	}else if(foodUnit == "Copper"){
		quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];
		quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCopper];
	}else if(foodUnit == "EnergyConsumed"){
		quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];
		quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
	}else if(foodUnit == "FatMonounsaturated"){
		quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];
		quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryFatMonounsaturated];
	}else if(foodUnit == "FatPolyunsaturated"){
		quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];
		quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryFatPolyunsaturated];
	}else if(foodUnit == "FatSaturated"){
		quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];
		quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryFatSaturated];
	}else if(foodUnit == "FatTotal"){
		quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];
		quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryFatTotal];
	}else if(foodUnit == "Fiber"){
		quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];
		quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryFiber];
	}else if(foodUnit == "Folate"){
		quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];
		quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryFolate];
	}else if(foodUnit == "Iodine"){
		quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];
		quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryIodine];
	}else if(foodUnit == "Iron"){
		quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];
		quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryIron];
	}else if(foodUnit == "Magnesium"){
		quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];
		quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryMagnesium];
	}else if(foodUnit == "Manganese"){
		quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];
		quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryManganese];
	}else if(foodUnit == "Molybdenum"){
		quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];
		quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryMolybdenum];
	}else if(foodUnit == "Niacin"){
		quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];
		quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryNiacin];
	}else if(foodUnit == "PantothenicAcid"){
		quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];
		quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryPantothenicAcid];
	}else if(foodUnit == "Phosphorus"){
		quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];
		quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryPhosphorus];
	}else if(foodUnit == "Potassium"){
		quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];
		quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryPotassium];
	}else if(foodUnit == "Protein"){
		quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];
		quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryProtein];
	}else if(foodUnit == "Riboflavin"){
		quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];
		quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryRiboflavin];
	}else if(foodUnit == "Selenium"){
		quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];
		quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietarySelenium];
	}else if(foodUnit == "Sodium"){
		quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];
		quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietarySodium];
	}else if(foodUnit == "Sugar"){
		quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];
		quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietarySugar];
	}else if(foodUnit == "Thiamin"){
		quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];
		quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryThiamin];
	}else if(foodUnit == "VitaminA"){
		quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];
		quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryVitaminA];
	}else if(foodUnit == "VitaminB12"){
		quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];
		quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryVitaminB12];
	}else if(foodUnit == "VitaminB6"){
		quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];
		quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryVitaminB6];
	}else if(foodUnit == "VitaminC"){
		quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];
		quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryVitaminC];
	}else if(foodUnit == "VitaminD"){
		quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];
		quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryVitaminD];
	}else if(foodUnit == "VitaminE"){
		quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];
		quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryVitaminE];
	}else if(foodUnit == "VitaminK"){
		quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];
		quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryVitaminK];
	}else if(foodUnit == "Zinc"){
		quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:unitDouble];
		quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryZinc];
	}

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