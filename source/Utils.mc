using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.System;
using Toybox.WatchUi;
import Toybox.Attention;
import Toybox.Lang;

module Utils {
    function _t(resource as Lang.ResourceId) {
        return WatchUi.loadResource(resource);
    }

    function min(a as Number, b as Number) {
        return a < b ? a : b;
    }

    function joinArray(arr as Array?, sep as Lang.String) as String {
        var out = "";
        if (arr == null) {
            return out;
        }

        for (var i = 0; i < arr.size(); i += 1) {
            if (i > 0) {
                out += sep;
            }
            out += arr[i];
        }
        return out;
    }

    function concatenateArray(arrays as Array<Array?>?) as Array {
        var result = [] as Array;

        if (arrays == null) {
            return result;
        }

        for (var i = 0; i < arrays.size(); i += 1) {
            var arr = arrays[i];
            if (arr != null) {
                for (var j = 0; j < arr.size(); j += 1) {
                    result.add(arr[j]);
                }
            }
        }

        return result;
    }

    function containsArray(arr as Array?, value as Number) as Boolean {
        if (arr == null) {
            return false;
        }
        for (var i = 0; i < arr.size(); i += 1) {
            if (arr[i] == value) {
                return true;
            }
        }
        return false;
    }

    function indexOfArray(arr as Array?, value as Number) as Number {
        if (arr == null) {
            return -1;
        }
        for (var i = 0; i < arr.size(); i += 1) {
            var v = arr[i];
            if (v == value) {
                return i;
            }
        }
        return -1;
    }

    // Function to turn on the backlight with a safe fallback
    function turnOnBacklight(maxPower as Float, level as Number) as Void {
        // Prepare three brightness levels
        var intensityArray = [
            maxPower / 3.0, // low intensity (1/3 power)
            (maxPower * 2.0) / 3.0, // medium intensity (2/3 power)
            maxPower, // high intensity (full power)
        ];

        var failed = false;

        // Try the "newer" method first (with brightness levels)
        try {
            // level is the index 0, 1, or 2 → pick intensity from array
            Attention.backlight(intensityArray[level]);
        } catch (e) {
            // If device doesn't support brightness values, mark as failed
            failed = true;
        }

        // If the first attempt failed → use the older method (just ON/OFF)
        if (failed) {
            try {
                Attention.backlight(true); // turn on with default brightness
            } catch (e) {
                // If this fails too, ignore it → app must not crash
            }
        }
    }
}
