local sprite_moonrock = Resources.sprite_load(NAMESPACE, "moonrockWhetstone", path.combine(PATH, "Sprites/moonrockWhetstone.png"), 1, 13, 5)
local sprite_buff = Resources.sprite_load(NAMESPACE, "whetstoneBuff", path.combine(PATH, "Sprites/moonrockBuff1.png"), 1, 8, 29)
local sprite_buff2 = Resources.sprite_load(NAMESPACE, "whetstoneBuff2", path.combine(PATH, "Sprites/moonrockBuff2.png"), 1, 6, -5)

local roc = Item.new(NAMESPACE, "moonrockWhetstone")
roc:set_sprite(sprite_moonrock)
roc:set_tier(Item.TIER.common)
roc:set_loot_tags(Item.LOOT_TAG.category_damage)
roc:clear_callbacks()

local buff = Buff.new(NAMESPACE, "moonrockBuff")
buff.show_icon = false
buff.icon_sprite = sprite_buff
buff:clear_callbacks()

--i dont want to do this but this draws over the crit icon
--setting depth doesn't work for some reason
local buff2 = Buff.new(NAMESPACE, "moonrockBuff2")
buff2.show_icon = true
buff2.icon_sprite = sprite_buff2
buff2:clear_callbacks()


buff:onStatRecalc(function(actor, stack)
	actor.critical_chance = actor.critical_chance + (9 + (3 * stack))
end)

roc:onAcquire(function(actor, stack)
	if stack == 1 then
	gm.sound_play_networked(gm.constants.wCrit, 1, 0.5, actor.x, actor.y)
	end
end)

roc:onAttackCreate(function(actor, stack, attack_info)
    local total_crit = actor.critical_chance
    if attack_info.bonus_crit then 
		total_crit = total_crit + attack_info.bonus_crit 
	end

    if attack_info.critical then
        if stack > 1 then 
			total_crit = total_crit + (2 + (3 * stack))
		end
        attack_info.damage = attack_info.damage + (2 + (3 * stack))
		attack_info:set_color(Color.from_hsv(205, 12 + (3 * stack), 100))
    end
end)

roc:onPostStep(function(actor, stack)
	local tp = Instance.find(gm.constants.oTeleporter)
	local data = actor:get_data()
	
	actor:buff_apply(buff2, 30)
	
	if tp.just_activated == 1 then
		actor:buff_apply(buff, 30)
	end
	
end)

roc:onPreDraw(function(actor, stack)
	local tp = Instance.find(gm.constants.oTeleporter)
	local data = actor:get_data()
	local buffDraw = 1
	local buffDraw2 = 1
	local yOffset = gm.sprite_get_yoffset(actor.sprite_idle)
	
	-- buffDraw2 = actor:draw_sprite(sprite_buff2, 0, actor.x, actor.y - yOffset)
	-- if not buffDraw2 == 1 then
		-- buffDraw2.parent = actor
		-- buffDraw2:object_set_depth(-900)
	-- end
	
	if tp.just_activated == 1 then
		buffDraw = actor:draw_sprite(sprite_buff, 0, actor.x, actor.y - yOffset)
		if not buffDraw == 1 then
			buffDraw.parent = actor
			buffDraw:object_set_depth(9999)
		end
	end
	
end)