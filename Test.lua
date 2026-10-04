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

for _, Object in ipairs(Scanner:GetDescendants()) do
	if Object:IsA("BasePart") then
		Object.Color = MainOrange
	end
end

local Handle = Scanner:FindFirstChild("Handle")

if Handle then
	local Screen = Handle:FindFirstChild("Screen")

	if Screen then
		for _, Object in ipairs(Screen:GetDescendants()) do
			if Object:IsA("BasePart") then
				Object.Color = DarkOrange
			end
		end

		local SurfaceLight = Screen:FindFirstChildWhichIsA("SurfaceLight")
		if SurfaceLight then
			SurfaceLight.Color = GlowOrange
		end
	end
end

local UI = Assets.ScreenUICrystal 
local OffS = UI.OffScreen 
