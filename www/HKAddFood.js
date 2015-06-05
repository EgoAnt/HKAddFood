window.HKAddFood = function(foodObj, callback) {
    cordova.exec(callback, function(err) {
        callback(err.message);
    }, "HKAddFood", "hkaddfood", foodObj);
};