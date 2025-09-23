local sprite_dust = Resources.sprite_load(NAMESPACE, "goldDust", path.combine(PATH, "Sprites/goldDust.png"), 1, 16, 17)

local dust = Item.new(NAMESPACE, "goldDust")
dust:set_sprite(sprite_dust)
dust:set_tier(Item.TIER.uncommon)
dust:set_loot_tags(Item.LOOT_TAG.category_utility)

dust:clear_callbacks()
dust:onHitProc(function(actor, victim, stack, hit_info)
	local gold = gm.instance_create(victim.x, victim.y, gm.constants.oEfGold)
	gold.value = 0.1 * (hit_info.damage / actor.damage) * stack * GM._mod_game_getDirector().stage_chest_cost_scale
	gold.vspeed = -1 * math.random(3)
	gold.hspeed = math.random(3)
end)

dust:onAcquire(function(actor, stack)
	local data = actor:get_data()
	if data.lootbugspawned == nil then
		if Instance.find(gm.constants.oTeleporter).just_activated == 1 then
			data.lootbugspawned = 1
		elseif Instance.find(gm.constants.oTeleporterEpic).just_activated == 1 then
			data.lootbugspawned = 1
		elseif Instance.find(gm.constants.oCommand).just_activated == 1 then
			data.lootbugspawned = 1
		else
			data.lootbugspawned = 0
		end
	end
end)

dust:onPostStep(function(actor, stack)
	local tp = Instance.find(gm.constants.oTeleporter)
	local dtp = Instance.find(gm.constants.oTeleporterEpic)
	local com = Instance.find(gm.constants.oCommand)
	local data = actor:get_data()
	
	if tp.just_activated == 1 and data.lootbugspawned == 0 then
		local lootbug = Object.find(NAMESPACE, "Lootbug"):create(tp.x + math.random(-20, 20), tp.y - 13)
		lootbug.itemcount = math.min(9, math.floor(actor.gold * 0.01 / GM._mod_game_getDirector().stage_chest_cost_scale))
		data.lootbugspawned = 1
		
	elseif dtp.just_activated == 1 and data.lootbugspawned == 0 then
		local lootbug = Object.find(NAMESPACE, "Lootbug"):create(dtp.x + math.random(-20, 20), dtp.y - 13)
		lootbug.itemcount = math.min(9, math.floor(actor.gold * 0.01 / GM._mod_game_getDirector().stage_chest_cost_scale))
		data.lootbugspawned = 1
		
	elseif com.just_activated == 1 and data.lootbugspawned == 0 then
		local lootbug = Object.find(NAMESPACE, "Lootbug"):create(com.x + math.random(-20, 20), com.y - 13)
		lootbug.itemcount = math.min(9, math.floor(actor.gold * 0.01 / GM._mod_game_getDirector().stage_chest_cost_scale))
		data.lootbugspawned = 1		
	end
end)

dust:onStageStart(function(actor, stack)
	local data = actor:get_data()
	if data.lootbugspawned == 1 then
		data.lootbugspawned = 0
	end
end)