--[=[
	@class instanceTagUtil

	A utility module for working with instance tags.
]=]

local CollectionService = game:GetService("CollectionService")

local Promise = require(script.Parent.Promise)
local Connection = require(script.Parent.Connection)

local instanceTagUtil = {}

--[=[
	@return Connection
	
	Observes the given [CollectionService](https://create.roblox.com/docs/reference/engine/classes/CollectionService) tag.
	`callbackAdded` will be automatically called on all instances with the given tag, and `callbackRemoved` (if specified)
	will be automatically called on an instance whenever it *no longer* has the given tag.

	```lua
	instanceTagUtil.observe("SomeTag", function(instanceAdded)
		
	end, function(instanceRemoved)
		
	end)
	```
]=]

function instanceTagUtil.observe(
	tag: string,
	callbackAdded: (instance: Instance) -> (),
	callbackRemoved: ((instance: Instance) -> ())?
)
	for _, instance in CollectionService:GetTagged(tag) do
		task.spawn(callbackAdded, instance)
	end

	local connections = {
		CollectionService:GetInstanceAddedSignal(tag):Connect(callbackAdded),
		if callbackRemoved ~= nil
			then CollectionService:GetInstanceRemovedSignal(tag):Connect(callbackRemoved)
			else nil,
	}

	return Connection.new(function()
		for _, connection in connections do
			connection:Disconnect()
		end
	end)
end

--[=[
	Returns a promise which is resolved when the given instance has the passed tag.
	The returned promise will be cancelled if `instance` is destroyed.

	```lua
	instanceTagUtil.instanceTagPromise(instance, "SomeTag", function()
		print(instance.Name, "has tag 'SomeTag'")
	end)
	```
]=]

function instanceTagUtil.instanceTagPromise(instance: Instance, tag: string)
	local promise = Promise.new(function(resolve)
		if instance:HasTag(tag) then
			resolve()
			return
		end

		CollectionService:GetInstanceAddedSignal(instance):Wait()
		resolve()
	end)

	local instanceDestroyingConnection = instance.Destroying:Once(function()
		promise:cancel()
	end)

	promise:finally(function()
		instanceDestroyingConnection:Disconnect()
	end)

	return promise
end

--[=[
	Adds all tags in `tags` to the given instance as [CollectionService](https://create.roblox.com/docs/reference/engine/classes/CollectionService) tags.

	```lua
	instanceTagUtil.addTagsToInstance(workspace.Baseplate, {"Test"})
	print(CollectionService:HasTag(workspace.Baseplate, "Test")) --> true
	```
]=]

function instanceTagUtil.addTagsToInstance(instance: Instance, tags: { string })
	for _, tag in tags do
		CollectionService:AddTag(instance, tag)
	end
end

--[=[
	Removes all tags in `tags` (which were tagged to the given instance as [CollectionService](https://create.roblox.com/docs/reference/engine/classes/CollectionService) tags) from the given instance.

	```lua
	instanceTagUtil.addTagsToInstance(workspace.Baseplate, {"Test"})
	print(CollectionService:HasTag(workspace.Baseplate, "Test")) --> true
	instanceTagUtil.removeTagsFromInstance(workspace.Baseplate, {"Test"})
	print(CollectionService:HasTag(workspace.Baseplate, "Test")) --> false
	```
]=]

function instanceTagUtil.removeTagsFromInstance(instance: Instance, tags: { string })
	for _, tag in tags do
		CollectionService:RemoveTag(instance, tag)
	end
end

return table.freeze(instanceTagUtil)
