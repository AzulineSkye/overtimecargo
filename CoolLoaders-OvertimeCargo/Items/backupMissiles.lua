local sprite = Resources.sprite_load(NAMESPACE, "Backup Missiles", path.combine(PATH, "Sprites/backupMissiles.png"), 1, 19.5, 19)

local missiles = Item.new(NAMESPACE, "backupMissiles")
missiles:set_sprite(sprite)
missiles:set_tier(Item.TIER.common)
missiles:set_loot_tags(Item.LOOT_TAG.category_damage)

missiles:clear_callbacks()

local smallMissile = Object.find("ror-EfMissileSmall")
local my_item_owners = {}

missiles:onAcquire(function(actor, stack)
    if stack == 1 then
        my_item_owners[actor.id] = true
    end
	if not actor.missileCount then
		actor.missileCount = 0
		actor.missileTimer = 0
	end
end)
missiles:onRemove(function(actor, stack)
    if stack == 1 then
        my_item_owners[actor.id] = nil
		if actor.missileCount then
			actor.missileCount = nil
			actor.missileTimer = nil
		end
    end
end)

missiles:onPostStep(function(actor, stack)
	if actor:exists() then
		if actor.missileTimer then
			if actor.missileTimer > 0 then
				actor.missileTimer = actor.missileTimer - 1
			end
			if actor.missileTimer <= 0 then
				if actor.missileCount and actor.missileCount > 0 and actor.missileCount <= 50 then
					actor.missileTimer = 10
					actor.missileCount = actor.missileCount - 1
					local miss = smallMissile:create(actor.x, actor.y)
					miss.damage = actor.damage * 0.5
				elseif
				actor.missileCount and actor.missileCount > 50 and actor.missileCount <= 100 then
					actor.missileTimer = 5
					actor.missileCount = actor.missileCount - 1
					local miss = smallMissile:create(actor.x, actor.y)
					miss.damage = actor.damage * 0.5
				elseif
				actor.missileCount and actor.missileCount > 100 then
					actor.missileTimer = 1
					actor.missileCount = actor.missileCount - 1
					local miss = smallMissile:create(actor.x, actor.y)
					miss.damage = actor.damage * 0.5
				end
			end
		end
	end
end)

Callback.add(Callback.TYPE.onEnemyInit, "backupShots", function(enemy)
	for id, _ in pairs(my_item_owners) do
		local actor = Instance.wrap(id)
		if actor:exists() then
			actor.missileCount = actor.missileCount + 2 + 1 * actor:item_stack_count(missiles)
		else
			-- clean up any that don't exist anymore.
			my_item_owners[id] = nil
		end
	end
end
)
