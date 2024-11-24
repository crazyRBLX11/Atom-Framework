--!native
--!strict
local Badges = {}

-- Badge Service.
function Badges:GetBadgeService()
	return game:GetService("BadgeService")
end

function Badges:AwardBadge(player: Player, BadgeID: number)
	local BadgeService = Badges:GetBadgeService()
	local DoesThePlayerHaveTheBadge = BadgeService:UserHasBadgeAsync(player.UserId, BadgeID)

	local success, errormessage = pcall(function()
		if DoesThePlayerHaveTheBadge ~= true then
			BadgeService:AwardBadge(player.UserId, BadgeID)
		end
	end)

	if not success then
		player:Kick("Error with BadgeService. " .. errormessage)
	end
end

return Badges
