using Toybox.System as Sys;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Lang;

class BmcQrView extends Ui.View {
    var _bmp;
    var _bmpSize;
    var _x, _y;

    const TOP_PAD = 24;
    const BOTTOM_PAD = 24;

    function initialize() {
        View.initialize();
    }

    function pickQrId(maxSize as Lang.Float) {
        var opts = [
            { :size => 256.0, :id => Rez.Drawables.img_bmc_qr_256 },
            { :size => 192.0, :id => Rez.Drawables.img_bmc_qr_192 },
            { :size => 176.0, :id => Rez.Drawables.img_bmc_qr_176 },
            { :size => 160.0, :id => Rez.Drawables.img_bmc_qr_160 },
            { :size => 144.0, :id => Rez.Drawables.img_bmc_qr_144 },
            { :size => 128.0, :id => Rez.Drawables.img_bmc_qr_128 },
            { :size => 112.0, :id => Rez.Drawables.img_bmc_qr_112 },
            { :size => 96.0, :id => Rez.Drawables.img_bmc_qr_096 },
        ];

        for (var i = 0; i < opts.size(); ++i) {
            if (opts[i][:size] <= maxSize) {
                _bmpSize = opts[i][:size];
                return opts[i][:id];
            }
        }

        _bmpSize = 96.0;
        return Rez.Drawables.img_bmc_qr_096;
    }

    function onLayout(dc as Gfx.Dc) {
        var w = dc.getWidth();
        var h = dc.getHeight();

        var availH = h - TOP_PAD - BOTTOM_PAD;

        var candidate = (w < availH ? w : availH) * 0.88;

        var ds = Sys.getDeviceSettings();
        if (ds has :screenShape && ds.screenShape == Sys.SCREEN_SHAPE_ROUND) {
            candidate *= 0.94;
        }

        var qrId = pickQrId(candidate);

        _bmp = Ui.loadResource(qrId);

        _x = (w - _bmpSize) / 2.0;
        _y = TOP_PAD + (availH - _bmpSize) / 2.0;
    }

    function onUpdate(dc as Gfx.Dc) {
        var w = dc.getWidth();
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        dc.clear();

        dc.drawText(w / 2, 16, Gfx.FONT_XTINY, Utils._t(Rez.Strings.supportMe), Gfx.TEXT_JUSTIFY_CENTER);

        dc.drawBitmap(_x, _y, _bmp);
    }
}

class DonateHelper {
    function openBuyMeACoffee() {
        Ui.pushView(new BmcQrView(), new Ui.InputDelegate(), Ui.SLIDE_LEFT);
    }
}
