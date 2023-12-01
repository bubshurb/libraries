--[=[ 
	@prop defaultUserThumbnail "rbxassetid://0"
	@within playersUtil
]=]

--[=[ 
	@class playersUtil

	A simple utility module for working with the Players service.
]=]

local Players = game:GetService("Players")

local Promise = require(script.Parent.Promise)

local DEFAULT_RETRY_TIMES = 3

local nameFromUserIdCache = {}
local userIdFromNameCache = {}

local playersUtil = {
	defaultUserThumbnail = "rbxassetid://0",
}

--[=[ 
	Returns a promise which is based off of [Promise.retry](https://eryn.io/roblox-lua-promise/api/Promise#retry), wrapped over
	[Players:GetUserThumbnailAsync](https://create.roblox.com/docs/reference/engine/classes/Players#GetUserThumbnailAsync). 

	The returned promise will retry upto `retryTimes` (or `3` times, if `retryTimes` is not specified).
]=]

function playersUtil.playerThumbnailPromise(
	userId: number,
	thumbnailType: Enum.ThumbnailType,
	thumbnailSize: Enum.ThumbnailSize,
	retryTimes: number?
)
	return Promise.retry(function(userId, thumbnailType, thumbnailSize)
		return Promise.new(function(resolve)
			local content, isReady =
				Players:GetUserThumbnailAsync(userId, thumbnailType, thumbnailSize)

			if isReady then
				resolve(content)
			end
		end)
	end, retryTimes or DEFAULT_RETRY_TIMES, userId, thumbnailType, thumbnailSize)
end

--[=[ 
	Returns a player from the given instance, if found. This is an efficient
	wrapper over [Players:GetPlayerFromCharacter](https://create.roblox.com/docs/reference/engine/classes/Players#GetPlayerFromCharacter).
 
	```lua
	laser.Touched:Connect(function(hit)
		local player = playerUtil.playerFromInstance(hit)

		if player then
			-- Damage the player
		end
	end)
	```
]=]

function playersUtil.playerFromInstance(instance: Instance): Player?
	while instance ~= nil do
		local player = Players:GetPlayerFromCharacter(instance)
		if player then
			return player
		end

		instance = instance.Parent
	end

	return nil
end

--[=[
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with the user name
	associated to the user id. 

	:::tip Caching behavior
	This method will immediately cache in the name (retrieved from the given user id), so calls
	for the same user id will return in cached user name immediately.
	:::

	```lua
	playersUtil.nameFromUserId(2981707497):andThen(function(userName)
		print(userName) --> "bubshurb"
	end)
	```

	@return Promise<string>
]=]

function playersUtil.nameFromUserId(userId: number)
	if nameFromUserIdCache[userId] ~= nil then
		return Promise.resolve(nameFromUserIdCache[userId])
	end

	local playerFromUserId = Players:GetPlayerByUserId(userId)
	if playerFromUserId then
		nameFromUserIdCache[userId] = playerFromUserId.Name
		return Promise.resolve(nameFromUserIdCache[userId])
	end

	local promise = Promise.new(function(resolve)
		resolve(Players:GetNameFromUserIdAsync(userId))
	end)

	promise
		:andThen(function(userName)
			nameFromUserIdCache[userId] = userName
		end)
		:catch(function() end)

	return promise
end

--[=[
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with the user id 
	associated to the username.

	:::tip Caching behavior
	This method will immediately cache in the user id (retrieved from the given username), so calls
	for the same username will return in cached user id immediately.
	:::

	```lua
	playersUtil.userIdFromName("bubshurb"):andThen(function(userId)
		print(userId) --> 2981707497
	end)
	```

	@return Promise<number>
]=]

function playersUtil.userIdFromName(userName: string)
	if userIdFromNameCache[userName] ~= nil then
		return Promise.resolve(userIdFromNameCache[userName])
	end

	local playerFromUserName = Players:FindFirstChild(userName)
	if playerFromUserName then
		userIdFromNameCache[userName] = playerFromUserName.UserId
		return Promise.resolve(userIdFromNameCache[userName])
	end

	local promise = Promise.new(function(resolve)
		resolve(Players:GetUserIdFromNameAsync(userName))
	end)

	promise
		:andThen(function(userId)
			userIdFromNameCache[userName] = userId
		end)
		:catch(function() end)

	return promise
end

return table.freeze(playersUtil)
