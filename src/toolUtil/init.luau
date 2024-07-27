--[=[
	@class toolUtil

	A simple utility module for working with tools.
]=]

local playerEventsUtil = require(script.Parent.playerEventsUtil)
local playersUtil = require(script.Parent.playersUtil)

local toolUtil = {}

--[=[
	Returns the owner instance of the given tool, if found.
]=]

function toolUtil.toolOwnerInstance(tool: Tool): Player?
	local playerFromTool = playersUtil.playerFromInstance(tool)
	local toolParent = tool.Parent

	if playerFromTool then
		return playerFromTool
	end

	if toolParent then
		if toolParent:IsA("Backpack") then
			return toolParent.Parent
		end
	end

	return nil
end

--[=[ 
    Places the given tool in the player's backpack and tries to
    equips it on the humanoid.
]=]

function toolUtil.tryPlaceToolInBackpackAndEquip(player: Player, tool: Tool)
	tool.Parent = player.Backpack

	local humanoid = if player.Character
		then player.Character:FindFirstChildWhichIsA("Humanoid")
		else nil

	if humanoid then
		humanoid:EquipTool(tool)
	end
end

--[=[
	Returns the player tool count. `predicate` is called on every tool owned by the player, and\
	each time it returns `true`, the tool count is incremented by 1.
]=]

function toolUtil.playerToolCountPredicate(player: Player, predicate: (tool: Tool) -> boolean)
	local toolCount = 0
	for _, playerTool in toolUtil.playerTools(player) do
		if predicate(playerTool) == true then
			toolCount += 1
		end
	end

	return toolCount
end

--[=[
	Returns an array of all player tools - equipped and enequipped.
]=]

function toolUtil.playerTools(player: Player)
	local tools = player.Backpack:GetChildren()

	if player.Character then
		for _, child in player.Character:GetChildren() do
			if child:IsA("Tool") then
				table.insert(tools, child)
			end
		end
	end

	return table.freeze(tools)
end

--[=[ 
    Returns the current equipped tool by the player.
]=]

function toolUtil.currentEquippedTool(player: Player)
	return if player.Character then player.Character:FindFirstChildWhichIsA("Tool") else nil
end

--[=[ 
	Observes the player for any new tools equipped or unequipped. Also captures
	all the initial tool equipped. 

	```lua
	toolUtil.observePlayerForEquippedTool(player, function(newToolEquipped, oldToolEquipped)
	
	end, function(newToolUnequipped, oldToolUnEquipped)
	
	end)
	```
]=]

function toolUtil.observePlayerForToolsEquippedAndEnequipped(
	player: Player,
	observerForToolEquipped: ((
		newToolEquipped: Tool,
		oldToolEquipped: Tool?
	) -> ())?,
	observerForToolEnequipped: ((
		newToolUnequipped: Tool,
		oldToolUnequipped: Tool?
	) -> ())?
)
	assert(
		observerForToolEquipped ~= nil or observerForToolEnequipped,
		"At least 1 observer should be specified."
	)

	local lastEquippedTool = toolUtil.currentEquippedTool(player)
	local lastEnequippedTool
	if lastEquippedTool and observerForToolEquipped then
		task.spawn(observerForToolEquipped, lastEquippedTool, nil)
	end

	local connections = {}
	table.insert(
		connections,
		playerEventsUtil.usePlayerCharacterAdded(player, function(newPlayerCharacter)
			if observerForToolEquipped then
				table.insert(
					connections,
					newPlayerCharacter.ChildAdded:Connect(function(child)
						if not child:IsA("Tool") then
							return
						end

						task.spawn(observerForToolEquipped, child, lastEquippedTool)
						lastEquippedTool = child
					end)
				)
			end

			if observerForToolEnequipped then
				table.insert(
					connections,
					newPlayerCharacter.ChildRemoved:Connect(function(child)
						if not child:IsA("Tool") then
							return
						end

						task.spawn(observerForToolEnequipped, child, lastEnequippedTool)
						lastEnequippedTool = child
					end)
				)
			end
		end)
	)

	return table.freeze({
		Disconnect = function()
			for _, connection in connections do
				connection:Disconnect()
			end
		end,
	})
end

--[=[ 
	Observes the player's backpack for any new tools added or removed. Also captures
	all initial tools in the player backpack.

	```lua
	toolUtil.observePlayerBackpackForTools(player, function(newToolAdded, oldToolAdded)
	
	end, function(newToolRemoved, oldToolRemoved)
	
	end)
	```
]=]

function toolUtil.observePlayerBackpackForTools(
	player: Player,
	observerForToolAdded: ((
		newToolAdded: Tool,
		oldToolAdded: Tool?
	) -> ())?,
	observerForToolRemoved: ((
		newToolRemoved: Tool,
		oldToolRemoved: Tool?
	) -> ())?
)
	assert(
		observerForToolAdded ~= nil or observerForToolRemoved,
		"At least 1 observer should be specified."
	)

	local connections = {}

	if observerForToolAdded then
		for _, tool in player.Backpack:GetChildren() do
			task.spawn(observerForToolAdded, tool, nil)
		end

		local lastToolAdded
		table.insert(
			connections,
			player.Backpack.ChildAdded:Connect(function(tool)
				task.spawn(observerForToolAdded, tool, lastToolAdded)
				lastToolAdded = tool
			end)
		)
	end

	if observerForToolRemoved then
		local lastToolRemoved
		table.insert(
			connections,
			player.Backpack.ChildRemoved:Connect(function(tool)
				task.spawn(observerForToolRemoved, tool, lastToolRemoved)
				lastToolRemoved = tool
			end)
		)
	end

	return table.freeze({
		Disconnect = function()
			for _, connection in connections do
				connection:Disconnect()
			end
		end,
	})
end

--[=[ 
	Observes the player's backpack and character for any new tools added or removed.

	```lua
	toolUtil.observePlayerForToolOwnership(player, function(newToolOwnershipGranted, oldToolOwnershipGranted)
	
	end, function(newToolOwnershipRemoved, oldToolOwnershipRemoved)
	
	end)
	```
]=]

function toolUtil.observePlayerForToolOwnership(
	player: Player,
	observerForToolOwnershipGranted: ((newTool: Tool, oldTool: Tool?) -> ())?,
	observerForToolOwnershipRemoved: ((newTool: Tool, oldTool: Tool?) -> ())?
)
	assert(
		observerForToolOwnershipGranted ~= nil or observerForToolOwnershipRemoved,
		"At least 1 observer should be specified."
	)

	local connections = {}
	local lastToolOwnershipGranted
	local lastToolOwnershipRemoved
	local lastBackpackTools = {}

	playerEventsUtil.usePlayerCharacterAdded(player, function(newPlayerCharacter)
		if observerForToolOwnershipRemoved then
			for _, lastBackpackTool in lastBackpackTools do
				task.spawn(
					observerForToolOwnershipRemoved,
					lastBackpackTool,
					lastToolOwnershipRemoved
				)
				lastToolOwnershipRemoved = lastBackpackTool
			end

			table.clear(lastBackpackTools)

			table.insert(
				connections,
				player.Backpack.ChildRemoved:Connect(function(toolRemoved)
					if toolRemoved.Parent ~= player.Character then
						task.spawn(
							observerForToolOwnershipRemoved,
							toolRemoved,
							lastToolOwnershipRemoved
						)
						lastToolOwnershipRemoved = toolRemoved
					end
				end)
			)

			table.insert(
				connections,
				newPlayerCharacter.ChildRemoved:Connect(function(childRemoved)
					if not childRemoved:IsA("Tool") or childRemoved.Parent == player.Backpack then
						return
					end

					task.spawn(
						observerForToolOwnershipRemoved,
						childRemoved,
						lastToolOwnershipRemoved
					)
					lastToolOwnershipRemoved = childRemoved
				end)
			)

			table.insert(
				connections,
				player.Backpack.ChildAdded:Connect(function(toolAdded)
					lastBackpackTools = player.Backpack:GetChildren()
				end)
			)

			lastBackpackTools = player.Backpack:GetChildren()
		end

		if observerForToolOwnershipGranted then
			for _, tool in player.Backpack:GetChildren() do
				task.spawn(observerForToolOwnershipGranted, tool, lastToolOwnershipGranted)
				lastToolOwnershipGranted = tool
			end

			local currentEquippedTool = newPlayerCharacter:FindFirstChildWhichIsA("Tool")
			if currentEquippedTool then
				task.spawn(observerForToolOwnershipGranted, currentEquippedTool, nil)
			end

			table.insert(
				connections,
				player.Backpack.ChildAdded:Connect(function(toolAdded)
					task.spawn(observerForToolOwnershipGranted, toolAdded, lastToolOwnershipGranted)
					lastToolOwnershipGranted = toolAdded
				end)
			)

			local lastToolOwnershipGranted
			table.insert(
				connections,
				newPlayerCharacter.ChildAdded:Connect(function(childAdded)
					if not childAdded:IsA("Tool") then
						return
					end

					task.spawn(
						observerForToolOwnershipGranted,
						childAdded,
						lastToolOwnershipGranted
					)
					lastToolOwnershipGranted = childAdded
				end)
			)
		end
	end)

	return table.freeze({
		Disconnect = function()
			for _, connection in connections do
				connection:Disconnect()
			end
		end,
	})
end

return table.freeze(toolUtil)
