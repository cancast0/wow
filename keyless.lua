local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local eventstore = {
    ToolCollect = ReplicatedStorage.Events.ToolCollect,
    ToyEvent = ReplicatedStorage.Events.ToyEvent,
    PlayerHiveCommand = ReplicatedStorage.Events.PlayerHiveCommand,
    ClaimHive = ReplicatedStorage.Events.ClaimHive
}
local mapstore = {
    HiddenStickers = Workspace.HiddenStickers,
    Flowers = Workspace.Flowers,
    Collectibles = Workspace.Collectibles,
    Snowflakes = Workspace.Particles.Snowflakes
}
local fieldstore = {}
local rawfieldstore = {}

for _, field in Workspace.FlowerZones:GetChildren() do
    fieldstore[field.Name] = field
    table.insert(rawfieldstore, field.Name)
end
local togglestore = {
    AutoDig = false,
    AutoFarm = false,
    AutoConvert = false,
    CollectHiddenStickers = false,
    FarmTokens = false,
    LoopMovement = false,
    FarmSnowflakes = false,
    AutoWealthClock = false,
    AutoGlueDispenser = false,
    AutoBlueberryDispenser = false,
    AutoCoconutDispenser = false,
    AutoStrawberryDispenser = false,
    AutoTreatDispenser = false,
}
local cstore = {
    Converting = false,
    SelectedField = "Dandelion Field",
    ConvertMethod = "Walk",
    WebhookUrl = "",
    WebhookConvertHoney = true,
    WebookCollectPollen = true,
    WebhookCollectSnowflake = true,
    GettingRares = false,
    GettingToken = false,
    FeedBackDebounce = false,
    CurrentFeedbackValue = "",
    CurrentFeedbackDiscordUser = "None",
    WalkSpeed = 24,
    JumpPower = 70,
}
local functionstore = {
    GetCapacity = function()
        return Players.LocalPlayer.CoreStats.Capacity.Value
    end,
    GetPollen = function()
        return Players.LocalPlayer.CoreStats.Pollen.Value
    end,
    GetHivePosition = function()
        return (Players.LocalPlayer.Honeycomb.Value).patharrow.Base.Position + Vector3.new(0, 2, 0)
    end,
    GetToken = function(field, mag)
        for i, v in mapstore.Collectibles:GetChildren() do
            if ((v.Position * Vector3.new(1, 0, 1)) - (fieldstore[field].Position * Vector3.new(1, 0, 1))).magnitude < mag then
                return v
            end
        end
    end,
    WalkThing = function()
        cstore.WalkingToField = true
        local py = Instance.new("Part")
        py.Parent = Workspace
        py.Name = "ckkk68"
        py.Size = Vector3.new(10000, 5, 10000)
        py.Position = Players.LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 370, 0)
        py.CanCollide = true
        py.Anchored = true
        py.Transparency = 1
        Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(py.Position + Vector3.new(0, 9, 0))
        repeat
            Players.LocalPlayer.Character.Humanoid:MoveTo(fieldstore[cstore.SelectedField].Position)
            task.wait(1)
        until (((fieldstore[cstore.SelectedField].Position * Vector3.new(1, 0, 1)) - (Players.LocalPlayer.Character.HumanoidRootPart.Position * Vector3.new(1, 0, 1))).magnitude < 15) or not togglestore.AutoFarm
        if Workspace:FindFirstChild("ckkk68") then
            Workspace.ckkk68:Destroy()
        end
    end,
    ClaimHive = function()
        for _, v in Workspace.Honeycombs:GetChildren() do
            if v.Owner.Value ~= nil then continue end
            eventstore.ClaimHive:FireServer(v.HiveID.Value)
        end
    end,
    Convert = function()
        eventstore.PlayerHiveCommand:FireServer("ToggleHoneyMaking")
    end,
    IsConverting = function()
        return Players.LocalPlayer.PlayerGui.ScreenGui.ActivateButton.TextBox.Text == "Stop Making Honey"
    end,
    SendFeedback = function(fd)
        body = {
            ["content"] = "Feedback by "..game.Players.LocalPlayer.Name .. " ("..(cstore.CurrentFeedbackDiscordUser)..")",
            ["embeds"] = {{
                ["description"] = fd,
                ["color"] = tonumber(0xff8700),
                ["title"] = ":pencil: Feedback"
            }}
        }
        spawn(function()
            http.request({
                Url = "https://discord.com/api/webhooks/1267241423959228567/BS3QXhZ883i3ytmT8AlP5O1jHx8TMuspk1vl0nW33L22qbLLiuK_bzYkrwE5JEMnXAzu",
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = HttpService:JSONEncode(body)
            })
        end)
    end,
    ToWebhook = function(typ)
        if cstore.WebhookUrl == "" then return end
        local body = {}
        if typ == "wbh_convert" then
            body = {
                ["content"] = "",
                ["embeds"] = {{
                    ["description"] = "Converting "..math.round(Players.LocalPlayer.CoreStats.Pollen.Value).." pollen",
                    ["color"] = tonumber(0xff8700),
                    ["title"] = ":bee: Converting Honey"
                }}
            }
        elseif typ == "wbh_collecting" then
            body = {
                ["content"] = "",
                ["embeds"] = {{
                    ["description"] = "Collecting from "..cstore.SelectedField,
                    ["color"] = tonumber(0xff8700),
                    ["title"] = ":bee: Collecting Pollen",
                }},
            }
        elseif typ == "wbh_gsnowflake" then
            body = {
                ["content"] = "",
                ["embeds"] = {{
                    ["description"] = "",
                    ["color"] = tonumber(0x00dbff),
                    ["title"] = ":snowflake: Collecting Snowflake"
                }}
            }
        end
        spawn(function()
            http.request({
                Url = cstore.WebhookUrl,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = HttpService:JSONEncode(body)
            })
        end)
    end,
}
functionstore["FindFlower"] = function(field)
    flower = mapstore.Flowers:GetChildren()[math.random(1, #mapstore.Flowers:GetChildren())]
    if flower.Name:split("-")[1] == "FP"..fieldstore[field].ID.Value then
        return flower
    else
        functionstore.FindFlower(field)
    end
end
functionstore["GetSnowflake"] = function()
    if #mapstore.Snowflakes:GetChildren() ~= 0 then
        return mapstore.Snowflakes:GetChildren()[math.random(1, #mapstore.Snowflakes:GetChildren())]
    else
        functionstore.GetSnowflake()
        task.wait(0.1)
    end
end

functionstore.ClaimHive()

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/railme37509124/Tabby/main/Lib.lua"))()

local window = library:new({LibSize = UDim2.new(0, 500, 0, 590) ,textsize = 13.5,font = Enum.Font.RobotoMono,name = "Tabby V1",color = Color3.fromRGB(255, 208, 75)})

-- // autofarm
local AutoFarmPage = window:page({name = "Autofarm"})
local AutoFarmSection = AutoFarmPage:section({name = "AutoFarm",side = "left",size = 250})
local ToysSection = AutoFarmPage:section({name = "Toys",side = "Right",size = 250})

-- // lplr
local LocalPlrPage = window:page({name = "Local Plr"})
local LocalPlrSection = LocalPlrPage:section({name = "Player",side = "left",size = 250})

-- // misc
local MiscPage = window:page({name = "Misc"})
local MiscSection = MiscPage:section({name = "Tokens",side = "left",size = 250})

-- // webhook
local WebhookPage = window:page({name = "Webhook"})
local WebhookSection = WebhookPage:section({name = "Webhook Config",side = "left",size = 250})

-- // feedback

local FeedbackPage = window:page({name = "Feedback"})
local FeedbackSection = FeedbackPage:section({name = "Feedback",side = "left",size = 250})

-- // autofarm
AutoFarmSection:toggle({name = "Auto Farm",flag = "autoFarm",value = false})
AutoFarmSection:toggle({name = "Auto Convert",flag = "autoConvert",value = false})
AutoFarmSection:toggle({name = "Collect Hidden Stickers",flag = "collectHiddenStickers",value = false})
AutoFarmSection:toggle({name = "Farm Tokens",flag = "farmTokens",value = false})
AutoFarmSection:toggle({name = "Farm Snowflakes",flag = "farmSnowflakes",value = false})
AutoFarmSection:toggle({name = "Auto Wealth Clock",flag = "autoWealthClock",value = false})
AutoFarmSection:toggle({name = "Auto Glue Dispenser",flag = "autoGlueDispenser",value = false})
AutoFarmSection:toggle({name = "Auto Blueberry Dispenser",flag = "autoBlueberryDispenser",value = false})
AutoFarmSection:toggle({name = "Auto Coconut Dispenser",flag = "autoCoconutDispenser",value = false})
AutoFarmSection:toggle({name = "Auto Strawberry Dispenser",flag = "autoStrawberryDispenser",value = false})
AutoFarmSection:toggle({name = "Auto Treat Dispenser",flag = "autoTreatDispenser",value = false})

AutoFarmSection:dropdown({
    name = "Select Field",
    flag = "selectedField",
    list = rawfieldstore,
    value = cstore.SelectedField,
    callback = function(v)
        cstore.SelectedField = v
    end
})

AutoFarmSection:dropdown({
    name = "Select Convert Method",
    flag = "convertMethod",
    list = {"Walk", "Teleport"},
    value = cstore.ConvertMethod,
    callback = function(v)
        cstore.ConvertMethod = v
    end
})

-- // webhook
WebhookSection:textbox({
    name = "Webhook URL",
    flag = "webhookUrl",
    value = cstore.WebhookUrl,
    callback = function(v)
        cstore.WebhookUrl = v
    end
})

WebhookSection:toggle({
    name = "Webhook Convert Honey",
    flag = "webhookConvertHoney",
    value = cstore.WebhookConvertHoney,
    callback = function(v)
        cstore.WebhookConvertHoney = v
    end
})

WebhookSection:toggle({
    name = "Webhook Collect Pollen",
    flag = "webhookCollectPollen",
    value = cstore.WebhookCollectPollen,
    callback = function(v)
        cstore.WebhookCollectPollen = v
    end
})

WebhookSection:toggle({
    name = "Webhook Collect Snowflake",
    flag = "webhookCollectSnowflake",
    value = cstore.WebhookCollectSnowflake,
    callback = function(v)
        cstore.WebhookCollectSnowflake = v
    end
})

-- // feedback
FeedbackSection:dropdown({
    name = "Select Feedback Discord User",
    flag = "feedbackDiscordUser",
    list = {"None", "User1", "User2"}, -- Add your user list here
    value = cstore.CurrentFeedbackDiscordUser,
    callback = function(v)
        cstore.CurrentFeedbackDiscordUser = v
    end
})

FeedbackSection:textbox({
    name = "Feedback",
    flag = "feedback",
    value = cstore.CurrentFeedbackValue,
    callback = function(v)
        cstore.CurrentFeedbackValue = v
    end
})

FeedbackSection:button({
    name = "Send Feedback",
    callback = function()
        if cstore.CurrentFeedbackValue ~= "" then
            functionstore.SendFeedback(cstore.CurrentFeedbackValue)
        end
    end
})
