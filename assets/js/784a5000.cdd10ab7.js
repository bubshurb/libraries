"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[2768],{43007:e=>{e.exports=JSON.parse('{"functions":[{"name":"new","desc":"A constructor method that creates a new property object, with `initialValue` as the current value\\nof the property.","params":[{"name":"initialValue","desc":"","lua_type":"T?"}],"returns":[{"desc":"","lua_type":"Property"}],"function_type":"static","source":{"line":54,"path":"src/Property/init.luau"}},{"name":"is","desc":"A method that returns a boolean indicating if `self` is a property or not.","params":[{"name":"self","desc":"","lua_type":"any"}],"returns":[{"desc":"","lua_type":"boolean\\r\\n"}],"function_type":"static","source":{"line":73,"path":"src/Property/init.luau"}},{"name":"clone","desc":"Creates a new property and binds it to the current property, and returns the new\\nproperty. The new property will operate on the value of the current property, however\\nyou may specify a `mapper` function for more control. The `mapper` function will be \\npassed the new value and the old value of the current property (and when the current\\nproperty is updated), the return value of the mapper will be the new value of the new\\nproperty.\\n\\nThe new property will be automatically destroyed once the current prpoerty is destroyed.\\n\\n```lua\\nlocal property = Property.new(5)\\nlocal anotherProperty = property:clone(function(number)\\n\\treturn number + 5\\nend)\\n\\nprint(anotherProperty:get()) --\x3e 10\\nproperty:set(10)\\nprint(anotherProperty:get()) --\x3e 15\\n```","params":[{"name":"mapper","desc":"","lua_type":"((newValue: any, oldValue: any) -> any)?"}],"returns":[],"function_type":"method","source":{"line":99,"path":"src/Property/init.luau"}},{"name":"bindToInstanceProperty","desc":"Binds the property to a property of the given Roblox instance. When the instance is destroyed,\\nthe property is automatically destroyed as well.\\n\\n```lua\\nlocal property = Property.new()\\nproperty:bindToInstanceProperty(workspace.Baseplate, \\"Transparency\\")\\n\\nproperty.onUpdate:Connect(function(newTransparency, oldTransparency)\\n\\tprint(newTransparency, oldTransparency) --\x3e 1, 0\\nend)\\n\\nprint(property:get()) --\x3e 0\\n\\nworkspace.Baseplate.Transparency = 1\\n\\n-- Deferred signal behavior: (Roblox instance-signals are not immediately fired)\\nprint(property.onUpdate:Wait()) --\x3e 1\\n```","params":[{"name":"instance","desc":"","lua_type":"Instance"},{"name":"property","desc":"","lua_type":"string"}],"returns":[],"function_type":"method","source":{"line":132,"path":"src/Property/init.luau"}},{"name":"bindToInstanceAttribute","desc":"Binds the property to an attribute of the given Roblox instance. When the instance is destroyed,\\nthe property is automatically destroyed as well.\\n\\n```lua\\nlocal property = Property.new()\\nproperty:bindToInstanceAttribute(workspace.Baseplate, \\"SomeAttribute\\")\\n\\nprint(property:get()) --\x3e nil\\n\\nworkspace.Baseplate:SetAttribute(\\"SomeAttribute\\", 5)\\n\\nprint(property:get()) --\x3e 5\\n```","params":[{"name":"instance","desc":"","lua_type":"Instance"},{"name":"attribute","desc":"","lua_type":"string"}],"returns":[],"function_type":"method","source":{"line":156,"path":"src/Property/init.luau"}},{"name":"bindToInstance","desc":"Binds the property to an instance so that once the instance is destroyed,\\nthe property will be destroyed too.\\n\\n```lua\\nlocal property = Property.new()\\nproperty:bindToInstance(workspace.Baseplate)\\n\\n print(Property.is(property)) --\x3e true\\n\\nworkspace.Baseplate:Destroy()\\n\\ntask.wait() -- Deferred signal behavior\\n\\nprint(Property.is(property)) --\x3e false\\n```","params":[{"name":"instance","desc":"","lua_type":"Instance"}],"returns":[],"function_type":"method","source":{"line":182,"path":"src/Property/init.luau"}},{"name":"set","desc":"Sets the value of the property to `value`, if this new value isn\'t the same as the previous value. ","params":[{"name":"value","desc":"","lua_type":"any"}],"returns":[],"function_type":"method","source":{"line":192,"path":"src/Property/init.luau"}},{"name":"observe","desc":"Observes the value of the property. \\n\\n```lua\\nproperty:observe(function(newValue, oldValue)\\n\\nend)\\n```","params":[{"name":"callback","desc":"","lua_type":"(newValue: any, oldValue: any) -> ()"}],"returns":[],"function_type":"method","source":{"line":213,"path":"src/Property/init.luau"}},{"name":"valuePromise","desc":"Returns a promise which is resolved with a non-nil value of the property, given that\\n`valuePredicate` is not passed as an argument.\\n\\n```lua\\nlocal property = Property.new()\\n\\nproperty:valuePromise():andThen(function(value)\\n\\tprint(value) --\x3e 2\\nend)\\n\\nproperty:set(2)\\n```\\n\\n`valuePredicate` can also be passed, which allows you to filter out values. If it returns\\nexactly `true`, only then will the promise resolve with the new value.\\n\\n```lua\\nproperty:valuePromise(function(newValue, oldValue) \\n\\treturn newValue == 10 and oldValue == 1\\nend):andThen(function(newValue)\\n\\tprint(newValue) \\nend)\\n\\nproperty:set(1) \\nproperty:set(10) \\n--\x3e 10\\n```","params":[{"name":"valuePredicate","desc":"","lua_type":"((newValue: any, oldValue: any) -> boolean)?"}],"returns":[{"desc":"","lua_type":"Promise"}],"function_type":"method","source":{"line":260,"path":"src/Property/init.luau"}},{"name":"forceSet","desc":"Works the same as [Property:set] except that values aren\'t checked for equality, for e.g:\\n\\n```lua\\nlocal property = Property.new()\\n\\nproperty.onUpdate:Connect(function(newValue)\\n\\tprint(newValue) \\nend)\\nproperty:forceSet(1) \\nproperty:forceSet(2) \\nproperty:forceSet(\\"a\\") \\n\\n--\x3e 1\\n--\x3e 2\\n--\x3e \\"a\\"\\n```","params":[{"name":"value","desc":"","lua_type":"any"}],"returns":[],"function_type":"method","tags":["Property Instance"],"source":{"line":299,"path":"src/Property/init.luau"}},{"name":"silentSet","desc":"Works almost the same as [Property:set], but never fires off the [Property.onUpdate] signal.","params":[{"name":"value","desc":"","lua_type":"any"}],"returns":[],"function_type":"method","source":{"line":309,"path":"src/Property/init.luau"}},{"name":"get","desc":"Returns a shallow copy of the current value of the property.\\n\\n```lua\\nlocal property = Property.new()\\n\\nlocal t = {}\\nproperty:set(t)\\nprint(property:get() == t) --\x3e false\\n```","params":[],"returns":[{"desc":"","lua_type":"any"}],"function_type":"method","source":{"line":326,"path":"src/Property/init.luau"}},{"name":"destroy","desc":"Destroys the property and renders it unusable.","params":[],"returns":[],"function_type":"method","source":{"line":334,"path":"src/Property/init.luau"}},{"name":"__tostring","desc":"","params":[],"returns":[],"function_type":"method","private":true,"source":{"line":343,"path":"src/Property/init.luau"}}],"properties":[{"name":"onUpdate","desc":" \\n\\nA [signal](https://sleitnick.github.io/RbxUtil/api/Signal/) which is fired whenever the value of the property is \\nset to a new one. The signal is only passed the new value as the only argument.","lua_type":"Signal <newValue: any, oldValue: any>","tags":["Signal","Property Instance"],"readonly":true,"source":{"line":28,"path":"src/Property/init.luau"}}],"types":[{"name":"Property","desc":" ","lua_type":"Property<T>","source":{"line":33,"path":"src/Property/init.luau"}}],"name":"Property","desc":" \\n\\nA class for wrapping values around setters and getters. A property in layman\'s terms is simply an object which contains some value.\\n \\n```lua\\nlocal property = Property.new(5)\\nprint(property:get()) --\x3e 5\\n\\nproperty.onUpdate:Connect(function(newValue, oldValue)\\n\\tprint(newValue, oldValue) --\x3e 10, 5\\nend)\\n\\nproperty:set(10) \\n```","source":{"line":17,"path":"src/Property/init.luau"}}')}}]);