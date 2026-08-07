import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class CosmoCaseApp extends Application.AppBase {
    private var _view as CosmoCaseView?;

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Lang.Dictionary?) as Void {
    }

    function onStop(state as Lang.Dictionary?) as Void {
    }

    function getInitialView() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] {
        _view = new CosmoCaseView();
        var delegate = new CosmoCaseDelegate(_view as CosmoCaseView);
        return [_view as CosmoCaseView, delegate];
    }
}
