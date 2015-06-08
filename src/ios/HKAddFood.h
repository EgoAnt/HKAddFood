#import <Cordova/CDV.h>
#import <HealthKit/HealthKit.h>

@interface HKAddFood :CDVPlugin

@property (nonatomic) HKHealthStore *healthStore;

- (void) available:(CDVInvokedUrlCommand*)command;
- (void) checkAuthStatus:(CDVInvokedUrlCommand*)command;
- (void) requestAuthorization:(CDVInvokedUrlCommand*)command;
- (void) saveFoodItemCalories:(CDVInvokedUrlCommand*)command;
- (void) saveFoodItemBiotin:(CDVInvokedUrlCommand*)command;
- (void) saveFoodItemCaffeine:(CDVInvokedUrlCommand*)command;
- (void) saveFoodItemCalcium:(CDVInvokedUrlCommand*)command;
- (void) saveFoodItemCarbohydrates:(CDVInvokedUrlCommand*)command;
- (void) saveFoodItemChloride:(CDVInvokedUrlCommand*)command;
- (void) saveFoodItemCholesterol:(CDVInvokedUrlCommand*)command;
- (void) saveFoodItemChromium:(CDVInvokedUrlCommand*)command;
- (void) saveFoodItemCopper:(CDVInvokedUrlCommand*)command;
- (void) saveFoodItemEnergyConsumed:(CDVInvokedUrlCommand*)command;
- (void) saveFoodItemFatMonounsaturated:(CDVInvokedUrlCommand*)command;
- (void) saveFoodItemFatPolyunsaturated:(CDVInvokedUrlCommand*)command;
- (void) saveFoodItemFatSaturated:(CDVInvokedUrlCommand*)command;
- (void) saveFoodItemFatTotal:(CDVInvokedUrlCommand*)command;
- (void) saveFoodItemFiber:(CDVInvokedUrlCommand*)command;
- (void) saveFoodItemFolate:(CDVInvokedUrlCommand*)command;
- (void) saveFoodItemIodine:(CDVInvokedUrlCommand*)command;
- (void) saveFoodItemIron:(CDVInvokedUrlCommand*)command;
- (void) saveFoodItemMagnesium:(CDVInvokedUrlCommand*)command;
- (void) saveFoodItemManganese:(CDVInvokedUrlCommand*)command;
- (void) saveFoodItemMolybdenum:(CDVInvokedUrlCommand*)command;
- (void) saveFoodItemNiacin:(CDVInvokedUrlCommand*)command;
- (void) saveFoodItemPantothenicAcid:(CDVInvokedUrlCommand*)command;
- (void) saveFoodItemPhosphorus:(CDVInvokedUrlCommand*)command;
- (void) saveFoodItemPotassium:(CDVInvokedUrlCommand*)command;
- (void) saveFoodItemProtein:(CDVInvokedUrlCommand*)command;
- (void) saveFoodItemRiboflavin:(CDVInvokedUrlCommand*)command;
- (void) saveFoodItemSelenium:(CDVInvokedUrlCommand*)command;
- (void) saveFoodItemSodium:(CDVInvokedUrlCommand*)command;
- (void) saveFoodItemSugar:(CDVInvokedUrlCommand*)command;
- (void) saveFoodItemThiamin:(CDVInvokedUrlCommand*)command;
- (void) saveFoodItemVitaminA:(CDVInvokedUrlCommand*)command;
- (void) saveFoodItemVitaminB12:(CDVInvokedUrlCommand*)command;
- (void) saveFoodItemVitaminB6:(CDVInvokedUrlCommand*)command;
- (void) saveFoodItemVitaminC:(CDVInvokedUrlCommand*)command;
- (void) saveFoodItemVitaminD:(CDVInvokedUrlCommand*)command;
- (void) saveFoodItemVitaminE:(CDVInvokedUrlCommand*)command;
- (void) saveFoodItemVitaminK:(CDVInvokedUrlCommand*)command;
- (void) saveFoodItemZinc:(CDVInvokedUrlCommand*)command;

@end