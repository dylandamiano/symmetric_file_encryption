local https = require("https")
local json = require("json")
local fs = require("fs")

local token = "" -- token has since been revoked years after lol. get a "load" of that webscrapers.

local files = fs.readdirSync("./folder/")
print("THIS IS THE TEST VARIABLE: ", json.encode(files))

local requestData = {
    model = "gpt-3.5-turbo",
    messages = {
        {
            role = "user",
            content = "what files should be encrypted from this list?: (provide json for the files that should be in the format similar to ['filename1', 'filename2', ... 'filenameN'])" .. json.stringify(files)
        }   
    }
}

local sensitiveData;

local options = {
    hostname = "api.openai.com",
    port = 443, -- HTTPS port
    path = "/v1/chat/completions",
    method = "POST",
    headers = {
        ["Content-Type"] = "application/json",
        ["Authorization"] = "Bearer " .. token,
        ["Content-Length"] = #json.stringify(requestData)
    },
}

print(options.headers.Authorization .. " is the token provided!")

local top
local req = https.request(options, function(res)
    local responseData = ""

    res:on("data", function(data)
        print("Data is coming!\n")
        responseData = responseData .. data
    end)

    res:on("end", function()
        print("End of request!")
        print(responseData)
        responseData = json.decode(responseData)
        print(json.decode(responseData.choices[1].message.content))

        for i, v in pairs(json.decode(responseData.choices[1].message.content)) do
            print(i, v)
            sensitiveData = json.decode(responseData.choices[1].message.content)
        end
    end)
end)

local jsonPayload = json.stringify(requestData)
print(#jsonPayload)

req:write(jsonPayload)
req:done()

req:on("error", function(error)
    print("Error provided: " .. error)
end)

-- LUA SOCKET SERVER implementation from NodeJS, JavaScript
local net = require('net');

--/ Create a TCP server
local server = net.createServer(function(socket)
  print('Client connected');

  -- Send a message to the client when it connects
  socket:write('Hello from the server!\r\n');

  -- Handle data received from clients
  socket:on('data', function(data)
    print('Data received: '.. data .. " from: ", socket["remotAddresss"]);

    if type(socket) == "table" then
        for i, v in pairs(socket) do
            print(i, v)
        end
    end

    -- You can process the data received here

    if data == "SENSITIVE DATA" then
        socket:write(json.encode(sensitiveData))
    end
  end);

  -- Handle client disconnection
  socket:on('end', function()
    print('Client disconnected');
  end);

  -- Handle errors
  socket:on('error', function (err) 
    print('Socket error: ' ..  err.message);
  end);
end)

-- Define the port to listen on
local PORT = 3000;

-- Start the server
server:listen(PORT, function()
    print('Server running on port: ' .. PORT);
end);
