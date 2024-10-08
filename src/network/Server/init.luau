--[=[
	@class NetworkServer
	@server

	The server counterpart of [network].
]=]

--[=[ 
	@prop RemoteProperty RemoteProperty
	@within NetworkServer
	@tag Read only
]=]

--[=[ 
	@prop RemoteProperty RemoteProperty
	@within NetworkServer
	@tag Read only
]=]

--[=[ 
	@interface DefaultNetworkServerConfig 
	@within NetworkServer
	.automaticArgumentSerializationAndDeserializationEnabled true
	.promisifyCallbacks true
]=]

--[=[
	@interface DefaultNetworkServerMiddleware
	@within NetworkServer
	.methodCallInbound {}
	.methodCallOutbound {}
	.valueDispatch {}
]=]

--[=[ 
	@interface NetworkServerConfig 
	@within NetworkServer
	.automaticArgumentSerializationAndDeserializationEnabled boolean -- determines whether or not values sent to clients by the remote signal be internally serialized/deserialized or not.
	.promisifyCallbacks boolean -- determines whether or not a promise is returned to the client (resolved with the return values of the callback) whenever they call a serverside exposed callback

	:::warning Remote Signal and Remote Property not subject to automatic serialization / deserialization!
	[RemoteSignal] and [RemoteProperty] objects sent across the network by the network object will never be
	serialized or deserialized, regardless of `automaticArgumentSerializationAndDeserializationEnabled`. They're
	handled internally to ensure they are properly replicated across the network.
	:::

	- `automaticArgumentSerializationAndDeserializationEnabled` -> `true`
		- Arguments and values sent across the network by the network object
		will be automatically serialized and deserialized respectively, with the
		help of an internal library, i.e [serializerUtil](https://babypatrick100.github.io/libraries/api/serializerUtil/).

		::note Serialization and deserialization limitations!
		While the serializer utility used to accomplish this supports a variety of data types, do keep in mind that not all data types
		can be supported on the go for serialization and deserialization - check the above hyperlink to the serializer utility on how
		many data types it supports.
		::::

		**See the type of the value of `abc` being `TweenInfo` on the client**:

		```lua
		-- Server
		local Workspace = game:GetService("Workspace")

		local testNetwork = network.Server.new("TestNetwork", nil, {
			automaticArgumentSerializationAndDeserializationEnabled = true
		})
		testNetwork:append("abc", TweenInfo.new()) -- By default, TweenInfos
		-- are not replicated properlty across the  network, but watch the magic!
		testNetwork:dispatch(Workspace)

		-- Client
		local Workspace = game:GetService("Workspace")

		local testNetwork = network.client.fromParent("TestNetwork", Workspace):expect()
		print(typeof(testNetwork.abc)) --> "TweenInfo"
		```
	- `automaticArgumentSerializationAndDeserializationEnabled` -> `false`
		- Arguments and values sent across the network will not be internally serialized
		and deserialized. Using the same example as above:

		**See the type of the value of `abc` being `table` on the client instead of `TweenInfo`**:

		```lua
		-- Server
		local Workspace = game:GetService("Workspace")

		local testNetwork = network.Server.new("TestNetwork", nil, {
			automaticArgumentSerializationAndDeserializationEnabled = false
		})
		testNetwork:append("abc", TweenInfo.new())
		testNetwork:dispatch(Workspace)

		-- Client
		local Workspace = game:GetService("Workspace")

		local testNetwork = network.client.fromParent("abc", Workspace):expect()
		print(typeof(testNetwork.abc)) --> "table"
		```

	- `promisifyCallbacks` -> `true`:

		Serverside exposed callback called on the client will immediately return a promise which will be resolved
		with the return values of the callback.

		```lua
		-- Server
		local Workspace = game:GetService("Workspace")

		local testNetwork = network.Server.new("TestNetwork", nil, {
			promisifyCallbacks = true
		})
		testNetwork:append("method", function() return task.wait(5) end)
		testNetwork:dispatch(Workspace)

		-- Client
		local Workspace = game:GetService("Workspace")

		local testNetwork = network.client.fromParent("abc", Workspace):expect()
		testNetwork.method():andThen(function(deltaTime)
			print(typeof(deltaTime)) --> "number"
		end)
		```
	- `promisifyCallbacks` -> `false`:
	
		Serverside exposed callback called on the client will **not** return a promise and instead
		will yield the given thread until the callback has returned back to the caller.

		```lua
		-- Server
		local Workspace = game:GetService("Workspace")

		local testNetwork = network.Server.new("TestNetwork", nil, {
			promisifyCallbacks = false
		})
		testNetwork:append("method", function() return task.wait(5) end)
		testNetwork:dispatch(Workspace)

		-- Client
		local Workspace = game:GetService("Workspace")

		local testNetwork = network.client.fromParent("abc", Workspace):expect()
		print(typeof(testNetwork.method())) --> "number" (Thread is yielded for approx 5 seconds)
		```
]=]

--[=[ 
	@type NetworkServer NetworkServer
	@within NetworkServer
]=]

--[=[
	@interface NetworkServerMiddleware
	@within NetworkServer
	.methodCallInbound (methodName: string, client: Player, args: {any}) -> boolean -- Before a callback runs.
	.methodCallOutbound (methodName: string, client: Player, args: {any}, methodResponse: any) -> any -- After a callback has finished running.
	.valueDispatch (client: Player, value: any) -> any -- Affects the return value of the callbacks (to the clients) after they've run.

	:::warning Yielding in middleware callbacks is not allowed
	Middleware callbacks aren't allowed to yield. If they do so, their thread will be closed via
	[coroutine.close](https://create.roblox.com/docs/reference/engine/libraries/coroutine#close) and an
	error will be outputted in the console.

	Yielding, (especially in network-related code) results in weird bugs and behavior which can be hard to track down!
	:::

	### `methodCallInbound` 

	Callbacks in `methodCallInbound` are called whenever a client tries to call any of the appended methods of the network. 

	The first argument passed to each callback is the name of the method (the client called), and the second argument, i.e 
	the arguments sent by the client, which are packed into an array. 
	
	```lua
	local methodCallInboundCallbacks = {
		function (methodName, client: Player, arguments)
			print(client:IsA("Player")) --> true 
			print(typeof(arguments)) --> "table"
		end
	}
	---
	```

	:::tip More control
	- If any of the callbacks return an **explicit** false value, then the method which the client tried to call, will *not* be
	called. This is useful as you can implement for e.g, implementing rate limits!

	- Additionally, you can modify the `arguments` table which will be reflected in the method, for e.g:

	```lua
	-- Server
	local Workspace = game:GetService("Workspace")
	local testNetwork = network.Server.new("TestNetwork", {methodCallInbound = {
		function(_, _, arguments) 
			arguments[2] = "test"
		end
	}})
	testNetwork:append("method", function(player, a)
		print(a) --> "test" (a ought to be 1, but the middleware modified it!)
	end)
	testNetwork:dispatch(Workspace)

	-- Client
	local Workspace = game:GetService("Workspace")

	local testNetwork = network.client.fromParent("TestNetwork", Workspace):expect()
	testNetwork.method(1) 
	```
	:::

	### `methodCallOutbound` 

	Callbacks in `methodCallOutbound` are called whenever a method (appended to the network) is called by the client, and 
	has **finished** running.  

	The first argument passed to each callback is the name of the method (client called), and the second argument, i.e 
	the arguments sent by the client, which are packed into an array. 

	A third argument i.e `methodResponse` is passed to each callback as well, which is just the response of the method called. 

	```lua
	local methodCallOutboundCallbacks = {
		function (methodName, client: Player, arguments, methodResponse)
			print(client:IsA("Player")) --> true 
			print(typeof(arguments)) --> "table"
		end
	}
	---
	```
	
	Additionally, these callbacks can return a value that overrides the actual result of the method (which will be sent
	back to the client). For e.g:

	```lua
	-- Server:
	local Workspace = game:GetService("Workspace")

	local middleware = {
		{
			function (methodName, arguments, methodResponse)
				print(methodResponse) --> "this"
				return 50
			end
		}
	}

	local testNetwork = network.Server.new("TestNetwork", middleware)
	testNetwork:append("someMethod", function()
		return "this"
	end)
	testNetwork:dispatch(Workspace)

	-- Client:
	local Workspace = game:GetService("Workspace")

	local testNetwork = network.fromParent("TestNetwork", Workspace):expect()
	print(testNetwork.someMethod()) --> 50 
	```

	Additionally, if more than 1 callback returns a value, then all those returned values will be packed into an array and *then* sent
	back to the client. This is by design, as it isn't ideal to disregard all returned values for just 1.
	
	For e.g: 
	
	```lua
	-- Server:
	local Workspace = game:GetService("Workspace")

	local middleware = {
		{
			function (methodName, arguments, response)
				return 1
			end,

			function (methodName, arguments, response)
				return 2
			end,

			function (methodName, arguments, response)
				return 3
			end
		}
	}

	local testNetwork = network.server.new("TestNetwork", middleware)
	testNetwork:append("someMethod", function()
		return "this"
	end)
	testNetwork:dispatch(Workspace)

	-- Client:
	local Workspace = game:GetService("Workspace")

	local testNetwork = network.client.fromParent("TestNetwork", Workspace):expect()
	print(testNetwork.someMethod()) --> {1, 2, 3} 
	```

	### `valueDispatch` 

	Callbacks in `valueDispatch` are called whenever the network object replicates a value (**specifically a non function and not a remote signal
	and not a remote property**), e.g a table, number, string, etc.

	The first argument passed to each callback is the client itself whom the value is going to replicate to, and the value.
	
	```lua
	local valueDispatchCallbacks = {
		function (client, value)
			---
		end,
	   
	}
	---
	```

	The return value of the callback will be used in favour of the original value. If more than 1 callback returns
	a value, all of them will be packed into an array and *then* sent.

	```lua
	local Workspace = game:GetService("Workspace")
	
	-- Server
	local valueDispatchCallbacks = {
		function (client, value)
			return {
				test = 1
			}
		end,
	   
	}

	local testNetwork = network.Server.new("TestNetwork", {valueDispatch = valueDispatchCallbacks})
	testNetwork:append("someValue", 5)
	testNetwork:dispatch(Workspace)

	-- Client
	local Workspace = game:GetService("Workspace")

	local testNetwork = network.client.fromParent("TestNetwork", Workspace):expect()
	print(testNetwork.someValue) --> {test = 1} (this thought to be 5, but the middleware returned a table instead)
	```

	```lua
	-- Server
	local Workspace = game:GetService("Workspace")
	
	local valueDispatchCallbacks = {
		function (client, value)
			print(value) --> 5
			return 1
		end,
		
		function (client, value)
			print(value) --> 5
		 	return 2
		end
	}

	local testNetwork = network.Server.new("TestNetwork", {valueDispatch = valueDispatchCallbacks})
	testNetwork:append("someValue", 5)
	testNetwork:dispatch(Workspace)

	-- Client
	local Workspace = game:GetService("Workspace")

	local testNetwork = network.client.fromParent("TestNetwork", Workspace):expect()
	print(testNetwork.someValue) --> {1, 2}
	---
	```

	:::tip More control
	- If any of the callbacks return a `nil` value, then the value will not be replicated to the client. For e.g:

	```lua
	local Workspace = game:GetService("Workspace")
	
	-- Server
	local valueDispatchCallbacks = {
		function (client, value)
			return nil
		end,
	   
	}

	local testNetwork = network.Server.new("TestNetwork", {valueDispatch = valueDispatchCallbacks})
	testNetwork:append("someValue", 5)
	testNetwork:dispatch(Workspace)

	-- Client
	local Workspace = game:GetService("Workspace")

	local testNetwork = network.client.fromParent("TestNetwork", Workspace):expect()
	print(testNetwork.someValue) --> nil (this thought to be 5, but the middleware returned a nil value instead)
	```
	:::
]=]

local Trove = require(script.Parent.Parent.Trove)
local Sift = require(script.Parent.Parent.Sift)
local Promise = require(script.Parent.Parent.Promise)
local networkUtil = require(script.Parent.utilities.networkUtil)
local RemoteSignal = require(script.RemoteSignal)
local Signal = require(script.Parent.Parent.Signal)
local RemoteProperty = require(script.RemoteProperty)
local sharedEnums = require(script.Parent.sharedEnums)

local DEFAULT_NETWORK_SERVER_MIDDLEWARE_TEMPLATE = {
	methodCallOutbound = {},
	methodCallInbound = {},
	valueDispatch = {},
}

local DEFAULT_NETWORK_SERVER_CONFIG_TEMPLATE = table.freeze({
	automaticArgumentSerializationAndDeserializationEnabled = true,
	promisifyCallbacks = true,
})

local networks = {}
local onNetworkCreated = Signal.new()

local NetworkServer = {
	RemoteProperty = RemoteProperty,
	RemoteSignal = RemoteSignal,
	__index = {},
}

--[=[
	@param middleware NetworkServerMiddleware?
	@param networkServerConfig NetworkServerConfig?

	Creates and returns a new network object of `name`.

	```lua
	-- Server:
	local network = NetworkServer.new("Test")
	network:append("key", "some value")
	network:dispatch(game:GetService("ReplicatedStorage"))

	-- Client:
	local network = network.Client.fromParent("Test", game:GetService("ReplicatedStorage")):expect()
	print(network.key) --> "some value"
	```

	- If the 2nd parameter `middleware` is not specified, then it will default to [DefaultNetworkServerMiddleware] instead.
	- If the 3rd parameter `networkServerConfig` is not specified, then it will default to [DefaultNetworkServerConfig] instead.

	:::warning Network object will initially not be accessible to the client!
	The network object will initially not be accessible to the client. You need to call [NetworkServer:dispatch] 
	to render the network object accessible to the client!
	:::
]=]

function NetworkServer.new(
	name: string,
	middleware: {
		methodCallOutbound: {
			(
				methodName: string,
				client: Player,
				args: { any },
				methodResponse: any
			) -> any
		}?,

		methodCallInbound: { (methodName: string, client: Player, args: { any }) -> boolean }?,
		valueDispatch: { (client: Player, value: any) -> any },
	}?,
	networkServerConfig: {
		automaticArgumentSerializationAndDeserializationEnabled: boolean,
		promisifyCallbacks: boolean,
	}?
): NetworkServer
	assert(networks[name] == nil, string.format('Network "%s" already exists!', name))

	if middleware ~= nil then
		middleware =
			Sift.Dictionary.mergeDeep(DEFAULT_NETWORK_SERVER_MIDDLEWARE_TEMPLATE, middleware)
	else
		middleware = Sift.Dictionary.copyDeep(DEFAULT_NETWORK_SERVER_MIDDLEWARE_TEMPLATE)
	end

	if networkServerConfig ~= nil then
		networkServerConfig =
			Sift.Dictionary.mergeDeep(DEFAULT_NETWORK_SERVER_CONFIG_TEMPLATE, networkServerConfig)
	else
		networkServerConfig = Sift.Dictionary.copyDeep(DEFAULT_NETWORK_SERVER_CONFIG_TEMPLATE)
	end

	local self = setmetatable({
		_name = name,
		_trove = Trove.new(),
		_middleware = middleware,
		_networkServerConfig = networkServerConfig,
	}, NetworkServer)

	self:_init()
	return self
end

--[=[
	@return NetworkServer?

	Returns a network of the given name, if found.

	```lua
	-- Script 1:
	local network = NetworkServer.new("Test")
	network:append("key", "some value")
	network:dispatch(game:GetService("ReplicatedStorage"))

	-- Script 2:
	local testNetwork = NetworkServer.fromName("Test")
	```
]=]

function NetworkServer.fromName(name: string): NetworkServer?
	return networks[name]
end

--[=[
	@return Promise<NetworkServer>

	RemotePromisified version of [NetworkServer.fromName].

	```lua
	-- Script 1:
	local network = NetworkServer.new("Test")
	network:append("key", "some value")
	network:dispatch(game:GetService("ReplicatedStorage"))

	-- Script 2:
	NetworkServer.fromNamePromise("Test"):andThen(function(testNetwork)
		print(testNetwork:dispatch()) 
	end)
	```
]=]

function NetworkServer.fromNamePromise(name: string)
	if networks[name] then
		return Promise.resolve(networks[name])
	end

	return Promise.new(function(resolve)
		while networks[name] == nil do
			onNetworkCreated:Wait()
		end

		resolve(networks[name])
	end)
end

--[=[
	Returns a boolean indicating if `self` is a network object or not.
]=]

function NetworkServer.is(self: any): boolean
	return getmetatable(self) == NetworkServer
end

--[=[
	@tag NetworkServer instance

	Returns a boolean indicating if the network object is dispatched to the 
	client or not. 
]=]

function NetworkServer.__index:dispatched(): boolean
	return self._networkFolder.Parent ~= nil
end

--[=[
	@tag NetworkServer instance

	Appends a key-value pair, `key` and `value`, to the network object, so that
	it is available to the client once the network object is dispatched. 

	For e.g:

	```lua
	-- Server
	local Workspace = game:GetService("Workspace")

	local testNetwork = network.Server.new("TestNetwork")
	testNetwork:append("key", "the value!")
	testNetwork:dispatch(Workspace)

	-- Client
	local testNetwork = Network.client.fromParent("TestNetwork", Workspace):expect()
	print(testNetwork.key) --> "the value!"
	```

	:::tip More support
	You can also append a [RemoteSignal] and a [RemoteProperty] as well, they'll be represented as a [ClientRemoteSignal] and a [ClientRemoteProperty]
	to the client respectively!
	::: 

	:::note Precaution!
	If the network object does not have a default middleware (`AutomaticArgumentSerializationAndDeserialization` specifically) set, 
	then [argument limitations](https://create.roblox.com/docs/scripting/events/argument-limitations-for-bindables-and-remotes)
	will apply, as remote functions are internally used the key-value pairs accessible to the clients.
	:::

	:::warning
	This method will error if the network object is dispatched to the client. 
	Always make sure to append keys and values *before* you dispatch the 
	network object. You can check if a network object is dispatched to the 
	client or not through [NetworkServer:dispatched].
	:::
]=]

function NetworkServer.__index:append(
	key: string,
	value: string | number | { number } | { [string]: any } | RemoteProperty.RemoteProperty | RemoteSignal.RemoteSignal
)
	assert(
		not self:dispatched(),
		string.format(
			"Cannot append key value pair ([%s]: %s) as network object is dispatched to the client!",
			key,
			tostring(value)
		)
	)

	self:_setup(key, value)
end

--[=[
	@tag NetworkServer instance

	Dispatches the network folder of the network object to `parent`, rendering
	the network object accessible to the client now. 

	```lua
	-- Server
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Workspace = game:GetService("Workspace")

	local network = require(ReplicatedStorage.Packages.network) 

	local testNetwork = Network.Server.new("Test")
	testNetwork:append("method", function(player)
		return string.format("hi, %s!", player.Name)
	end)

	-- Dispatch the network to workspace:
	testNetwork:dispatch(Workspace) 

	-- Client
	local Workspace = game:GetService("Workspace")

	local testNetwork = network.client.fromParent("Test", Workspace):expect()
	print(testNetwork.method()) --> "hi, bubshurb!"
	```
]=]

function NetworkServer.__index:dispatch(parent: Instance)
	self._networkFolder.Parent = parent
end

--[=[
	@tag NetworkServer instance
	
	Destroys the network object and all appended remote properties &
	remote signals within the network object, and renders the network 
	object useless. 
]=]

function NetworkServer.__index:destroy()
	self._trove:Destroy()
end

function NetworkServer.__index:_setupRemoteObject(key, value)
	(value :: any):dispatch(key, self._networkFolder)

	self._trove:Add(function()
		if not RemoteProperty.is(value) or not RemoteSignal.is(value) then
			return
		end

		(value :: any):destroy()
	end)
end

function NetworkServer.__index:_setup(key, value)
	local keyRemoteFunction = self._networkFolder:FindFirstChild(key)
	if keyRemoteFunction ~= nil then
		error(
			string.format(
				'Attempt to append value of key "%s" again. Key already exists as a value of type "%s"!',
				key,
				keyRemoteFunction:GetAttribute(sharedEnums.Attribute.RemoteValueType)
			)
		)
	end

	if RemoteSignal.is(value) or RemoteProperty.is(value) then
		self:_setupRemoteObject(key, value)
		return
	end

	local remoteFunction = Instance.new("RemoteFunction")
	remoteFunction:SetAttribute(
		sharedEnums.Attribute.AutomaticRemoteArgumentSerializationAndDeserializationEnabled,
		self._networkServerConfig.automaticArgumentSerializationAndDeserializationEnabled
	)
	if typeof(value) == "function" then
		remoteFunction:SetAttribute(
			sharedEnums.Attribute.RemotePromisified,
			self._networkServerConfig.promisifyCallbacks
		)
	end
	remoteFunction.Name = key
	remoteFunction:SetAttribute(sharedEnums.Attribute.RemoteValueType, typeof(value))
	remoteFunction.Parent = self._networkFolder

	function remoteFunction.OnServerInvoke(client, serializedArgs)
		local deserializedArgs =
			{ networkUtil.deserializeAndUnpackArgs(remoteFunction, serializedArgs) }

		if typeof(value) == "function" then
			local methodCallInboundMiddlewareAccumulatedResponses =
				networkUtil.accumulatedResponseFromMiddlewareCallbacks(
					self._middleware.methodCallInbound,
					key,
					client,
					table.unpack(deserializedArgs)
				)

			-- If there is an explicit false value included in the accumulated
			-- the response of all inbound method callbacks, then that means we should
			-- avoid this client's request to call the method!
			if
				methodCallInboundMiddlewareAccumulatedResponses ~= nil
				and table.find(methodCallInboundMiddlewareAccumulatedResponses, false)
			then
				return
			end

			local methodResponses = { value(client, table.unpack(deserializedArgs)) }
			local methodCallOutboundMiddlewareAccumulatedResponses, methodCallOutboundMiddlewareResponsesAreValid =
				networkUtil.truncateAccumulatedResponses(
					self._middleware.methodCallOutbound,
					networkUtil.accumulatedResponseFromMiddlewareCallbacks(
						self._middleware.methodCallOutbound,
						key,
						client,
						deserializedArgs,
						table.unpack(methodResponses)
					)
				)

			if methodCallOutboundMiddlewareResponsesAreValid then
				return networkUtil.serializeGivenArgs(
					remoteFunction,
					methodCallOutboundMiddlewareAccumulatedResponses
				)
			else
				return networkUtil.serializeGivenArgs(remoteFunction, table.unpack(methodResponses))
			end
		else
			local valueDispatchMiddlewareAccumulatedResponses, valueDispatchMiddlewareResponsesAreValid =
				networkUtil.truncateAccumulatedResponses(
					self._middleware.valueDispatch,
					networkUtil.accumulatedResponseFromMiddlewareCallbacks(
						self._middleware.valueDispatch,
						client,
						value
					)
				)

			return networkUtil.serializeGivenArgs(
				remoteFunction,
				if valueDispatchMiddlewareResponsesAreValid
					then valueDispatchMiddlewareAccumulatedResponses
					else value
			)
		end
	end

	self._trove:Add(function()
		remoteFunction.OnServerInvoke = nil
		remoteFunction:Destroy()
	end)
end

function NetworkServer.__index:_init()
	self:_setupNetworkFolder()
	networks[self._name] = self
	onNetworkCreated:Fire()

	self._trove:Add(function()
		networks[self._name] = nil
		setmetatable(self, nil)
	end)
end

function NetworkServer.__index:_setupNetworkFolder()
	local networkFolder = self._trove:Add(Instance.new("Folder"))
	networkFolder.Name = self._name
	networkFolder:SetAttribute(sharedEnums.Attribute.NetworkFolder, true)
	self._networkFolder = networkFolder
end

export type NetworkServer = typeof(NetworkServer.new(""))

return table.freeze(NetworkServer)
