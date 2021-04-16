--[[

Note that this is not a final product, many new features will be added as I develop this script!

- infiniteraymond

]]

local p = owner

local rss = game:GetService("ReplicatedStorage")

for _,v in pairs(game.ReplicatedStorage:GetChildren()) do
	if v.Name == "Remotes" then
		v.Name = "nilllll"
	end
end

for _, v in pairs(workspace:GetChildren()) do
	if v.Name == p.Name .. "_VR_" then
		v:Destroy()
	end
end

local character = p.Character

local vr = {}
local models = {
	rig = Instance.new("Model")
}

function tween(t,g)
	game:GetService("TweenService"):Create(t,TweenInfo.new(0.5,Enum.EasingStyle.Cubic),g):Play()
end

local remotes = {
	initiate = Instance.new("RemoteEvent");
	update = Instance.new("RemoteEvent");
	summon = Instance.new("RemoteEvent");
}

local lhpL = nil
local rhpL = nil

local usedAlreadyL = false
local usedAlreadyR = false

local cooldownL = 0
local cooldownR = 0

local folder = Instance.new("Folder")
folder.Parent = rss
folder.Name = "Remotes"

remotes.initiate.Parent = folder
remotes.update.Parent = folder
remotes.summon.Parent = folder

remotes.initiate.Name = "VRInit"
remotes.update.Name = "VRUpd"
remotes.summon.Name = "VRSum"

vr.initiate = function()
	print("VR IS WORKING")
	local characterRig = models.rig
	characterRig.Parent = workspace:WaitForChild(p.Name)
	characterRig.Name = p.Name .. "_VR_"

	local h = character.Head:Clone()
	h.Parent = models.rig
	h.Anchored = true

	local la = character["Left Arm"]:Clone()
	la.Parent = models.rig
	la.Anchored = true
	la.Size = Vector3.new(0.5, 1.25, 0.5)

	local ra = character["Right Arm"]:Clone()
	ra.Parent = models.rig
	ra.Anchored = true
	ra.Size = Vector3.new(0.5, 1.25, 0.5)

	local shirt = character.Shirt:Clone()
	shirt.Parent = models.rig

	local hum = character.Humanoid:Clone()
	hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	hum.Parent = models.rig

	for _, v in pairs(character:GetChildren()) do
		if v:IsA("Accoutrement") then
			print("ACCESSORY MODIFIED")
			if v:WaitForChild("Handle"):FindFirstChild("HairAttachment") then
				v:WaitForChild("Handle"):FindFirstChild("AccessoryWeld").Part1 = characterRig.Head
			elseif v:WaitForChild("Handle"):FindFirstChild("HatAttachment") then
				v:WaitForChild("Handle"):FindFirstChild("AccessoryWeld").Part1 = characterRig.Head
			elseif v:WaitForChild("Handle"):FindFirstChild("FaceFrontAttachment") then
				v:WaitForChild("Handle"):FindFirstChild("AccessoryWeld").Part1 = characterRig.Head
			else
				v:Destroy()
			end
		end
	end

	wait(1)

	character.PrimaryPart.CFrame = CFrame.new(0,-20,0)
	character.HumanoidRootPart.Anchored = true
end

vr.update = function(_, data)
	local character = workspace:WaitForChild(p.Name):WaitForChild(p.Name .. "_VR_")
    tween(character:WaitForChild("Head"),{CFrame = data.Head})
	tween(character:WaitForChild("Left Arm"),{CFrame = data.Left})
	tween(character:WaitForChild("Right Arm"),{CFrame = data.Right})

	if data.GrabbingLeft then
		local v = data.GrabbingLeft
		if v:IsA("Part") or v:IsA("MeshPart") then
			if lhpL == nil and (v.Position - character:WaitForChild("Left Arm").Position).magnitude <= 2.5 and not v.Anchored then
				lhpL = v
				print("held " .. v.Name:lower())
				local weld = Instance.new("WeldConstraint")
				weld.Parent = v
				if v.Name == "Pistol" then
					--v.CFrame = character:WaitForChild("Left Arm").CFrame * CFrame.new(0,0,0.75) * CFrame.Angles(math.rad(90),0,0)
				end
				weld.Part0 = character:WaitForChild("Left Arm")
				weld.Part1 = v
				weld.Name = "GrabWeld"
			elseif v:FindFirstChild("VRInteractive") and lhpL == nil and (v.Position - character:WaitForChild("Left Arm").Position).magnitude <= 2.5 then
				lhpL = v
				local weld = Instance.new("WeldConstraint")
				weld.Name = "InteractionWeld"
				weld.Parent = v
				print("interacted with ".. v.Name)
			end
		end
		if data.TriggeringLeft then
			if v.Name == "Pistol" and not usedAlreadyL then
				usedAlreadyL = true
				vr.use("left")
			elseif v.Name == "M4A1" and (tick() - cooldownL) >= 0.1 then
				cooldownL = tick()
				vr.use("left")
			end
		end
	end

	if data.GrabbingRight then
		local v = data.GrabbingRight
		if v:IsA("Part") or v:IsA("MeshPart") then
			if rhpL == nil and (v.Position - character:WaitForChild("Right Arm").Position).magnitude <= 2.5 and not v.Anchored then
				rhpL = v
				print("held " .. v.Name:lower())
				local weld = Instance.new("WeldConstraint")
				weld.Parent = v
				if v.Name == "Pistol" then
				--v.CFrame = character:WaitForChild("Right Arm").CFrame * CFrame.new(0,0,0.75) * CFrame.Angles(math.rad(90),0,0)
				end
				weld.Part0 = character:WaitForChild("Right Arm")
				weld.Part1 = v
				weld.Name = "GrabWeld"
			elseif v:FindFirstChild("VRInteractive") and rhpL == nil and (v.Position - character:WaitForChild("Right Arm").Position).magnitude <= 2.5 then
				rhpL = v
				local weld = Instance.new("WeldConstraint")
				weld.Name = "InteractionWeld"
				weld.Parent = v
				print("interacted with ".. v.Name)
			end
		end
		if data.TriggeringRight then
			if v.Name == "Pistol" and not usedAlreadyR then
				usedAlreadyR = true
				vr.use("right")
			elseif v.Name == "M4A1" and (tick() - cooldownR) >= 0.1 then
				cooldownR = tick()
				vr.use("right")
			end
		end
	end

	if not data.TriggeringRight and usedAlreadyR then
		usedAlreadyR = false
	end

	if not data.TriggeringLeft and usedAlreadyL then
		usedAlreadyL = false
	end

	if lhpL or rhpL then
		if lhpL and not data.GrabbingLeft then
			if lhpL:FindFirstChild("GrabWeld") then
				lhpL:FindFirstChild("GrabWeld"):Destroy()
			end
			if lhpL:FindFirstChild("InteractionWeld") then
				lhpL:FindFirstChild("InteractionWeld"):Destroy()
			end
			local bv = Instance.new("BodyVelocity",lhpL)
			bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
			bv.Velocity = lhpL.CFrame.lookVector*40
			game.Debris:AddItem(bv,0.15)
			lhpL = nil
			print("let go of object on l")
		end
		if rhpL and not data.GrabbingRight then
			if rhpL:FindFirstChild("GrabWeld") then
				rhpL:FindFirstChild("GrabWeld"):Destroy()
			end
			if rhpL:FindFirstChild("InteractionWeld") then
				rhpL:FindFirstChild("InteractionWeld"):Destroy()
			end
			local bv = Instance.new("BodyVelocity",rhpL)
			bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
			bv.Velocity = lhpL.CFrame.lookVector*40
			game.Debris:AddItem(bv,0.15)
			rhpL = nil
			print("let go of object on r")
		end
	end


	-- Temporarily Removed as it breaks way too much

	if lhpL and rhpL then
		if (rhpL.Name == "Torso" or rhpL.Name == "HumanoidRootPart") then
			if (lhpL.Name == "Head" or lhpL.Name == "Handle") then
				if lhpL.Name == "Handle" and not lhpL:FindFirstChild("HatAttachment") then return end
				if (lhpL.Position - rhpL.Position).magnitude >= 2 then
					if lhpL.Name == "Handle" then
						lhpL.Parent.Parent:FindFirstChild("Humanoid").Health = 0
					else
						lhpL.Parent:FindFirstChild("Humanoid").Health = 0
					end
				end
			end
		elseif (lhpL.Name == "Torso" or lhpL.Name == "HumanoidRootPart") then
			if (rhpL.Name == "Head" or rhpL.Name == "Handle") then
				if rhpL.Name == "Handle" and not rhpL:FindFirstChild("HatAttachment") then return end
				if (rhpL.Position - lhpL.Position).magnitude >= 2 then
					if rhpL.Name == "Handle" then
						rhpL.Parent.Parent:FindFirstChild("Humanoid").Health = 0
					else
						rhpL.Parent:FindFirstChild("Humanoid").Health = 0
					end
				end
			end
		end
	end


end

vr.summon = function(_, guntype)
	local gun
	if guntype == "Pistol" then
		gun = Instance.new("Part")
		gun.Name = "Pistol"
		gun.CFrame = workspace:WaitForChild(p.Name):WaitForChild(p.Name .. "_VR_").Head.CFrame * CFrame.new(0,0,-5)
		gun.CanCollide = true
		gun.Size = Vector3.new(0.25, 0.7, 0.25)

		local mesh = Instance.new("SpecialMesh")
		mesh.Parent = gun
		mesh.MeshId = "rbxassetid://1470036430"
		mesh.TextureId = "rbxassetid://1470036477"
		mesh.Offset = Vector3.new(0,0,-0.4)
		mesh.Scale = Vector3.new(0.025,0.025,0.025)

		gun.Parent = workspace
	elseif guntype == "M4A1" then
		gun = Instance.new("Part")
		gun.Name = "M4A1"
		gun.CFrame = workspace:WaitForChild(p.Name):WaitForChild(p.Name .. "_VR_").Head.CFrame * CFrame.new(0,0,-5)
		gun.CanCollide = true
		gun.Size = Vector3.new(0.25, 0.7, 0.25)

		local mesh = Instance.new("SpecialMesh")
		mesh.Parent = gun
		mesh.MeshId = "rbxassetid://477116314"
		mesh.TextureId = "rbxassetid://477116318"
		mesh.Offset = Vector3.new(0,0,-0.7)
		mesh.Scale = Vector3.new(0.025,0.025,0.025)

		gun.Parent = workspace
	end
	local sound = Instance.new("Sound")
	sound.Parent = gun
	sound.Name = "GunShot"
	sound.SoundId = "rbxassetid://6661889492"
end

vr.use = function(arm)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {workspace:WaitForChild(p.Name):WaitForChild(p.Name .. "_VR_"), lhpL, rhpL}
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	if arm == "left" and lhpL then
		if lhpL:FindFirstChild("GunShot") then
			lhpL:FindFirstChild("GunShot"):Play()
		end
		local HitRay = workspace:Raycast(lhpL.Position, (lhpL.CFrame * CFrame.new(0,0,-1000)).p, raycastParams)
		local hit
		if HitRay then
			hit = HitRay.Instance
		end
		if lhpL.Name == "M4A1" and hit then
			print("left hit part: " .. hit.Name)
			lhpL:FindFirstChild("GunShot").SoundId = "rbxassetid://3402635080"
			lhpL:FindFirstChild("GunShot").Pitch = 1.3
			if hit.Parent:FindFirstChild("Humanoid") then
				hit.Parent:FindFirstChild("Humanoid").Health -= 5
			end
		elseif lhpL.Name == "Pistol" and hit then
			print("left hit part: " .. hit.Name)
			lhpL:FindFirstChild("GunShot").SoundId = "rbxassetid://3397156561" 
			lhpL:FindFirstChild("GunShot").Pitch = 1.3
			if hit.Parent:FindFirstChild("Humanoid") then
				hit.Parent:FindFirstChild("Humanoid").Health -= 25
			end
		end
	end
	if arm == "right" and rhpL then
		if rhpL:FindFirstChild("GunShot") then
			rhpL:FindFirstChild("GunShot"):Play()
		end
		local HitRay = workspace:Raycast(rhpL.Position, (rhpL.CFrame * CFrame.new(0,0,-1000)).p, raycastParams)
		local hit
		if HitRay then
			hit = HitRay.Instance
		end
		if rhpL.Name == "M4A1" and hit then
			print("right hit part: " .. hit.Name)
			if hit.Parent:FindFirstChild("Humanoid") then
				hit.Parent:FindFirstChild("Humanoid").Health -= 5
			end
		elseif rhpL.Name == "Pistol" and hit then
			print("right hit part: " .. hit.Name)
			if hit.Parent:FindFirstChild("Humanoid") then
				hit.Parent:FindFirstChild("Humanoid").Health -= 25
			end
		end
	end
end

remotes.initiate.OnServerEvent:Connect(vr.initiate)
remotes.update.OnServerEvent:Connect(vr.update)
remotes.summon.OnServerEvent:Connect(vr.summon)

local check
check = game:GetService("RunService").Heartbeat:Connect(function()
	if not game:GetService("Players"):FindFirstChild(p.Name) then
		for _,v in pairs(game.ReplicatedStorage:GetChildren()) do
			if v.Name == "Remotes" then
				v.Name = "nilllll"
			end
		end
		if workspace:FindFirstChild(p.Name .. "_VR_") then
			workspace:FindFirstChild(p.Name .. "_VR_"):Destroy()
		end
		check:Disconnect()

	end
end)

NLS([[
wait(2)

print("Starting VR (Client)...")
function tween(t,g)
	game:GetService("TweenService"):Create(t,TweenInfo.new(0.5,Enum.EasingStyle.Cubic),g):Play()
end
local rss = game:GetService("ReplicatedStorage")
local rs = game:GetService("RunService")
local vr = game:GetService("VRService")
local uis = game:GetService("UserInputService")
local cam = workspace.CurrentCamera
local move = 0
local holdingRight = false
local holdingLeft = false
local trc = false
local tlc = false
local player = game.Players.LocalPlayer
local remotes = {
	initiate = rss:WaitForChild("Remotes"):WaitForChild("VRInit");
	update = rss:WaitForChild("Remotes"):WaitForChild("VRUpd");
	summon = rss:WaitForChild("Remotes"):WaitForChild("VRSum");
}
local function gprtc(cf)
	return cam.CFrame*CFrame.new(cf.p*cam.HeadScale) * (cf - cf.p)
end
if vr.VREnabled then
	print("VR is enabled! Attempting to FireServer..")
	remotes.initiate:FireServer()
	local character = workspace:WaitForChild(player.Name):WaitForChild(player.Name .. "_VR_")
	print("Successfully got ahold of server, and VR player has been created.")
	cam.CameraType = Enum.CameraType.Scriptable
	cam.CFrame = player.Character.Head.CFrame
	for _,v in pairs(player.Character.Humanoid:GetAccessories()) do
		v.Handle.Transparency = 1
	end
	rs.Heartbeat:Connect(function()
		
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = {character}
		raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
		local GroundRay = workspace:Raycast(character:WaitForChild("Head").Position, character:WaitForChild("Head").Position - Vector3.new(0,1000,0), raycastParams)
		local GrabRayR = workspace:Raycast(character:WaitForChild("Right Arm").Position, (character:WaitForChild("Right Arm").CFrame * CFrame.new(0,-250,0)).p - character:WaitForChild("Right Arm").Position, raycastParams)
		local GrabRayL = workspace:Raycast(character:WaitForChild("Left Arm").Position, (character:WaitForChild("Left Arm").CFrame * CFrame.new(0,-250,0)).p - character:WaitForChild("Right Arm").Position, raycastParams)
		
		if GroundRay then
			if not GroundRay.Instance.Parent:FindFirstChild("Humanoid") and not GroundRay.Instance.Parent:IsA("Accoutrement") and not GroundRay.Instance:FindFirstChild("GrabWeld") then
				cam.CFrame = CFrame.new(cam.CFrame.X, GroundRay.Position.Y + 5, cam.CFrame.Z)
			end
		end
		
		local phl = false
		local phr = false
		if holdingRight and GrabRayR then
			phr = GrabRayR.Instance
		end
		if holdingLeft and GrabRayL then
			phl = GrabRayL.Instance
		end
		
		local data = {
			Head = gprtc(vr:GetUserCFrame(Enum.UserCFrame.Head));
			Right = gprtc(vr:GetUserCFrame(Enum.UserCFrame.RightHand)) * CFrame.Angles(90,0,0);
			Left = gprtc(vr:GetUserCFrame(Enum.UserCFrame.LeftHand)) * CFrame.Angles(90,0,0);
			GrabbingRight = phr;
			GrabbingLeft = phl;
			TriggeringRight = trc;
			TriggeringLeft = tlc;
		}
   character:WaitForChild("Head").CFrame = data.Head
	tween(character:WaitForChild("Left Arm"),{CFrame = data.Left})
	tween(character:WaitForChild("Right Arm"),{CFrame = data.Right})

		remotes.update:FireServer(data)

		local offsetCFrame = CFrame.new(character:WaitForChild("Head").CFrame.LookVector)
		cam.CFrame = (cam.CFrame:ToWorldSpace(CFrame.new(offsetCFrame.X/3.5*move, 0, offsetCFrame.Z/3.5*move)))

	end)
else
	print("Uh, sorry, but you can\'t use this script without VR.")
end

function chatted(player, message)
	print(player.Name .. " ".. message)
end

uis.InputChanged:Connect(function(input, processed)
	if input.UserInputType == Enum.UserInputType.Gamepad1 then
		if input.KeyCode == Enum.KeyCode.Thumbstick1 then
			move = input.Position.Y
		end
	end
end)

uis.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.ButtonR1 then
		holdingRight = true
	elseif input.KeyCode == Enum.KeyCode.ButtonL1 then
		holdingLeft = true
	elseif input.KeyCode == Enum.KeyCode.ButtonB then
		remotes.summon:FireServer("M4A1")
	elseif input.KeyCode == Enum.KeyCode.ButtonY then
		remotes.summon:FireServer("Pistol")
	elseif input.KeyCode == Enum.KeyCode.ButtonR2 then
		trc = true
	elseif input.KeyCode == Enum.KeyCode.ButtonL2 then
		tlc = true
	end
end)

uis.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.ButtonR1 then
		holdingRight = false
	elseif input.KeyCode == Enum.KeyCode.ButtonL1 then
		holdingLeft = false
	elseif input.KeyCode == Enum.KeyCode.ButtonR2 then
		trc = false
	elseif input.KeyCode == Enum.KeyCode.ButtonL2 then
		tlc = false
	end
end)

game:GetService("Players").PlayerAdded:Connect(function(p)
	p.Chatted:Connect(function(msg)
		chatted(p, msg)
	end)
end)

for _, p in pairs(game:GetService("Players"):GetChildren()) do
	p.Chatted:Connect(function(msg)
		chatted(p, msg)
	end)
end
local StarterGui = game:GetService("StarterGui")
--StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
StarterGui:SetCore("VRLaserPointerMode", 0)
StarterGui:SetCore("VREnableControllerModels", false)

local playerModule = require(game:GetService("Players").LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"))
local VRFolder = workspace.CurrentCamera:WaitForChild("VRCorePanelParts", math.huge)

while wait(0) do 
	pcall(function()
		VRFolder:WaitForChild("UserGui", math.huge).Parent = nil 
		playerModule:GetControls():Disable()
	end)
end
]], p.Character)
