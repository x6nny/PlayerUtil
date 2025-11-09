--!strict
local Players = game:GetService('Players')
local UserService = game:GetService('UserService')

type Thumbnails = {
	['HeadShot'] : {['Size48x48'] : string, ['Size60x60'] : string, ['Size100x100'] : string, ['Size150x150'] : string, ['Size180x180'] : string, ['Size352x352'] : string, ['Size420x420'] : string},
	['AvatarBust'] : {['Size48x48'] : string, ['Size60x60'] : string, ['Size100x100'] : string, ['Size150x150'] : string, ['Size180x180'] : string, ['Size352x352'] : string, ['Size420x420'] : string},
	['AvatarThumbnail'] : {['Size48x48'] : string, ['Size60x60'] : string, ['Size100x100'] : string, ['Size150x150'] : string, ['Size180x180'] : string, ['Size352x352'] : string, ['Size420x420'] : string},
}
type GetInfo = (UserId : number) -> {
	HumanoidDescription : HumanoidDescription,
	Thumbnails : Thumbnails,
	DisplayName : string,
	UserName : string,
	Verified : boolean
}

export type PlayerInfo = {
	GetThumbnails : (UserId : number) -> Thumbnails,
	GetInfo : GetInfo
}

local PlayerInfo = {}
local userInfo_Cache = {}
local userThumbnail_Cache = {}

function PlayerInfo.GetThumbnails(UserId : number) : Thumbnails
	if userThumbnail_Cache[UserId] then
		return userThumbnail_Cache[UserId]
	end
	local ThumbnailTypes = {
		['HeadShot'] = {
			'Size48x48',
			'Size60x60',
			'Size100x100',
			'Size150x150',
			'Size180x180',
			'Size352x352',
			'Size420x420',
		},
		['AvatarBust'] = {
			'Size48x48',
			'Size60x60',
			'Size100x100',
			'Size150x150',
			'Size180x180',
			'Size352x352',
			'Size420x420',
		},
		['AvatarThumbnail'] = {
			'Size48x48',
			'Size60x60',
			'Size100x100',
			'Size150x150',
			'Size180x180',
			'Size352x352',
			'Size420x420',
		},
	}

	local Thumbnails = {}

	for Type, Sizes in pairs(ThumbnailTypes) do
		if Thumbnails[Type] == nil then Thumbnails[Type] = {} end
		for _, Size in pairs(Sizes) do
			local Thumb = Players:GetUserThumbnailAsync(UserId, Enum.ThumbnailType[Type], Enum.ThumbnailSize[Size])
			Thumbnails[Type][Size] = Thumb
		end
	end

	userThumbnail_Cache[UserId] = Thumbnails

	return Thumbnails :: Thumbnails
end

function PlayerInfo.GetInfo(UserId : number) : {HumanoidDescription : HumanoidDescription, Thumbnails : Thumbnails, DisplayName : string, UserName : string, Verified : boolean}
	if userInfo_Cache[UserId] ~= nil then
		return userInfo_Cache[UserId]
	end

	local HumanoidDescription = Players:GetHumanoidDescriptionFromUserId(UserId)
	local UserInfo = UserService:GetUserInfosByUserIdsAsync({UserId})[1]
	local DisplayName = UserInfo['DisplayName']
	local UserName = UserInfo['Username']
	local Verified = UserInfo['HasVerifiedBadge']

	local Thumbnails = PlayerInfo.GetThumbnails(UserId)

	local info = {
		HumanoidDescription = HumanoidDescription,
		Thumbnails = Thumbnails,
		DisplayName = DisplayName,
		UserName = UserName,
		Verified = Verified
	} :: {HumanoidDescription : HumanoidDescription, Thumbnails : Thumbnails, DisplayName : string, UserName : string, Verified : boolean}

	userInfo_Cache[UserId] = info

	return info
end

Players.PlayerRemoving:Connect(function(player : Player)
	local UserId = player.UserId
	
	if userInfo_Cache[UserId] then
		userInfo_Cache[UserId] = nil
	end
	if userThumbnail_Cache[UserId] then
		userThumbnail_Cache[UserId] = nil
	end
end)

return PlayerInfo