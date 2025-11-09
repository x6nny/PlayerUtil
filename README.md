# 🧩 Player Module Suite

A **Roblox Luau module suite** that simplifies working with players by providing:

* 🧱 **`PlayerHandler`** — Manage player join/leave events cleanly.
* 🧬 **`Meta`** — Extend PlayerHandler with metatable utilities for indexing, calling, and iterating players.
* 👤 **`PlayerInfo`** — Retrieve, cache, and manage player information and thumbnails.

This suite is modular, type-safe (`--!strict`), and performance-friendly — perfect for scalable multiplayer systems.

---

## 📦 Installation

Clone or copy the module folder into your Roblox Studio project, then require the entry module:

```lua
local PlayerModule = require(path.to.Module)

local Handler = PlayerModule.Handler
local Info = PlayerModule.Info
```

---

## 🧱 `init` Module

### Overview

Acts as the **entry point** that unifies all submodules.

```lua
--!strict
return {
	['Handler'] = require('@self/PlayerHandler'),
	['Info'] = require('@self/PlayerInfo'),
}
```

### Usage Example

```lua
local PlayerModule = require(script.Parent)

local Handler = PlayerModule.Handler
local Info = PlayerModule.Info
```

---

## ⚙️ `PlayerHandler` Module

### Overview

Handles **player lifecycle events** (join/leave) with a simple and extensible API.
It leverages a **custom metatable** (`meta.lua`) to provide convenient iteration and indexing of players.

---

### 🔍 API Summary

| Function                   | Parameters                                                  | Returns    | Description                                                                         |
| :------------------------- | :---------------------------------------------------------- | :--------- | :---------------------------------------------------------------------------------- |
| **`PlayerAdded(func)`**    | `(player: Player) -> ()`                                    | `() -> ()` | Registers a function that runs when a player joins. Returns a disconnect function.  |
| **`PlayerRemoving(func)`** | `(player: Player, exitReason: Enum.PlayerExitReason) -> ()` | `() -> ()` | Registers a function that runs when a player leaves. Returns a disconnect function. |

---

### 💡 Features

* 🔹 Non-yielding callback execution via `task.spawn()`
* 🔹 Returns disconnect functions for cleanup
* 🔹 Uses a metatable for easy player lookup and iteration
* 🔹 Executes removal callbacks safely during shutdown (`BindToClose`)

---

### 📘 Example

```lua
local PlayerHandler = require(script.Parent.PlayerHandler)

-- Handle player joining
local disconnectJoin = PlayerHandler.PlayerAdded(function(player)
	print(player.Name .. " has joined!")
end)

-- Handle player leaving
PlayerHandler.PlayerRemoving(function(player, reason)
	print(player.Name .. " left the game. Reason:", reason.Name)
end)

-- Stop listening for player joins
disconnectJoin()
```

---

### 🧩 Metatable Integration

The `PlayerHandler` internally uses the [`Meta`](#-meta-module) module as its metatable, giving it **extra powers**:

```lua
local PlayerHandler = require(script.Parent.PlayerHandler)

-- Get player by name, UserId, or Model
print(PlayerHandler["PlayerName"])
print(PlayerHandler[12345678])
print(PlayerHandler[workspace:WaitForChild("PlayerName")])

-- Iterate through players
for _, player in PlayerHandler do
	print(player.Name)
end

-- Get player count
print(#PlayerHandler)
```

---

## 🧬 `Meta` Module

### Overview

Provides a **metatable** that extends the `PlayerHandler` module with extra functionality for:

* Direct player lookup via indexing or calling
* Iteration (`for _, player in PlayerHandler do`)
* Player count via length operator (`#PlayerHandler`)

---

### 🧩 API Summary

| Metamethod        | Description                                                                                  | Example                         |
| :---------------- | :------------------------------------------------------------------------------------------- | :------------------------------ |
| `__call(_, key)`  | Returns a `Player?` when called with a string (name), number (UserId), or Model (character). | `PlayerHandler("NoobMaster69")` |
| `__index(_, key)` | Returns a `Player?` when accessed by key.                                                    | `PlayerHandler[12345678]`       |
| `__len(_)`        | Returns the total number of connected players.                                               | `#PlayerHandler`                |
| `__iter()`        | Allows iteration over all current players.                                                   | `for _, p in PlayerHandler do`  |

---

### 📘 Example

```lua
local PlayerHandler = require(script.Parent.PlayerHandler)

-- Retrieve players in multiple ways
print(PlayerHandler("CoolPlayer"))
print(PlayerHandler[12345678])
print(PlayerHandler[workspace.CoolPlayer])

-- Count players
print("Players online:", #PlayerHandler)

-- Iterate all players
for _, player in PlayerHandler do
	print("Active:", player.Name)
end
```

---

## 👤 `PlayerInfo` Module

### Overview

The **PlayerInfo** module provides utilities for fetching and caching **user data**, including:

* Roblox **Display Name**, **Username**, and **Verification Badge**
* Full **HumanoidDescription**
* Multiple **thumbnail types and sizes**

Caches are automatically managed and cleared when players leave.

---

### 🔍 API Summary

| Function                    | Parameters         | Returns                                                                | Description                                                                   |
| :-------------------------- | :----------------- | :--------------------------------------------------------------------- | :---------------------------------------------------------------------------- |
| **`GetThumbnails(UserId)`** | `(UserId: number)` | `Thumbnails`                                                           | Retrieves and caches user thumbnails (HeadShot, AvatarBust, AvatarThumbnail). |
| **`GetInfo(UserId)`**       | `(UserId: number)` | `{ HumanoidDescription, Thumbnails, DisplayName, UserName, Verified }` | Returns a structured table of player information and thumbnails.              |

---

### 🧩 Thumbnails Structure

Each type (HeadShot, AvatarBust, AvatarThumbnail) includes sizes:

```
Size48x48, Size60x60, Size100x100, Size150x150,
Size180x180, Size352x352, Size420x420
```

---

### 📘 Example

```lua
local PlayerInfo = require(script.Parent.PlayerInfo)

local info = PlayerInfo.GetInfo(12345678)

print(info.DisplayName) -- e.g. "CoolPlayer"
print(info.UserName)    -- e.g. "CoolPlayer123"
print(info.Verified)    -- true / false

-- Access thumbnails
print(info.Thumbnails.HeadShot.Size100x100)
```

---

### 🧹 Cache Management

The module automatically clears user caches when a player leaves:

```lua
Players.PlayerRemoving:Connect(function(player)
	-- userInfo_Cache and userThumbnail_Cache are cleaned
end)
```

---

## 🧠 Example Integration

```lua
local PlayerModule = require(script.Parent)
local Handler = PlayerModule.Handler
local Info = PlayerModule.Info

Handler.PlayerAdded(function(player)
	local data = Info.GetInfo(player.UserId)
	print(`{data.DisplayName} joined! Verified: {data.Verified}`)
end)

Handler.PlayerRemoving(function(player)
	print(player.Name .. " has left the game.")
end)
```

---

## 🧩 Module Summary

| Module            | Purpose                                                           |
| :---------------- | :---------------------------------------------------------------- |
| **init**          | Entry point linking `PlayerHandler` and `PlayerInfo`.             |
| **PlayerHandler** | Manages player lifecycle and integrates with metatable utilities. |
| **Meta**          | Provides iteration, lookup, and count features for players.       |
| **PlayerInfo**    | Fetches, caches, and manages player information and thumbnails.   |

---

## 🛠️ Technical Notes

* Built with **Luau strict mode** (`--!strict`)
* Uses **`task.spawn`** for safe, non-blocking callbacks
* Uses **`UserService`** and **`Players`** APIs for data retrieval
* Automatically cleans up cached data
* Works seamlessly on both **server** and **client**

---

## 📄 License

This project is licensed under the **MIT License**.
You are free to use, modify, and distribute it with attribution.
