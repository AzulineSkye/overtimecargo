local sprite = Resources.sprite_load(NAMESPACE, "scrapMissiles", path.combine(PATH, "Sprites/item/scrapMissiles.png"), 1, 16, 16)
local missile_sprite = Resources.sprite_load(NAMESPACE, "scrapMissilesMissile", path.combine(PATH, "Sprites/fx/scrapMissilesMissile.png"), 3, 23, 5)

local missiles = Item.new(NAMESPACE, "scrapMissiles")
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
					miss.sprite_index = missile_sprite
					miss.damage = actor.damage * 0.8
				elseif
				actor.missileCount and actor.missileCount > 50 and actor.missileCount <= 100 then
					actor.missileTimer = 5
					actor.missileCount = actor.missileCount - 1
					local miss = smallMissile:create(actor.x, actor.y)
					miss.sprite_index = missile_sprite
					miss.damage = actor.damage * 0.8
				elseif
				actor.missileCount and actor.missileCount > 100 then
					actor.missileTimer = 1
					actor.missileCount = actor.missileCount - 1
					local miss = smallMissile:create(actor.x, actor.y)
					miss.sprite_index = missile_sprite
					miss.damage = actor.damage * 0.8
				end
			end
		end
	end
end)

Callback.add(Callback.TYPE.onEnemyInit, "scrapMissilesLaunch", function(enemy)
	for id, _ in pairs(my_item_owners) do
		local actor = Instance.wrap(id)
		if actor:exists() then
			actor.missileCount = actor.missileCount + 2 + 1 * actor:item_stack_count(missiles)
		else
			my_item_owners[id] = nil
		end
	end
end
)
