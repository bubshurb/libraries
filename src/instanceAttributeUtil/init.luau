local Promise = require(script.Parent.Promise)

--[=[
	@class instanceAttributeUtil

	A utility module for working with instance attributes.
]=]

local instanceAttributeUtil = {}

type Observer = (newAttributeValue: any, oldAttributeValue: any) -> ()

--[=[
	Returns a read only array of all descendants in `instanceTree` which have the
	`desiredAttribute` attribute.
]=]

function instanceAttributeUtil.all(instanceTree: Instance, desiredAttribute: string)
	local captured = {}

	for _, descendant in instanceTree:GetDescendants() do
		if descendant:GetAttribute(desiredAttribute) ~= nil then
			table.insert(captured, descendant)
		end
	end

	return table.freeze(captured)
end

--[=[
	Works similar to [instanceAttributeUtil.observe], but observes an dictionary of 
	attributes instead of a single attribute.

	```lua
	instanceAttributeUtil.observeMany(workspace, workspace:GetAttributes(), function(newAttributes, oldAttributes)
		...
	end)
	```
]=]

function instanceAttributeUtil.observeMany(
	instance: Instance,
	attributesToObserve: { [string]: any },
	observer: Observer
)
	local attributesToObserveNew = table.clone(attributesToObserve)
	local attributesToObserveOld = table.clone(attributesToObserve)
	task.spawn(observer, attributesToObserveNew, nil)

	return instance.AttributeChanged:Connect(function(attribute, newAttributeValue)
		if attributesToObserve[attribute] == nil then
			return
		end

		attributesToObserveNew[attribute] = newAttributeValue
		task.spawn(observer, attributesToObserveNew, attributesToObserveOld)
		attributesToObserveOld[attribute] = newAttributeValue
	end)
end

--[=[
	Sets up an event connection which listens to any descendant added to `instanceTree`, if it has the
	`desiredAttribute` atribute, then `callback` will be called.

	```lua
	instanceAttributeUtil.new(workspace, "Test", function(instance)
		print(instance)
	end)
	```
]=]

function instanceAttributeUtil.new(
	instanceTree: Instance,
	desiredAttribute: string,
	callback: (descendant: Instance) -> ()
)
	return instanceTree.DescendantAdded:Connect(function(descendant)
		if descendant:GetAttribute(desiredAttribute) ~= nil then
			callback(descendant)
		end
	end)
end

--[=[
	Sets up an event connection which listens to any descendant removed from `instanceTree`, if it has the
	`desiredAttribute` atribute, then `callback` will be called.

	```lua
	instanceAttributeUtil.removed(workspace, "Test", function(instance)
		print(instance)
	end)
	```
]=]

function instanceAttributeUtil.removed(
	instanceTree: Instance,
	desiredAttribute: string,
	callback: (descendant: Instance) -> ()
)
	return instanceTree.DescendantRemoving:Connect(function(descendant)
		if descendant:GetAttribute(desiredAttribute) ~= nil then
			callback(descendant)
		end
	end)
end

--[=[
	Observes the value of attribute `desiredAttribute` in `instance`, so `observer` is called
	every time the attribute updates.

	```lua
	instanceAttributeUtil.observe(workspace, "SomeAttribute", function(newValue, oldValue)
		...
	end)
	```
]=]

function instanceAttributeUtil.observe(
	instance: Instance,
	desiredAttribute: string,
	observer: Observer
)
	local oldAttributeValue = instance:GetAttribute(desiredAttribute)
	if oldAttributeValue ~= nil then
		task.spawn(observer, oldAttributeValue)
	end

	return instance:GetAttributeChangedSignal(desiredAttribute):Connect(function()
		observer(instance:GetAttribute(desiredAttribute), oldAttributeValue)
		oldAttributeValue = instance:GetAttribute(desiredAttribute)
	end)
end

--[=[
	Returns a promise which is resolved when the given instance has the given attribute.
	
	```lua
	instanceAttributeUtil.instanceAttributePromise(instance, "SomeAttribute"):andThen(function(value)
		print(value) --> 5
	end)

	instance:SetAttribute("SomeAttribute", 5)
	```

	`predicate` can also be passed, which should return a boolean value. It is passed
	the new attribute value of the instance, and the old attribute value of the instance. The promise
	will only resolve when `predicate` returns `true` for the new attribute value of the instance.

	```lua
	instanceAttributeUtil.instanceAttributePromise(instance, "SomeAttribute", function(newValue, oldValue)
		return newValue == 2 and oldValue == 1
	end):andThen(function(value)
		print(value) --> 2
	end)

	instance:SetAttribute("SomeAttribute", 1)
	instance:SetAttribute("SomeAttribute", 2)
	```
]=]

function instanceAttributeUtil.instanceAttributePromise(
	instance: Instance,
	attribute: string,
	predicate: ((
		newValue: any,
		oldValue: any
	) -> boolean)?
)
	return Promise.new(function(resolve)
		if predicate == nil then
			if instance:GetAttribute(attribute) ~= nil then
				resolve(instance:GetAttribute(attribute))
			else
				instance:GetAttributeChangedSignal(attribute):Wait()
				resolve()
			end
		else
			local oldValue
			while predicate(instance:GetAttribute(attribute), oldValue) ~= true do
				oldValue = instance:GetAttribute(attribute)
				instance:GetAttributeChangedSignal(attribute):Wait()
			end

			resolve(instance:GetAttribute(attribute))
		end
	end)
end

return table.freeze(instanceAttributeUtil)
