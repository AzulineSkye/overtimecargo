local sprite_dust = Resources.sprite_load(NAMESPACE, "goldDust", path.combine(PATH, "Sprites/goldDust.png"), 1, 16, 17)

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

dust:onAcquire(function(actor, stack)
	local data = actor:get_data()
	data.dusttimer = 0
	data.itemsspawned = 0
end)

dust:onPostStep(function(actor, stack)
	local tp = Instance.find(gm.constants.oTeleporter)
	local data = actor:get_data()
	
	local itemcount = math.min(10, math.floor(actor.gold * 0.01 / GM._mod_game_getDirector().stage_chest_cost_scale))
	
	if tp.just_activated == 1 then
		data.dusttimer = data.dusttimer + 1
		
		if data.dusttimer >= 90 and data.dusttimer % 30 == 0 and data.itemsspawned <= itemcount then
			
			local tier = Item.TIER.common
			if math.random() <= 0.2 then 
				tier = Item.TIER.uncommon
			end
			if math.random() <= 0.05 then 
				tier = Item.TIER.rare
			end
			
			local item = Item.get_random(tier):create(tp.x, tp.y, tp)
			item.item_stack_kind = 1
			
			data.itemsspawned = data.itemsspawned + 1
		end
	end
end)

dust:onStageStart(function(actor, stack)
	local data = actor:get_data()
	data.dusttimer = 0
	data.itemsspawned = 0
end)