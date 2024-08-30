"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[7402],{45040:e=>{e.exports=JSON.parse('{"functions":[{"name":"toolOwner","desc":"Attempts to returns the owner of the given tool, if found.","params":[{"name":"tool","desc":"","lua_type":"Tool"}],"returns":[{"desc":"","lua_type":"Player?\\r\\n"}],"function_type":"static","source":{"line":43,"path":"src/toolUtil/init.luau"}},{"name":"tryPlaceToolInBackpackAndStarterGear","desc":" \\nPlaces the given tool in the given `player`\'s backpack and a cloned variant of it in `player.StarterGear`.","params":[{"name":"player","desc":"","lua_type":"Player"},{"name":"tool","desc":"","lua_type":"Tool"}],"returns":[],"function_type":"static","source":{"line":62,"path":"src/toolUtil/init.luau"}},{"name":"tryPlaceToolInBackpackAndEquip","desc":" \\nPlaces the given tool in the given `player`\'s backpack and tries to equips it on the humanoid.","params":[{"name":"player","desc":"","lua_type":"Player"},{"name":"tool","desc":"","lua_type":"Tool"}],"returns":[],"function_type":"static","source":{"line":71,"path":"src/toolUtil/init.luau"}},{"name":"mappedPlayerToolCount","desc":"Returns the player tool count. `predicate` is called on every tool owned by the given `player`, and each time it returns `true`, \\nthe tool count is incremented by 1.","params":[{"name":"player","desc":"","lua_type":"Player"},{"name":"predicate","desc":"","lua_type":"(tool: Tool) -> boolean"}],"returns":[],"function_type":"static","source":{"line":88,"path":"src/toolUtil/init.luau"}},{"name":"playerTools","desc":"Returns a read only array of all player tools - both equipped and unequipped.","params":[{"name":"player","desc":"","lua_type":"Player"}],"returns":[],"function_type":"static","source":{"line":103,"path":"src/toolUtil/init.luau"}},{"name":"currentEquippedTool","desc":" \\nReturns the current equipped tool by the player.","params":[{"name":"player","desc":"","lua_type":"Player"}],"returns":[],"function_type":"static","source":{"line":121,"path":"src/toolUtil/init.luau"}},{"name":"observePlayerForToolsEquippedAndUnequipped","desc":" \\nObserves the player for any new tools equipped or unequipped. Also captures\\nall the initial tool equipped. \\n\\n```lua\\ntoolUtil.observePlayerForEquippedTool(player, function(newToolEquipped)\\n\\nend, function(newToolUnequipped)\\n\\nend)\\n```\\n\\n:::warning\\nThis method will throw an error if both `observerForToolEquipped` and `observerForToolUnequipped` are not specified, at least any *one* of them must be specified.\\n:::","params":[{"name":"player","desc":"","lua_type":"Player"},{"name":"observerForToolEquipped","desc":"","lua_type":"((toolEquipped: Tool) -> ())?"},{"name":"observerForToolUnequipped","desc":"","lua_type":"((toolUnequipped: Tool) -> ())?\\r\\n"}],"returns":[],"function_type":"static","source":{"line":142,"path":"src/toolUtil/init.luau"}},{"name":"observePlayerBackpackForTools","desc":" \\nObserves the player\'s backpack for any new tools added or removed. Also captures\\nall initial tools in the player backpack.\\n\\n```lua\\ntoolUtil.observePlayerBackpackForTools(player, function(toolAdded)\\n\\nend, function(toolRemoved)\\n\\nend)\\n```\\n\\n:::warning\\nThis method will throw an error if both `observerForToolAdded` and `observerForToolRemoved` are not specified, at least any *one* of them must be specified.\\n:::","params":[{"name":"player","desc":"","lua_type":"Player"},{"name":"observerForToolAdded","desc":"","lua_type":"((newToolAdded: Tool) -> ())?"},{"name":"observerForToolRemoved","desc":"","lua_type":"((newToolRemoved: Tool) -> ())?\\r\\n"}],"returns":[],"function_type":"static","source":{"line":214,"path":"src/toolUtil/init.luau"}},{"name":"observePlayerForToolOwnership","desc":" \\nObserves the player\'s backpack and character for any new tools added or removed.\\n\\n```lua\\ntoolUtil.observePlayerForToolOwnership(player, function(toolOwnershipGranted)\\n\\nend, function(toolOwnershipRemoved)\\n\\nend)\\n```\\n\\n:::warning\\nThis method will throw an error if both `observerForToolOwnershipGranted` and `observerForToolOwnershipRemoved` are not specified, at least any\\n*one* of them must be specified.\\n:::","params":[{"name":"player","desc":"","lua_type":"Player"},{"name":"observerForToolOwnershipGranted","desc":"","lua_type":"((newTool: Tool) -> ())?"},{"name":"observerForToolOwnershipRemoved","desc":"","lua_type":"((newTool: Tool) -> ())?\\r\\n"}],"returns":[],"function_type":"static","source":{"line":277,"path":"src/toolUtil/init.luau"}}],"properties":[],"types":[],"name":"toolUtil","desc":"A simple utility module for working with tools.","source":{"line":6,"path":"src/toolUtil/init.luau"}}')}}]);