import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Background;

class MonoToneSettings {
    var extraWidgetType = 0x000000;
    var hasProperties=false;

    function initialize() {
        //hasProperties=(Toybox.Application has :Properties);
        load();         //app
        loadLocal();    //on-device
    }

    function load() {
    }

    function loadLocal() {
        extraWidgetType=Application.Storage.getValue("extrawidgettype");
        if(extraWidgetType==null){extraWidgetType=0x000000;}
    }

    function saveLocal() {
        Application.Storage.setValue("extrawidgettype",extraWidgetType);
    }
/*
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
*/
}

class MonoToneSettingsMenu extends WatchUi.Menu2 {
    var mySettings=null;
    var widgetNames = [WatchUi.loadResource(@Rez.Strings.empty) as String,
                        WatchUi.loadResource(@Rez.Strings.hrGraph) as String,
                        WatchUi.loadResource(@Rez.Strings.speedLabel) as String,
                        WatchUi.loadResource(@Rez.Strings.caloriesLabel) as String,
                        WatchUi.loadResource(@Rez.Strings.altitudeLabel) as String,
                    ] as [String];
    var extraWidgetMenuItem = null;

    function initialize() {
        Menu2.initialize(null);
        mySettings=new MonoToneSettings();
        Menu2.setTitle("Settings");
    
        extraWidgetMenuItem = new WatchUi.MenuItem("Extra Widget Type",widgetNames[mySettings.extraWidgetType as Number] as String,"ewt",null);

        Menu2.addItem(extraWidgetMenuItem);
    }
}

class MonoToneSettingsMenuDelegate extends WatchUi.Menu2InputDelegate {
	var view=null;

    function initialize(v) {
        Menu2InputDelegate.initialize();
        view=v;
    }
    
  	function onSelect(item) {
        var id=item.getId();
  		if(id.equals("ewt"))   {
            view.mySettings.extraWidgetType= (view.mySettings.extraWidgetType+1) % view.widgetNames.size(); ;
            view.extraWidgetMenuItem.setSubLabel((view.widgetNames as [String])[view.mySettings.extraWidgetType]);
            }   	
		}
    
    function onBack() {
        view.mySettings.saveLocal();
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
		//return false;
    }

}	
