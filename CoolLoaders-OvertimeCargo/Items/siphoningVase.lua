local sprite_vase = Resources.sprite_load(NAMESPACE, "siphoningVase", path.combine(PATH, "Sprites/siphoningVase.png"), 1, 16, 16)

local vase = Item.new(NAMESPACE, "siphoningVase")
vase:set_sprite(sprite_vase)
vase:set_tier(Item.TIER.rare)
vase:set_loot_tags(Item.LOOT_TAG.category_damage, Item.LOOT_TAG.category_healing)

vase:clear_callbacks()
vase:onAcquire(function(actor, stack)
	if actor:get_data().pulse == nil then
		actor:get_data().pulse = 0
	end
end)

vase:onPostStep(function(actor, stack)
	local i = 0
	local targetenemies = List.new()
	
	GM.collision_ellipse_list(actor.x - 180, actor.y - 180, actor.x + 180, actor.y + 180, gm.constants.pActor, false, true, targetenemies, true)
	
	for _, victim in ipairs(targetenemies) do 
		if victim.team ~= actor.team then
			i = i + 1
			if not victim:get_data().siphontick then
				victim:get_data().siphontick = 30
			end
			if i <= stack then
				if victim:get_data().siphontick > 0 then
					victim:get_data().siphontick = victim:get_data().siphontick - 1
				end
				if victim:get_data().siphontick <= 0 then
					local direct = actor:fire_direct(victim, 0.5, 0, victim.x, victim.y, nil, false)
					direct.attack_info:set_color(65535)
					actor:heal(actor.maxhp * 0.025)
					victim:buff_apply(Buff.find("ror", "oil"), 60)
					gm.sound_play_networked(gm.constants.wUse, 1, 0.8 + math.random() * 0.2, victim.x, victim.x)
					victim:get_data().siphontick = 30
					actor:get_data().pulse = 100
				end
			else
				break
			end
		end
	end
	
	targetenemies:destroy()
end)

vase:onPostDraw(function(actor, stack)
	local i = 0
	local targetenemies = List.new()
	
	if actor:get_data().pulse > 0 then
		actor:get_data().pulse = actor:get_data().pulse - 4
	end
	
	GM.collision_ellipse_list(actor.x - 180, actor.y - 180, actor.x + 180, actor.y + 180, gm.constants.pActor, false, true, targetenemies, true)
	
	for _, victim in ipairs(targetenemies) do
		if victim.team ~= actor.team then
			i = i + 1
			if i <= stack then
				gm.draw_set_colour(Color.from_hsv(100, 100, actor:get_data().pulse))
				gm.draw_line_width(actor.x, actor.y, victim.x, victim.y, 4)
			else
				break
			end
		end
	end
end)