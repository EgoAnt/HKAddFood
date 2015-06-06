var HKAddFood = function() {

};

HKAddFood.prototype.available = function (successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "HKAddFood", "available", []);
};

HKAddFood.prototype.checkAuthStatus = function (options, successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "HKAddFood", "checkAuthStatus", [options]);
};

 HKAddFood.prototype.requestAuthorization = function (options, successCallback, errorCallback) {
     cordova.exec(successCallback, errorCallback, "HKAddFood", "requestAuthorization", [options]);
};

HKAddFood.prototype.saveFoodItem = function (options, successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "HKAddFood", "saveFoodItem", [options]);
};

window.hkaddfood = new HKAddFood();