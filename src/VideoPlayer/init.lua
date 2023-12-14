--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")

--// Modules
local Library = require(script.Library)

--// General
local VideoPlayer = {}
VideoPlayer.__index = VideoPlayer


export type Video = {

    Parent : GuiObject,

    Playing : boolean,
    Completed : boolean,
    CurrentlyPlaying : nil,

    Event : BindableEvent,
    OnCompletion : RBXScriptSignal

}


function VideoPlayer.new(Parent : GuiObject) : Video

    local self = setmetatable({}, VideoPlayer)

    --// General
    self.Parent = Parent
    self.Playing = false
    self.CurrentlyPlaying = nil
    self.Completed = false
    self.Folder = Instance.new("Folder") self.Folder.Parent = Parent

    --// Events & Connections
    self.Event = Instance.new("BindableEvent")
    self.OnCompletion = self.Event.Event

    return self

end

function VideoPlayer:Play(Directory : string, Properties : any) : nil
    
    local Preloaded = self.Folder:FindFirstChild(Directory)

    if not Preloaded then self:Preload(Directory) end

    local VideoData = Library[Directory]
    local Frames,FPS = VideoData.Frames,VideoData.FPS

    for _,Id in ipairs(Frames) do
        
        self.Parent.Image = Id

    end

    self.Parent.Image = ""
    self.Playing = true
    self.CurrentlyPlaying = Directory

    local function Play()

        for _,Id in ipairs(Frames) do

            if self.Playing == false then break end

            self.Parent.Image = Id
    
            task.wait(FPS)
    
        end

        _ = (Properties and Properties.Looped and self.Playing) and Play() or self.CompletedEvent:Fire()

    end

    coroutine.wrap(Play)()

end

function VideoPlayer:Stop() : nil

    self.Playing = false
    
end

function VideoPlayer:Preload(Directory : string) : nil

    local Video = Library[Directory]

    if not Video then return warn(string.format("ERROR 404: Could not locate \'%s\' inside of Video Library",Directory)) end

    local Frames = Video.Frames
    ContentProvider:PreloadAsync(Frames)

    for i,Id in ipairs(Frames) do

        local ImageLabel = Instance.new("ImageLabel")
        ImageLabel.Image = Id
        ImageLabel.Size = UDim2.new(0,1,0,1)
        ImageLabel.Parent = self.Folder
        ImageLabel.Position = UDim2.new(1,0,1,0)
        ImageLabel.Name = Directory..i
        ImageLabel.BackgroundTransparency = 1
        ImageLabel.ImageColor3 = Color3.fromRGB(0,0,0)
        ImageLabel.ZIndex = 0

    end

    return

end

function VideoPlayer:Destroy()

    self.Folder:Destroy()
    self.Playing = false
    setmetatable(self,nil)
    self = nil

end


return VideoPlayer