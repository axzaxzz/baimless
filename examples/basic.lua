--[[
    Basic Example - Baimless UI Library
    Shows how to create a simple UI with login screen
--]]

local Baimless = loadstring(game:HttpGet('https://raw.githubusercontent.com/axzaxzz/baimless/main/src/Baimless.lua'))()

-- Example 1: Show login screen with authentication
Baimless:ShowLogin(function(username, password)
    print("Login attempt:", username)
    
    -- Simulate authentication check
    if username == "admin" and password == "admin123" then
        print("Login successful!")
        return true
    else
        warn("Invalid credentials")
        return false
    end
end)

-- The main UI will automatically appear after successful login

-- Example 2: Create UI directly without login
-- local window = Baimless:CreateWindow()
-- print("UI created successfully")