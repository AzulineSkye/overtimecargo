local sprite_dust = Resources.sprite_load(NAMESPACE, "goldDust", path.combine(PATH, "Sprites/goldDust.png"), 1, 16, 16)

local dust = Item.new(NAMESPACE, "goldDust")
dust:set_sprite(sprite_dust)
dust:set_tier(Item.TIER.uncommon)
dust:set_loot_tags(Item.LOOT_TAG.category_utility)

dust:clear_callbacks()
dust:onHitProc(function(actor, victim, stack, hit_info)
	local gold = gm.instance_create(victim.x, victim.y, gm.constants.oEfGold)
	gold.value = 0.1 * stack * GM._mod_game_getDirector().stage_chest_cost_scale
	gold.vspeed = -1 * math.random(3)
	gold.hspeed = math.random(3)
end)