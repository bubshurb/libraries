local packages = script.Parent.Parent

local Trove = require(packages.Trove)
local Signal = require(packages.Signal)

export type Signal = typeof(Signal.new())
export type Trove = typeof(Trove.new())
export type SerializedArgs = { [any]: any }
export type RemoteEventOrUnreliable = RemoteEvent | UnreliableRemoteEvent
export type RemoteInstance = RemoteEventOrUnreliable | RemoteFunction
export type Callback = (...any) -> ...any

return nil
