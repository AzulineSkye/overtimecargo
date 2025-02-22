local sprite_triangle = Resources.sprite_load(NAMESPACE, "resonatingTriangle", path.combine(PATH, "Sprites/resonatingTriangle.png"), 1, 16, 16)
local sprite_buff = Resources.sprite_load(NAMESPACE, "resonatingTriangleBuff", path.combine(PATH, "Sprites/resonatingTriangleBuff.png"), 1, 10, 8)

local tri = Item.new(NAMESPACE, "resonatingTriangle")
tri:set_sprite(sprite_triangle)
tri:set_tier(Item.TIER.common)
tri:set_loot_tags(Item.LOOT_TAG.category_damage)
tri:clear_callbacks()

local buff = Buff.new(NAMESPACE, "resonatingTriangleBuff")
buff.show_icon = true
buff.icon_sprite = sprite_buff
buff:clear_callbacks()

tri:onAcquire(function(actor, stack)
	if actor:get_data().triangletimer == nil then
		actor:get_data().triangletimer = 0
	end
	if actor:get_data().triangleactivated == nil then
		actor:get_data().triangleactivated = false
	end
end)

tri:onPostStep(function(actor, stack)
	if actor:get_data().triangletimer > 0 then
		actor:get_data().triangletimer = actor:get_data().triangletimer - 1
	else
		actor:buff_apply(buff, 30)
		if actor:get_data().triangleactivated == false then
			gm.sound_play_networked(gm.constants.wCrit, 1, 1, actor.x, actor.y)
			actor:get_data().triangleactivated = true
		end
	end
end)

tri:onDamagedProc(function(actor, stack)
	actor:get_data().triangletimer = 7 * 60
	actor:get_data().triangleactivated = false
	actor:buff_remove(buff)
	if actor:buff_stack_count(buff) > 0 then
		gm.sound_play_networked(gm.constants.wCrit2, 1, 1, actor.x, actor.y)
	end
	actor:buff_remove(buff)
end)

tri:onAttackHit(function(actor, victim, stack, hit_info)
	if actor:buff_stack_count(buff) > 0 and victim:exists() then
		victim:damage_inflict(victim, hit_info.damage * 0.12 * stack, 0, actor, victim.x, victim.y, hit_info.damage * 0.12 * stack, actor.team, Color.from_rgb(144, 144, 255))
	end
end)