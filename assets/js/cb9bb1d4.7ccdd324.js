"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[1149],{45336:e=>{e.exports=JSON.parse('{"functions":[{"name":"productInfo","desc":"Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved wih the product info of the given\\nplace id.","params":[{"name":"assetId","desc":"","lua_type":"number"},{"name":"infoType","desc":"","lua_type":"Enum.InfoType?"}],"returns":[{"desc":"","lua_type":"Promise<ProductInfo>"}],"function_type":"static","source":{"line":36,"path":"src/marketPlaceServiceUtil/init.luau"}},{"name":"userOwnsGamepassAsync","desc":"Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with a boolean indicating\\nif the user owns the specified gamepass or not. Incase the operation fails, the promise will reject\\nwith an additional value i.e the error message.\\n\\n```lua\\nlocal wasSucessfull, userOwnsGamepass, errorMessage = marketPlaceServiceUtil.userOwnsGamepassAsync(123, 45678123):await()\\n\\nif wasSucessfull then\\n\\tprint(userOwnsGamepass)\\nelse \\n\\tprint(userOwnsGamepass) --\x3e false\\n\\tprint(errorMessage)\\nend\\n```","params":[{"name":"userId","desc":"","lua_type":"number"},{"name":"gamepassId","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"Promise<boolean>"}],"function_type":"static","source":{"line":61,"path":"src/marketPlaceServiceUtil/init.luau"}},{"name":"playerOwnsAsset","desc":"Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with a boolean indicating\\nif the player owns the specified asset or not. Incase the operation fails, the promise will reject\\nwith an additional value i.e the error message.\\n\\n```lua\\nlocal wasSucessfull, playerOwnsAsset, errorMessage = marketPlaceServiceUtil.playerOwnsAsset(123, 45678123):await()\\n\\nif wasSucessfull then\\n\\tprint(playerOwnsAsset)\\nelse \\n\\tprint(playerOwnsAsset) --\x3e false\\n\\tprint(errorMessage)\\nend\\n```","params":[{"name":"player","desc":"","lua_type":"Player"},{"name":"assetId","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"Promise<boolean>"}],"function_type":"static","source":{"line":84,"path":"src/marketPlaceServiceUtil/init.luau"}},{"name":"playerOwnsBundle","desc":"Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with a boolean indicating\\nif the player owns the specified bundle or not. Incase the operation fails, the promise will reject\\nwith an additional value i.e the error message.\\n\\n```lua\\nlocal wasSucessfull, playerOwnsBundle, errorMessage = marketPlaceServiceUtil.playerOwnsBundle(123, 45678123):await()\\n\\nif wasSucessfull then\\n\\tprint(playerOwnsBundle)\\nelse \\n\\tprint(playerOwnsBundle) --\x3e false\\n\\tprint(errorMessage)\\nend\\n```","params":[{"name":"player","desc":"","lua_type":"Player"},{"name":"bundleId","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"Promise<boolean>"}],"function_type":"static","source":{"line":107,"path":"src/marketPlaceServiceUtil/init.luau"}},{"name":"subscriptionInfoProductAsync","desc":"Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with the info\\nof the given subscription id.\\n\\n```lua\\nlocal wasSucessfull, subscriptionInfo = marketPlaceServiceUtil.subscriptionInfoProductAsync(subscriptionId):await()\\n\\nif wasSucessfull then\\n\\tprint(subscriptionInfo)\\nelse\\n\\tprint(tostring(subscriptionInfo)) -- Error\\nend\\n```","params":[{"name":"subscriptionId","desc":"","lua_type":"string"}],"returns":[{"desc":"","lua_type":"Promise<SubscriptionInfo>"}],"function_type":"static","source":{"line":128,"path":"src/marketPlaceServiceUtil/init.luau"}},{"name":"userSubscriptionDetailsAsync","desc":"Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with the\\nuser subscription details.\\n\\n```lua\\nlocal wasSucessfull, userSubscriptionDetails = marketPlaceServiceUtil.GetUserSubscriptionDetailsAsync(player, subscriptionId):await()\\n\\nif wasSucessfull then\\n\\tprint(userSubscriptionDetails)\\nelse\\n\\tprint(tostring(userSubscriptionDetails)) -- Error\\nend\\n```","params":[{"name":"player","desc":"","lua_type":"Player"},{"name":"subscriptionId","desc":"","lua_type":"string"}],"returns":[{"desc":"","lua_type":"Promise<UserSubscriptionDetails>"}],"function_type":"static","source":{"line":151,"path":"src/marketPlaceServiceUtil/init.luau"}},{"name":"userSubscriptionPaymentHistoryAsync","desc":"Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with the\\nuser subscription payment history.\\n\\n```lua\\nlocal wasSucessfull, userSubscriptionPaymentHistory = marketPlaceServiceUtil.userSubscriptionPaymentHistoryAsync(player, subscriptionId):await()\\n\\nif wasSucessfull then\\n\\tprint(userSubscriptionPaymentHistory)\\nelse\\n\\tprint(tostring(userSubscriptionPaymentHistory)) -- Error\\nend\\n```","params":[{"name":"player","desc":"","lua_type":"Player"},{"name":"subscriptionId","desc":"","lua_type":"string\\r\\n"}],"returns":[{"desc":"","lua_type":"Promise<UserSubscriptionPaymentHistory>"}],"function_type":"static","source":{"line":174,"path":"src/marketPlaceServiceUtil/init.luau"}},{"name":"userSubscriptionStatusAsync","desc":"Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with the\\nuser subscription payment history.\\n\\n```lua\\nlocal wasSucessfull, userSubscriptionStatus = marketPlaceServiceUtil.userSubscriptionStatusAsync(player, subscriptionId):await()\\n\\nif wasSucessfull then\\n\\tprint(userSubscriptionStatus)\\nelse\\n\\tprint(tostring(userSubscriptionStatus)) -- Error\\nend\\n```","params":[{"name":"player","desc":"","lua_type":"Player"},{"name":"subscriptionId","desc":"","lua_type":"string"}],"returns":[{"desc":"","lua_type":"Promise<UserSubscriptionStatus>"}],"function_type":"static","source":{"line":200,"path":"src/marketPlaceServiceUtil/init.luau"}},{"name":"activeAssetProductInfoWhichPlayerOwns","desc":" \\nRetrieves the asset product info that belongs to a player of userid `playerUserId`.","params":[{"name":"playerUserId","desc":"","lua_type":"number"},{"name":"assetId","desc":"","lua_type":"number\\r\\n"}],"returns":[],"function_type":"static","source":{"line":210,"path":"src/marketPlaceServiceUtil/init.luau"}}],"properties":[],"types":[],"name":"marketPlaceServiceUtil","desc":"An utility module for working with [MarketplaceService](https://create.roblox.com/docs/reference/engine/classes/MarketplaceService).","source":{"line":6,"path":"src/marketPlaceServiceUtil/init.luau"}}')}}]);