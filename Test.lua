local Players = game:GetService("Players")  
local TweenService = game:GetService("TweenService") 
local ReplicatedStorage = game:GetService("ReplicatedStorage") 
local RunService = game:GetService("RunService") 
 
local Plr = Players.LocalPlayer 
local Character = Plr.Character or Plr.CharacterAdded:Wait() 
 
local CurrentRooms = workspace:WaitForChild("CurrentRooms", 9e9) 
 
local Assets = game:GetObjects("rbxassetid://12501464609")[1] 
Assets.Parent = ReplicatedStorage 
 
local Scanner = Assets.CrystalScanner

-- ORANGE TABLET
local MainOrange = Color3.fromRGB(255, 115, 25)
local DarkOrange = Color3.fromRGB(140, 45, 10)
local GlowOrange = Color3.fromRGB(255, 145, 35)

-- Recolor the scanner casing
for _, Object in ipairs(Scanner:GetDescendants()) do
	if Object:IsA("BasePart") then
		if Object.Name ~= "Screen" then
			Object.Color = MainOrange
		end
	end
end

-- Recolor the screen housing/light
local Handle = Scanner:FindFirstChild("Handle")

if Handle then
	local Screen = Handle:FindFirstChild("Screen")

	if Screen then
		local SurfaceLight = Screen:FindFirstChildWhichIsA("SurfaceLight")

		if SurfaceLight then
			SurfaceLight.Color = GlowOrange
		end
	end
end

local UI = Assets.ScreenUICrystal
local OffS = UI.OffScreen

local ItemsToRemove = {}
local Stars = {}
local Connections = {}

local State = false
local CanUse = true

local TabletID = math.random(1, 999999999)

function MoveRoomToViewport(Room : Model)
	local Clone = Room:Clone()
	Clone.Parent = UI.ViewNormal
	
	for _,v in pairs(Clone:QueryDescendants("Sound")) do
		v:Destroy()
	end
	
	ItemsToRemove[#ItemsToRemove + 1] = Clone
end

function MarkObject(Object, Prompt)
	if Object:GetAttribute("TabletMark_"..TabletID) then return end

	local Marked = Object.PrimaryPart
	local S = MarkObjectWithStar(Marked)
	
	if Prompt then
		local C_; C_ = Prompt.Triggered:Connect(function()
			C_:Disconnect()
			
			TweenService:Create(S, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{
				Transparency = 1
			}):Play()

			task.delay(1, function()
				S:Destroy()
			end)
		end)
	end
	
	local Room = Object:FindFirstAncestorWhichIsA("Model")
	Room.Destroying:Connect(function()
		S:Destroy()
	end)
	
	Object:SetAttribute("TabletMark_"..TabletID, true)
end

function MarkObjectWithStar(Object : BasePart)
	local NewStar = Assets.Star:Clone()
	NewStar.Parent = UI.ViewSpecial
	NewStar.Position = Object.Position
	NewStar.Color = Color3.new(1, 1, 1)
	
	local Index = #Stars + 1
	
	Object.Destroying:Connect(function()
		table.remove(Stars, Index)
		
		TweenService:Create(NewStar, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{
			Transparency = 1
		}):Play()
		
		task.delay(1, function()
			NewStar:Destroy()
		end)
	end)
	
	Stars[#Stars + 1] = NewStar
	
	return NewStar
end

function DisplayStatic()
	Scanner.Handle.Use:Play()
	UI.Static2.ImageTransparency = 0
	UI.ViewSpecial.ImageTransparency = 1
	
	TweenService:Create(UI.ViewSpecial, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{
		ImageTransparency = 0
	}):Play()
	
	TweenService:Create(UI.Static2, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{
		ImageTransparency = 1
	}):Play()
end

function TurnOffAnimation()
	Scanner.Handle.Disable:Play()
	
	OffS.Visible = true
	OffS.Frame.Size = UDim2.fromScale(1, 1)
	
	TweenService:Create(OffS.Frame, TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{
		Size = UDim2.fromScale(1, .1)
	}):Play()
	
	task.wait(.5)
	
	TweenService:Create(OffS.Frame, TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),{
		Size = UDim2.fromScale(0, .1)
	}):Play()
end

function Switch()
	if not CanUse then
		return false
	end
	
	CanUse = false
	
	local Anim = Character.Humanoid:LoadAnimation(Scanner.Animations.fire)
	Anim.Priority = "Action4"
	Anim:Play()
	
	task.wait(.3)
	
	if State == false then
		On()
	else
	
		Off()
	end
	
	task.wait(1)
	
	CanUse = true
end

function CameraStaticMover(Static)
	local RNG = math.random(-100, 100)
	local RNG1 = math.random(-100, 100)
	Static.Position = UDim2.new(0.5, RNG, 0.5, RNG1)
end

function Update()
	local RoomId = Plr:GetAttribute("CurrentRoom")
	local CurrentRoom = CurrentRooms:FindFirstChild(RoomId)
	
	-- Update viewport
	for _, v in pairs(ItemsToRemove) do
		v:Destroy()
	end

	-- Add room(s) to viewport
	if CurrentRooms:FindFirstChild(RoomId - 1) then
		MoveRoomToViewport(CurrentRooms[RoomId - 1]) -- Previous room
	end

	MoveRoomToViewport(CurrentRoom) -- Current room

	if CurrentRooms:FindFirstChild(RoomId + 1) then
		MoveRoomToViewport(CurrentRooms[RoomId + 1]) -- Next room
	end

	-- Mark objects in room(s)
	local ToFind = {
		"LeverForGate"
	}

	for _, v in next, CurrentRoom:QueryDescendants("ProximityPrompt") do
		local ancestor = v:FindFirstAncestorWhichIsA("Model")
		if
			v.Name == "ModulePrompt"
			or v.Name == "HidingPrompt"
			or table.find(ToFind, ancestor.Name)
		then
			MarkObject(ancestor, v)
		end
	end
end

local OGLight = Scanner.Handle.Screen.SurfaceLight.Brightness

function On()
	DisplayStatic()
	OffS.Visible = false
	--Scanner.Handle.Idle:Play()
	
	TweenService:Create(Scanner.Handle.Screen.SurfaceLight, TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),{
		Brightness = OGLight
	}):Play()
	
	State = true
	
	Update()
	
	Connections.CurrentRoomChanged = Plr:GetAttributeChangedSignal("CurrentRoom"):Connect(function()
		if State then
			DisplayStatic()
			Update()
		end
	end)
	
	task.spawn(function()
		while RunService.PreRender:Wait() do
			if not State then 
				break 
			end
			
			for _,v in pairs(Stars) do
				v.CFrame = CFrame.lookAt(v.Position, Scanner.Handle.Position)
			end
			
			CameraStaticMover(UI.Static1)
			CameraStaticMover(UI.Static2)
			
			UI.Camera.CFrame = Scanner.Handle.CFrame * CFrame.Angles(0, math.rad(180), 0) * CFrame.new(0, 0, -.3)
		end
	end)
end

function Off()
	task.spawn(function()
		TurnOffAnimation()
	end)
	
	task.spawn(function()
		TweenService:Create(Scanner.Handle.Screen.SurfaceLight, TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),{
			Brightness = 0
		}):Play()
	end)
	
	for _, v in pairs(Connections) do
		v:Disconnect()
	end
	Connections = {}
	
	State = false
end

function OffUnequip()
	UI.Enabled = false
	UI.ViewNormal.CurrentCamera = nil
	UI.ViewSpecial.CurrentCamera = nil
	
	Off()
end

function OnEquip()
	UI.Enabled = true
	UI.ViewNormal.CurrentCamera = UI.Camera
	UI.ViewSpecial.CurrentCamera = UI.Camera
	
	On()
end

Scanner.Equipped:Connect(OnEquip)
Scanner.Unequipped:Connect(OffUnequip)
Scanner.Activated:Connect(Switch)

UI.Parent = Plr.PlayerGui
Scanner.Parent = Plr.Backpack
