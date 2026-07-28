import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class HarvestPixelsApp extends Application.AppBase {
    private var _view as HarvestPixelsView?;

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Lang.Dictionary?) as Void {
    }

    function onStop(state as Lang.Dictionary?) as Void {
    }

    function getInitialView() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] {
        _view = new HarvestPixelsView();
        return [_view];
    }

    function onSettingsChanged() as Void {
        if (_view != null) {
            (_view as HarvestPixelsView).onSettingsChanged();
        }
    }
}
