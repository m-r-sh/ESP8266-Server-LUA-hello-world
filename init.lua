wifi.setmode(wifi.STATION)
wifi.sta.config("AccessPointName","Password")
print(wifi.sta.getip())

--uart.write(0, ip) or print(ip)
led1 = 3 -- pin number 
led2 = 4 -- pin number 
waitForTemp=0
gpio.mode(led1, gpio.OUTPUT)
gpio.mode(led2, gpio.OUTPUT)
srv=net.createServer(net.TCP)--net.createServer(net.TCP,1000) 1000s time out
temp=20
-- when 4 chars is received this function call .
uart.on("data","\^",
  function(data)
    
    if data=="quit^" then
      uart.on("data") -- unregister callback function
    end
    waitForTemp=1  
    dataLen=string.len(data)
    --print("dataLen with ^",dataLen)
    dataLen=dataLen-1 -- without EOD
    temp=string.sub(data,1,dataLen)   
   -- print("temp is",temp)
    
   
end, 0)--0:input fromUART will not go to Lua interpreter, can accept bin data
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
        local _on,_off = "",""
        if(_GET.pin == "TempShow")then--send temp req to board and wait for get temp
            --gpio.write(led1, gpio.HIGH);
           -- uart.write(0, 'SODtempEOD');-- send temp and now must wait for receive
            --wait until get tmep
          --  while(waitForTemp==0)
          --  do 
            
          --  end                  
            -- if can delay here . all is ok
           -- sleep(3)
             waitForTemp=0           
                --tmr.delay(3000);-- delay for receive temp in uart.on

       
        end 
        if(_GET.setTemp ~= nil)then
                local command = "^temp";
                command=command.._GET.setTemp;
                command=command.."^";
                
                uart.write(0,command);
        end
        buf = buf..'<h1 style="backgrnd-color:powderblue;color:yellow;"> Server for Read and change Temperature </h1>';
              buf = buf.."<p>Temperature Display  "..temp.."<a href=\"?pin=TempShow\"><button>TEMP</button></a>&nbsp;</p>";
              buf = buf..'<form action="\" method="get"><p>insert your Optimum temperature :</p> <input type="text" name="setTemp"><input type="submit" value="Send">&nbsp;</form>';
      -- buf = buf.."<p>GPIO2 <a href=\"?pin=ON2\"><button>ON</button></a>&nbsp;<a href=\"?pin=OFF2\"><button>OFF</button></a></p>";
       
       -- elseif(_GET.pin == "OFF1")then
         --     gpio.write(led1, gpio.LOW);
        --elseif(_GET.pin == "ON2")then
        --      gpio.write(led2, gpio.HIGH);
        --elseif(_GET.pin == "OFF2")then
        --      gpio.write(led2, gpio.LOW);
        
       -- end
        client:send(buf);
        client:close();
        collectgarbage();
    end)-- end of conn on receive
end)--end of listen
