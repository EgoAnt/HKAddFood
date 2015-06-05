HKAddFood.prototype.available = function (successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "HKAddFood", "available", []);
};

HKAddFood.prototype.checkAuthStatus = function (options, successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "HKAddFood", "checkAuthStatus", [options]);
};

 HKAddFood.prototype.requestAuthorization = function (options, successCallback, errorCallback) {
     cordova.exec(successCallback, errorCallback, "HKAddFood", "requestAuthorization", [options]);
};