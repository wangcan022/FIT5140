console.log("Server Start")
console.log("======================================")
//this server using liberary below:
//1.express : https://www.npmjs.com/package/express
//2.johnny-five : https://www.npmjs.com/package/johnny-five
//3.rasp-io : https://www.npmjs.com/package/raspi-io
//4.mcp3008.js : https://github.com/fiskeben/mcp3008.js
//5.onoff  : https://www.npmjs.com/package/onoff
//6.RBG and altimeter sensor code from lecture slide

//=========================================================================================
//express
var express = require('express')
var app = express();
//=========================================================================================

//=========================================================================================
//GPIO Setting
var Gpio = require('onoff').Gpio; //include onoff to interact with the GPIO
//pin
var EnablePin = new Gpio(27, 'out');
var InputPin1 = new Gpio(17, 'out');
var InputPin2 = new Gpio(18, 'out');
//=========================================================================================

//=========================================================================================
//Server Port Setting
app.listen(8080);
//=========================================================================================

//=========================================================================================
//Motor Code ---- manual on/off by get request
app.get("/motor",function(request, result){
    var instruction = request.query.instruction
    if (instruction == 1)
    {
        console.log("trying to start motor");
        motorStart();
        setTimeout(motorEnd, 2000);
        result.send("Motor Start");
    }
    else{
        console.log("trying to stop motor")
        motorEnd();
        result.send("Motor Stop");
    } 
});

function motorStart()
{
    EnablePin.writeSync(1);
    InputPin1.writeSync(1);
    InputPin2.writeSync(0);
}

function motorEnd()
{
    EnablePin.writeSync(0);
    InputPin1.writeSync(0);
    InputPin2.writeSync(0);
}

//=========================================================================================
//auto watering function
function autoWatering()
{
    if(shouldAutoWatering)
    {
        let lowerLimit = 500;//assume the plan needs moisture over 500
        currentMoistureObject = moistureSensorData[moistureSensorData.length-1];
        currentMoisture = currentMoistureObject["Moisture"]
        if (currentMoisture < lowerLimit)
        {
            motorStart();
            setTimeout(motorEnd, 2000);
        }
        else{
            motorEnd();
        }
    }
}

setInterval(autoWatering,5000)
var shouldAutoWatering = false; 

app.get('/setautowatering', function(request,result){
    var instruction = request.query.instruction
    if(instruction==1)
    {
        shouldAutoWatering = true;
        result.send("shouldAutoWatering: " + shouldAutoWatering);
    }
    else{
        shouldAutoWatering = false;
        motorEnd();
        result.send("shouldAutoWatering: " + shouldAutoWatering);
    }
})
//=========================================================================================
//turn on light
var LightPin = new Gpio(26, 'out');
LightPin.writeSync(1);
app.get('/setlight', function(request,result){
    var instruction = request.query.instruction
    if (instruction==1)
    {
        LightPin.writeSync(1);
        result.send("Light on")
    }
    else{
        LightPin.writeSync(0);
        result.send("Light off")
    }
})

//=========================================================================================
//Moisture Sensor Code
//this moisture sensor code modify from example that comes with the mcp3008.js package
var moistureSensorData = new Array();

var Mcp3008 = require('mcp3008.js'),
adc = new Mcp3008(),
channel = 0;

out = function (value) {
    var temp = {"Moisture":`${value}`}
    moistureSensorData.push(temp);
    console.log(temp);
    //slice the array
    let currentLength = moistureSensorData.length;
    if (currentLength > 1000)
    {
        let arrayLength = 1000;
        moistureSensorData = moistureSensorData.slice(currentLength-100,currentLength);
    }
};

app.get('/moisture', function(request, result)
{
    result.send(moistureSensorData)
});

adc.read(0, out);
adc.poll(0, 1000, out);

//=========================================================================================
//RGB & Temperature Sensor Code
//code modify from lecture slide
var tempArray = new Array();//this temp stands for temperature, not temp
var rgbArray = new Array();

app.get('/temp', function(request, result){
    var numberOfDataRequested = request.query.numberOfDataRequested
    let endNumber = tempArray.length
    
    if (endNumber < numberOfDataRequested)
    {
        //send error
        let customError = {"error": endNumber}
        let arrayTobeReturn = tempArray
        arrayTobeReturn.push(customError)
        result.send(arrayTobeReturn)
    }
    else
    {
        let startNumber = endNumber - numberOfDataRequested
        let tempArrayToBeReturn = tempArray.slice(startNumber,endNumber)
        result.send(tempArrayToBeReturn);
    }
	
});

app.get('/rgb', function(request, result){
    var numberOfDataRequested = request.query.numberOfDataRequested
    let endNumber = rgbArray.length
    if(endNumber < numberOfDataRequested)
    {
        let customError = {"error": endNumber}
        var arrayTobeReturn = new Array()
        arrayTobeReturn = rgbArray
        arrayTobeReturn.push(customError)
        result.send(arrayTobeReturn)
    }
    else{
        let startNumber = endNumber - numberOfDataRequested
        var rgbArrayToBeReturn = rgbArray.slice(startNumber,endNumber)
        result.send(rgbArrayToBeReturn);
    }
    
});


var raspi = require("raspi-io")
var five = require("johnny-five")
var i2c = require("i2c");

//TCS34725
var address = 0x29;
var version = 0x44;
var rgbSensor = new i2c(address,{device: '/dev/i2c-1'});
//Variables to store colour values
var red;
var green;
var blue;
//bug fix for conflict between MCP3008 and raspi-ip/johnny-five
//https://github.com/nebrius/raspi-io/issues/76
var board = new five.Board({
    io: new raspi({excludePins: ['MOSI0','MISO0','SCLK0','CE0', 'MOSI1','MISO1','SCLK1','CE1',]})
})

board.on("ready", function(){
    var multi = new five.Multi({
        controller: "MPL3115A2",
        elevation: 23
    });

    console.log("server ready to begin processing...");
    multi.on("change", function(){
        console.log("Thermometer: celsius: ", this.thermometer.celsius);
        console.log("Barometer:pressure: ", this.barometer.pressure);
        console.log("Altimeter: ", this.altimeter.meters);
	var temp = {"celsius":this.thermometer.celsius,"pressure":this.barometer.pressure,"altimeter":this.altimeter.meters}
    tempArray.push(temp);
    //slice the array
    let currentLength = tempArray.length
    if (currentLength > 1000)
    {
        let arrayLength = 1000;
        tempArray = tempArray.slice(currentLength-100,currentLength);
    }

    });

    //Run setup if we can retreive correct sensor version for TCS34752 sensor
    rgbSensor.writeByte(0x80|0x12, function(err){});
    rgbSensor.readByte(function(err,res){
        if(res == version){
            setup();
            captureColours();
        }
    });
});

    function setup(){
        //Enable register
        rgbSensor.writeByte(0x80|0x00, function(err){});
        //Power on and enable RGB sensor
        rgbSensor.writeByte(0x01|0x02, function(err){});
        //Read results from Register 14 where adta values are stroed
        rgbSensor.writeByte(0x80|0x14, function(err){});
    }

    function captureColours(){
        //Read the information, output RGB as 16bit number
        rgbSensor.read(8, function(err,res){
            //Colours are stored in two 8 bit address registers, we need to combine them
            clear = res[1] << 8 | res[0];
            red = res[3] << 8 | res[2];
            green = res[5] << 8 | res[4];
            blue = res[7] << 8 | res[6]; 
            //Print data to console
            console.log("Clear" + clear);
            console.log("Red: " + red);
            console.log("Green: " + green);
            console.log("Blue: " + blue);
            var rgb = {"Red":red,"Green":green,"Blue":blue}
            rgbArray.push(rgb);
            //slice the array
            let currentLength = rgbArray.length;
            if (currentLength > 1000)
            {
                let arrayLength = 1000;
                rgbArray = rgbArray.slice(currentLength-100,currentLength);
            }
        });
    }
        setInterval(function(){
            captureColours();
        }, 500);
//=========================================================================================
app.get("/all",function(request, result){
    var allData = new Array();
    var initNumber = 0;
    let rgbLength = rgbArray.length;
    let tempLength = tempArray.length;
    let moistureLength = moistureSensorData.length;
    var minLength;
    if (rgbLength < tempLength)
    {
        minLength = rgbLength;
    }
    else
    {
        minLength = tempLength
    }
    if (minLength > moistureLength)
    {
        minLength = moistureLength;
    }

    for(i=1;i<minLength;i++)
    {
        // allData.push(rgbArray[(rgbLength-i)]);
        // allData.push(tempArray[tempLength-i]);
        // allData.push(moistureSensorData[moistureLength-i]);
        
        var temp = {"Red": rgbArray[rgbLength-i]["Red"], "Green": rgbArray[rgbLength-i]["Green"], "Blue": rgbArray[rgbLength-i]["Blue"], "celsius": tempArray[tempLength-i]["celsius"], "pressure": tempArray[tempLength-i]["pressure"], "altimeter": tempArray[tempLength-i]["altimeter"], "Moisture": moistureSensorData[moistureLength-i]["Moisture"]};
        allData.push(temp);
    }
    result.send(allData);
});
