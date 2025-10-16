local sprite_moonrock = Resources.sprite_load(NAMESPACE, "moonStone", path.combine(PATH, "Sprites/item/moonrockWhetstone.png"), 1, 13, 5)
local sprite_buff = Resources.sprite_load(NAMESPACE, "whetstoneBuff", path.combine(PATH, "Sprites/buffs/moonrockBuff1.png"), 1, 8, 29)
local sprite_buff2 = Resources.sprite_load(NAMESPACE, "whetstoneBuff2", path.combine(PATH, "Sprites/buffs/moonrockBuff2.png"), 1, 6, 27)

local roc = Item.new(NAMESPACE, "moonStone")
roc:set_sprite(sprite_moonrock)
roc:set_tier(Item.TIER.common)
roc:set_loot_tags(Item.LOOT_TAG.category_damage)
roc:clear_callbacks()

--buff to be applied during tp
local buff = Buff.new(NAMESPACE, "moonrockBuff")
buff.show_icon = false
buff.icon_sprite = sprite_buff
buff:clear_callbacks()

--increase crit chance
buff:onStatRecalc(function(actor, stack)
	actor.critical_chance = actor.critical_chance + (9 + (3 * stack))
end)

--funny indicator
roc:onAcquire(function(actor, stack)
	if stack == 1 then
	gm.sound_play_networked(gm.constants.wCrit, 1, 0.5, actor.x, actor.y)
	end
end)

--increase crit damage
roc:onAttackCreate(function(actor, stack, attack_info)
    local total_crit = actor.critical_chance
    if attack_info.bonus_crit then 
		total_crit = total_crit + attack_info.bonus_crit 
	end

    if attack_info.critical then
        if stack > 1 then 
			total_crit = total_crit + (2 + (3 * stack))
		end
		--modify crit damage numbers for fun
		--(affects ceremonial dagger dmg numbers for some reason?)
        attack_info.damage = attack_info.damage + (2 + (3 * stack))
		attack_info:set_color(Color.from_hsv(205, 12 + (3 * stack), 100))
    end
end)

--keep the buff active after activating tp
roc:onPostStep(function(actor, stack)
	local tp = Instance.find(gm.constants.oTeleporter)
	local dtp = Instance.find(gm.constants.oTeleporterEpic)
	local com = Instance.find(gm.constants.oCommand)
	local data = actor:get_data()
	
	if tp.just_activated == 1 or dtp.just_activated == 1 or com.just_activated == 1 then
		actor:buff_apply(buff, 30)
	end
	
end)

--for some reason, draws the sprite the highest
--(above critglasses icon)
roc:onPostDraw(function(actor)
	local data = actor:get_data()
	local yOffset = gm.sprite_get_yoffset(actor.sprite_idle)
	
	actor:draw_sprite(sprite_buff2, 0, actor.x, actor.y - yOffset)
	
end)

--for some reason, draws the sprite the lowest
--(below critglasses icon)
roc:onPreDraw(function(actor)
	local tp = Instance.find(gm.constants.oTeleporter)
	local dtp = Instance.find(gm.constants.oTeleporterEpic)
	local com = Instance.find(gm.constants.oCommand)
	local data = actor:get_data()
	local yOffset = gm.sprite_get_yoffset(actor.sprite_idle)
	
	if tp.just_activated == 1 or dtp.just_activated == 1 or com.just_activated == 1 then
		actor:draw_sprite(sprite_buff, 0, actor.x, actor.y - yOffset)
	end

end)