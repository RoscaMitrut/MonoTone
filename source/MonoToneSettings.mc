import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class MonoToneSettings {
    var extraWidgetType = 0x000000;
    var hasProperties=false;

    function initialize() {
        hasProperties=(Toybox.Application has :Properties);
        load();         
        loadLocal();    
    }

    function load() {
        extraWidgetType=readKeyInt("ExtraWidget",0x000000);
    }

    function loadLocal() {
    }

    function saveLocal() {
    }

	hidden function readKeyInt(key,thisDefault) {	
	    var value=null;
        try {
            value = Application.Properties.getValue(key);
        } catch(e) {
            value=null;
        }
	    if(value==null || !(value instanceof Number)) {
			if(value!=null) {value=value.toNumber();} 
			else {value=thisDefault;}
    	}    	
		return value;    
	}
}

class MonoToneSettingsMenu extends WatchUi.Menu2 {
    var mySettings=null;

    function initialize() {
        Menu2.initialize(null);
        mySettings=new MonoToneSettings();
        Menu2.setTitle("Settings");
    }
}

class MonoToneSettingsMenuDelegate extends WatchUi.Menu2InputDelegate {
	var view=null;

    function initialize(v) {
        Menu2InputDelegate.initialize();
        view=v;
    }
    
  	function onSelect(item) {
  		//var id=item.getId();
	}
    
    function onBack() {
        view.mySettings.saveLocal();
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
		//return false;
    }

}	
