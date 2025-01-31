local sprite_treatment = Resources.sprite_load(NAMESPACE, "specialTreatment", path.combine(PATH, "Sprites/specialTreatment.png"), 1, 16, 16)
local sprite_treatment_used = Resources.sprite_load(NAMESPACE, "specialTreatmentConsumed", path.combine(PATH, "Sprites/specialTreatmentConsumed.png"), 1, 16, 16)
local sprite_buff_icon = Resources.sprite_load(NAMESPACE, "specialTreatmentBuff", path.combine(PATH, "Sprites/specialTreatmentBuff.png"), 1, 18, 14)

local treatment = Item.new(NAMESPACE, "specialTreatment")
treatment:clear_callbacks()
treatment:set_sprite(sprite_treatment)
treatment:set_tier(Item.TIER.common)
treatment:set_loot_tags(Item.LOOT_TAG.category_healing)

local treatment_used = Item.new(NAMESPACE, "specialTreatmentConsumed", true)
treatment_used:set_sprite(sprite_treatment_used)
treatment_used:set_loot_tags(Item.LOOT_TAG.item_blacklist_vendor, Item.LOOT_TAG.item_blacklist_infuser)
treatment_used:clear_callbacks()

local parspeed = Particle.find("ror", "Fire2")
parspeed:set_alpha2(0.75, 0)

local buffspeed = Buff.new(NAMESPACE, "specialTreatmentSpeed")
buffspeed:clear_callbacks()
buffspeed.max_stack = 1
buffspeed.show_icon = true
buffspeed.icon_sprite = sprite_buff_icon

buffspeed:onStatRecalc(function(actor, stack)
	actor.pHmax = actor.pHmax + 0.7 * (actor:item_stack_count(treatment_used) + actor:item_stack_count(treatment))
end)

buffspeed:onPostStep(function(actor, stack)
	actor:get_data().parspeed = actor:get_data().parspeed + 1
	
	if gm.bool(actor.barrier) and actor:get_data().parspeed >= 6 then
		parspeed:create(actor.x, actor.y - math.random(-6, 6), 1, Particle.SYSTEM.below)
		actor:get_data().parspeed = 0
	end
end)

treatment:onAcquire(function(actor, stack)
	actor:get_data().parspeed = 0
end)

treatment:onDamagedProc(function(actor, attacker, stack, hit_info)
	if actor.hp < actor.maxhp * 0.249 and 0 >= actor.barrier - hit_info.damage then
		actor:add_barrier(actor.maxbarrier * 0.75)
		local flash = GM.instance_create(actor.x, actor.y, gm.constants.oEfFlash)
		flash.parent = actor
		flash.rate = 0.1
		flash.image_alpha = 0.5
		flash.image_blend = Color.YELLOW
		gm.sound_play_networked(gm.constants.wBarrierActivate, 1, 0.8 + math.random() * 0.2, actor.x, actor.y)
		gm.sound_play_networked(gm.constants.wChildDeath, 1, 1.6 + math.random() * 0.4, actor.x, actor.y)
		actor:item_remove(treatment)
		actor:item_give(treatment_used)
	end
end)

treatment:onPostStep(function(actor, stack)
	if gm.bool(actor.barrier) then
		actor:buff_apply(buffspeed, 30)
	else
		actor:buff_remove(buffspeed, 30)
	end
end)

treatment_used:onAcquire(function(actor, stack)
	actor:get_data().parspeed = 0
end)

treatment_used:onStageStart(function(actor, stack)
	actor:item_give(treatment, actor:item_stack_count(treatment_used))
	actor:item_remove(treatment_used, actor:item_stack_count(treatment_used))
end)

treatment_used:onPostStep(function(actor, stack)
	if gm.bool(actor.barrier) then
		actor:buff_apply(buffspeed, 30)
	else
		actor:buff_remove(buffspeed, 30)
	end
end)