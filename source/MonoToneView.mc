import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.ActivityMonitor;
import Toybox.Activity;

class MonoToneView extends WatchUi.WatchFace {
    const customTinyFont = WatchUi.loadResource(@Rez.Fonts.customTiny);
    const customSmallFont = WatchUi.loadResource(@Rez.Fonts.customSmall);
    const customMediumFont = WatchUi.loadResource(@Rez.Fonts.customMedium);

    const graphX = 54;
    const graphY = 143;
    const graphWidth = 128;
    const graphHeight = 50;

    const WHITE = 0;
    const RED = 1;
    const BLUE = 2;
    
    const INVALID_HR_SAMPLE = 255;

    const BATTERY_THRESHOLD = 20;

    var mySettings;

    function initialize() {
        WatchFace.initialize();

        mySettings=new MonoToneSettings();
    }

    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    function onShow() as Void {
        mySettings.loadLocal();
    }

    function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);
        var date = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);

        var systemStats = System.getSystemStats();
        var deviceSettings = System.getDeviceSettings();
        var info = ActivityMonitor.getInfo();
        var infos = Activity.getActivityInfo();

        (View.findDrawableById("DayOfWeek") as Toybox.WatchUi.Text).setText(
            date.day_of_week.toUpper()
        );
        (View.findDrawableById("DayOfMonth") as Toybox.WatchUi.Text).setText(
            date.day.format("%02d")
        );
        (View.findDrawableById("Month") as Toybox.WatchUi.Text).setText(
            date.month.toUpper()
        );

        (View.findDrawableById("Hour") as Toybox.WatchUi.Text).setText(
            date.hour.format("%02d")
        );
        (View.findDrawableById("Minute") as Toybox.WatchUi.Text).setText(
            date.min.format("%02d")
        );

        (View.findDrawableById("BatteryPercentage") as Toybox.WatchUi.Text).setText(
            systemStats.battery.format("%d")
        );

        (View.findDrawableById("HRAct") as Toybox.WatchUi.Text).setText(
            infos.currentHeartRate ? infos.currentHeartRate.format("%d") : "--"
        );

        (View.findDrawableById("Steps") as Toybox.WatchUi.Text).setText(
            info.steps ? info.steps.format("%d") : "0"
        );

        if(deviceSettings.alarmCount > 0){
            colorAlarms(RED);
        }else{
            colorAlarms(WHITE);
        }

        if(deviceSettings.notificationCount > 0){
            colorNotifications(RED);
        }else{
            colorNotifications(WHITE);
        }

        if(deviceSettings.doNotDisturb){
            colorDnD(RED);
        }else{
            colorDnD(WHITE);
        }

        if(deviceSettings.phoneConnected){
            colorBluetooth(WHITE);
        }else{
            colorBluetooth(RED);
        }

        if(systemStats.charging){
            colorBattery(BLUE);
        }else if(systemStats.battery <= BATTERY_THRESHOLD){
            colorBattery(RED);
        }else{
            colorBattery(WHITE);
        }

        switch (mySettings.extraWidgetType){
            case 0x00000:
                break;
            case 0x000001:
                drawHeartRateGraph(dc);
                break;
            case 0x000002:
                drawCaloriesLabel(dc,info);
                break;
            case 0x000003:
                drawAltitudeLabel(dc,infos);
                break;
            /*
            case 0x000004:
                drawSpeedLabel(dc,infos);
                break;
            */
        }
    }

    function onHide() as Void {}
    function onExitSleep() as Void {
        WatchUi.requestUpdate();
    }
    function onEnterSleep() as Void {
        WatchUi.requestUpdate();
    }

    function drawAltitudeLabel(dc as Dc, infos as Toybox.Activity.Info) as Void {
        var altitude = infos.altitude;
        var altitudeString = altitude!=null ? altitude.format("%d") : 0;
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(120, graphY, customMediumFont, altitudeString, Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT); 
        dc.drawText(120,  graphY - 13, customSmallFont, "ALTITUDE - M", Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawCaloriesLabel(dc as Dc, info as Toybox.ActivityMonitor.Info) as Void {
        var calories = info.calories;
        var caloriesString = calories!=null ? calories.format("%d") : 0;
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(120, graphY, customMediumFont, caloriesString, Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(120,  graphY - 13, customSmallFont, "CALORIES - KCAL", Graphics.TEXT_JUSTIFY_CENTER);
    }
    /*
    The speed label is working as expected in the simulator while using Activity.Info.getActivityInfo() and Position.getInfo() and crashing when using Sensor.getInfo().
    On the physical watch, Sensor.getInfo() is still crashing, Activity.Info.getActivityInfo() is showing 0.0 constantly and Position.getInfo() is showing huge numbers.

    function drawSpeedLabel(dc as Dc, infos as Toybox.Activity.Info) as Void {
        var speed = infos.currentSpeed;
        var speedString = speed!=null ? (speed*3.6).format("%.1f") : "0.0";
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(120, graphY, customMediumFont, speedString, Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(120,  graphY - 13, customSmallFont, "SPEED - KM/HR", Graphics.TEXT_JUSTIFY_CENTER);
    }
    function drawSpeedLabel(dc as Dc) as Void {
        var speed = Position.getInfo().speed;
        var speedString = speed!=null ? (speed*3.6).format("%.1f") : "0.0";
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(120, graphY, customMediumFont, speedString, Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(120,  graphY - 13, customSmallFont, "SPEED - KM/HR", Graphics.TEXT_JUSTIFY_CENTER);
    }    
    function drawSpeedLabel(dc as Dc) as Void {
        var sensorInfo = Sensor.getInfo();
        var speed = sensorInfo.speed;
        var speedString = speed!=null ? (speed*3.6).format("%.1f") : "0.0";
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(120, graphY, customMediumFont, speedString, Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(120,  graphY - 13, customSmallFont, "SPEED - KM/HR", Graphics.TEXT_JUSTIFY_CENTER);
    }
    */
    function scaleValue(value as Number, oldMin as Number, oldMax as Number, newMin as Number, newMax as Number) as Number {
        if (oldMax == oldMin) { return newMin; }
        return (((value - oldMin) * (newMin - newMax)) / (oldMax - oldMin)) + newMax;
    }

    function drawHeartRateGraph(dc as Dc) as Void {
        var pixels_per_sample = 8;
        var nrOfSamples = graphWidth/pixels_per_sample;
        var hrinfo = ActivityMonitor.getHeartRateHistory(nrOfSamples, true);
        if (hrinfo == null) { return; }

        var targetMin = graphY + 3;
        var targetMax = graphY + graphHeight - 2;

        var min = hrinfo.getMin();
        var max = hrinfo.getMax();
        if (min == null || max == null) { return; }

        var previousValue = hrinfo.next();
        if (previousValue == null) { return; }
        var currentValue = hrinfo.next();
        var currentIndex = 0;
        var mined = false;
        var maxed = false;

        var x1 = 0;
        var y1 = 0;
        var x2 = 0; 
        var y2 = 0;
        while (currentValue != null && previousValue != null) {
            if(currentValue.heartRate == INVALID_HR_SAMPLE || previousValue.heartRate == INVALID_HR_SAMPLE){
                previousValue = currentValue;
                currentIndex++;
                currentValue = hrinfo.next();
                continue;
            }
            x1 = graphX + currentIndex*pixels_per_sample;
            y1 = scaleValue(previousValue.heartRate,min,max,targetMin,targetMax);
            x2 = graphX + (currentIndex+1)*pixels_per_sample;
            y2 = scaleValue(currentValue.heartRate,min,max,targetMin,targetMax);

            dc.setPenWidth(3);
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(x1, y1, x2, y2);
                
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawPoint(x1,y1);

            drawMinMaxLabels(dc, previousValue, x1, y1, min, max, mined, maxed);

            previousValue = currentValue;
            currentIndex++;
            currentValue = hrinfo.next();
        }

        drawMinMaxLabels(dc, previousValue, x2, y2, min, max, mined, maxed);

        dc.setPenWidth(3);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawPoint(x2,y2);
    }

    function drawMinMaxLabels(dc, value, x, y, min, max, mined, maxed){
        if(value.heartRate <= min && !mined){
            var x_temp = x;
            if(x_temp<64){x_temp=64;}
            if(x_temp>174){x_temp=174;}
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x_temp, y, customTinyFont , min.format("%d"), Graphics.TEXT_JUSTIFY_CENTER);
            mined = true;
        }
        if(value.heartRate >= max && !maxed){
            var x_temp = x;
            if(x_temp<64){x_temp=64;}
            if(x_temp>174){x_temp=174;}
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x_temp, y-20, customTinyFont, max.format("%d"), Graphics.TEXT_JUSTIFY_CENTER);
            maxed = true;
        }
    }    

    function setIconColor(baseId as String, color as Number) as Void {
        findDrawableById(baseId).setVisible(color == WHITE);
        findDrawableById(baseId + "Red").setVisible(color == RED);
        
        var blueIcon = findDrawableById(baseId + "Blue");
        if (blueIcon != null) {
            blueIcon.setVisible(color == BLUE);
        }
    }

    function colorBattery(color as Number) as Void {
        setIconColor("Battery", color);
        var textColor = color == RED ? 0xff0000 : 
                       color == BLUE ? 0x0000ff : 
                       Graphics.COLOR_DK_GRAY;
        (View.findDrawableById("BatteryPercentage") as Text).setColor(textColor);
    }

    function colorDnD(color as Number) as Void {
        setIconColor("DnD", color);
    }

    function colorAlarms(color as Number) as Void {
        setIconColor("Alarms", color);
    }

    function colorBluetooth(color as Number) as Void {
        setIconColor("Bluetooth", color);
    }

    function colorNotifications(color as Number) as Void {
        setIconColor("Notifications", color);
    }
}

