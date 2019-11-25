pages = {'app.html','app.css','app.js'}
hw = 127
hc = 180
ss = 1
sst = 5
sat = 255

function hex2num(str)
  local a =0
  local b = 0
  a =("0x"..string.sub(str,1,1))+0
  b =("0x"..string.sub(str,2,2))+0
  return a*16+b
end

function receiver(sck, data)
  _, _, _, url, _ = string.find(data, "([A-Z]+) /([^?]*)%??(.*) HTTP")

  if url=='' or url==nil then
    url = 'app.html'
  end

  _, _, c = string.find(url, "c/(.*)")
  if c~=nil then
    j = hex2num(string.sub(c,1,2))
    f = hex2num(string.sub(c,3,4))
    s = hex2num(string.sub(c,5,6))

    hw = 20 + j / 255 * 160
    hc = 180 + f / 255 * 180
    ss = 0.1+(s / 255)*2
    sst = 10-9*(s / 255)
    sat = 255
    if ((j + f) < 63) then
      sat =(128 + (j + f) / 63 * 127)
    end

    --print(string.format("c '%s' at %d %d %d", c, joy,fury,stress))
    sck:send("HTTP/1.1 200 OK\r\n\r\n",function(c) c:close() end)
    return
  end

  for _, v in pairs(pages) do
    if v == url then
      sck:send("HTTP/1.1 200 OK\r\n\r\n",function(c) send_it_all(c,url,0) end)
      return
    end
  end

  sck:send("HTTP/1.1 404 file not found",function(c) c:close() end)

end


--recursive send function
function send_it_all(c,u,p)
  if file.open(u, "r") then
      file.seek("set", p)
      local chunk = file.read(512)
      file.close()
      if chunk then
          if (string.len(chunk) == 512) then
              c:send(chunk,function(c)
                send_it_all(c,u,p+512) end)
              return
          else
            c:send(chunk,function(c)
              c:close() end)
            return
          end
      end
  end
  c:close()
end


srv = net.createServer(net.TCP)
srv:listen(80, function(conn)
  conn:on("receive", receiver)
end)


print("HTTP Server is now listening. Free Heap:", node.heap())


-- init the ws2812 module
ws2812.init(ws2812.MODE_SINGLE)
-- create a buffer, 10 LEDs with 3 color bytes
buffer = ws2812.newBuffer(50, 3)

local t=0
tmr.create():alarm(50, 1, function()
  for i=1,buffer:size() do
    x = 2 - (i/buffer:size() + t) % 1
    buffer:set(i, color_utils.hsv2grb((hc + hw * x)%360, sat, 255))
  end
  t = t + 0.1*sst
  ws2812.write(buffer)
end)
