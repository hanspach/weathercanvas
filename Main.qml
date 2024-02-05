import QtQuick

Window {
    width: 800
    height: 800
    visible: true
    title: qsTr("Canvas")


    Canvas {
        property string date: "So, 31.12.23"
        property int humidity: 0
        property int temperature: 0
       // property real x: 30
        //property real y: 100
        property var fp: [drawTimeDate, drawForeCast, drawTemperatures];
        property int idx: 0



        anchors.fill: parent
        id: canvas

        onPaint: {

            let ctx = getContext("2d");
            ctx.fillStyle = 'black'
            ctx.fillRect(0,0,canvas.width,canvas.height);
            ctx.fillStyle = "lime green"
            ctx.beginPath();

            if(time.sec % 5 == 0) {
                if(++canvas.idx > 2) {
                    canvas.idx = 0;
                }
            }
            drawTimeDate(ctx);
            //fp[idx](ctx);

            ctx.stroke();
        }

    }

    function drawTimeLine(ctx,fontSize,showSec) {
        ctx.font = "" + fontSize + "px sans serif";
        var txt = "" + time.hour + ":" + fillupNumber(time.min,2,'0');
        var w = ctx.measureText(txt).width;
        var x = (50 + canvas.width - w) / 2;
        var y = (canvas.height / 3) * 2;
        ctx.fillText(txt,x,y);
        if(showSec) {
            x += w;
            ctx.font = "" + (fontSize/2) + "px sans serif";
            ctx.fillText(fillupNumber(time.sec,2,'0'),x,y);
        }
    }

    function drawTimeDate(ctx) {
        ctx.font = "108px sans serif";
        var x  = (canvas.width - ctx.measureText(canvas.date).width) / 2;
        var y  = canvas.height / 3;

        ctx.fillText(canvas.date,x,y);
        drawTimeLine(ctx,148,true);
    }

    function drawForeCast(ctx,x,y,font) {
        ctx.font = font;
        ctx.fillText("Weather - Forecast",x,y);
    }

    function drawTemperatures(ctx,x,y,font) {
        ctx.font = font;
        ctx.fillText("Temperatures - Pressures",x,y);
    }

    Timer {
        property int hour: 18
        property int min:  45
        property int sec:  50

        id: time
        interval: 1000; running: false; repeat: true
        onTriggered: {
            if(++sec > 59) {
                sec = 0;

                if(++min > 59) {
                    min = 0;

                    if(++hour > 23) {
                        hour = 0;
                    }
                }
            }
            canvas.requestPaint();
        }
    }

    Component.onCompleted: {
        time.start();

        //esp32Request();
    }

    function esp32Request() {
            const url = "http://192.168.0.14";
            const xhr = new XMLHttpRequest();

            xhr.open('GET', url);
            xhr.send();
            xhr.onload = function() {
                if(xhr.status == 200) {
                    try {
                        const objs = JSON.parse(xhr.responseText.toString());
                        let item = objs["date"];
                        if(typeof item === "string")
                            canvas.date = item;
                        item = objs["hour"];
                        if(typeof item === "number")
                            time.hour = item;
                        item = objs["min"];
                        if(typeof item === "number")
                            time.min = item;
                        item = objs["sec"];
                        if(typeof item === "number")
                            time.sec = item;

                        console.log("Datum:" + objs["date"]);
                        console.log("Uhrzeit:" + objs["hour"] + ":" + objs["min"] + ":" + objs["sec"]);
                        console.log("Luftfeuchte:" + objs["humidity"] + "\%");
                        console.log("Temperatur:" + objs["temperature"] + "°C");
                        console.log("Luftdruck:" + objs["pressure"] + " mBar");
                        console.log("Wetter:" + objs["description"]);
                        console.log("Raumtemperatur:" + objs["itemp"] + "°C");
                        console.log("Aussentemperatur:" + objs["otemp"] + "°C");
                        console.log("Bat-Ladezustand:" + objs["batpercent"] + "\%");


                    }
                    catch(e) {
                        console.log(e.name);
                    }
                }
                else {
                    console.log(xhr.statusText);
                }
            }
        }


    function fillupNumber(n, digits, fillChar) {
        let res = Array.from(n.toString());
        for(let i=res.length; i < digits; ++i)
            res.unshift(fillChar);
        return res.join("");
    }


}



