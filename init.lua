wifi.setmode(wifi.SOFTAP)
--print(wifi.sta.getip())
wifi.ap.config({ssid="myssid",pwd="mypassword"})
--192.168.4.1
pin = 4
led1 = 3

gpio.mode(led1, gpio.OUTPUT)
tmr.alarm(1, 20000, 1, function() GetSensorData() end)

function GetSensorData()
    status, temp, humi, temp_dec, humi_dec = dht.read(pin)
    if status == dht.OK then
    temp = (temp * 9 / 5 + 32)
        print("DHT Temperature:"..temp..";".."Humidity:"..humi)
    elseif status == dht.ERROR_CHECKSUM then
        print( "DHT Checksum error." )
        temp = "ce"
        humi = "ce"
        temp_dec = "ce"
        humi_dec =  "ce" 
    elseif status == dht.ERROR_TIMEOUT then
        print( "DHT timed out." )
        temp = "to"
        humi = "to"
        temp_dec = "to"
        humi_dec = "to"
    end
end

srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive", function(client,request)
        local buf = "";
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end
        
        local _GET = {}
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
            end 
end
       buf = buf.."HTTP/1.1 200 OK\r\n";--safari
       buf = buf.."Content-type: text/html\r\n";--safari
       buf = buf.."Connection: close\r\n\r\n";--safari
       buf = buf.."<h1> ESP8266 Web Server</h1>";
       buf = buf.."<p>GPIO0 <a href=\"?pin=ON1\"><button>ON</button></a>&nbsp;<a href=\"?pin=OFF1\"><button>OFF</button></a></p>";
       buf = buf.."Temp:"..temp..".....".."humidity:"..humi;
       buf = buf.."<meta http-equiv=refresh content=10>";
        local _on,_off = "",""
        if(_GET.pin == "ON1")then
              gpio.write(led1, gpio.HIGH);
        elseif(_GET.pin == "OFF1")then
            gpio.write(led1, gpio.LOW);

        end

        client:send(buf);
        client:close();
        collectgarbage();    
    end)   
end)
