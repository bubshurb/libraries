"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[2702],{70905:e=>{e.exports=JSON.parse('{"functions":[{"name":"usePlayerAdded","desc":" \\nA simple wrapper for the [PlayerAdded](https://create.roblox.com/docs/reference/engine/classes/Players#PlayerAdded) event. \\nThis method additionally captures **current** players in game; during the time of the execution of this method, as well.\\n\\n```lua\\nplayerUtil.usePlayerAdded(function(player)\\n\\tprint(player.Name, \\" joined the game!\\")\\nend)\\n```","params":[{"name":"callback","desc":"","lua_type":"(player: Player) -> ()"}],"returns":[],"function_type":"static","source":{"line":21,"path":"src/playerEventsUtil/init.luau"}},{"name":"usePlayerCharacterAdded","desc":" \\nA wrapper over the [player.CharacterAdded](https://create.roblox.com/docs/reference/engine/classes/Player#CharacterAdded) event.\\nAlso runs the given callback initially if `player.Character` is a truthy value, passing in `newCharacter` (while `oldCharacter`\\n= `nil`).\\n\\n```lua\\nplayerEventsUtil.usePlayerCharacterAdded(player, function(newCharacter, oldCharacter)\\n\\t\\nend)\\n```","params":[{"name":"player","desc":"","lua_type":"Player"},{"name":"callback","desc":"","lua_type":"(\\r\\n\\t\\tnewPlayerCharacter: Model,\\r\\n\\t\\toldPlayerCharacter: Model?\\r\\n\\t) -> ()\\r\\n"}],"returns":[],"function_type":"static","source":{"line":41,"path":"src/playerEventsUtil/init.luau"}}],"properties":[],"types":[],"name":"playerEventsUtil","desc":" \\n\\nA simple utility module for working with player events.","source":{"line":6,"path":"src/playerEventsUtil/init.luau"}}')}}]);