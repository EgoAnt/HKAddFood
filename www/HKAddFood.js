cordova.define("com.egoant.plugins.hkaddfood.HKAddFood", function(require, exports, module) { function HKAddFood() {
}

HKAddFood.prototype.available = function (successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "HKAddFood", "available", []);
};

 HKAddFood.prototype.requestAuthorization = function (options, successCallback, errorCallback) {
     cordova.exec(successCallback, errorCallback, "HKAddFood", "requestAuthorization", [options]);
};
                                                                                             
                                                                                             HKAddFood.install = function () {
     if (!window.plugins) {
         window.plugins = {};
     }

                                                                                                 window.plugins.healthkit = new HKAddFood();
     return window.plugins.healthkit;
 };

                                                                                             cordova.addConstructor(HKAddFood.install);

});