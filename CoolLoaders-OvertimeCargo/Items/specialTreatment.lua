local sprite_treatment = Resources.sprite_load(NAMESPACE, "specialTreatment", path.combine(PATH, "Sprites/specialTreatment.png"), 1, 16, 16)
local sprite_treatment_used = Resources.sprite_load(NAMESPACE, "specialTreatmentConsumed", path.combine(PATH, "Sprites/specialTreatmentConsumed.png"), 1, 16, 16)

local treatment = Item.new(NAMESPACE, "specialTreatment")
treatment:clear_callbacks()
treatment:set_sprite(sprite_treatment)
treatment:set_tier(Item.TIER.common)
treatment:set_loot_tags(Item.LOOT_TAG.category_healing)

local treatment_used = Item.new(NAMESPACE, "specialTreatmentConsumed")
treatment_used:set_sprite(sprite_treatment_used)
treatment_used:clear_callbacks()

treatment:onDamagedProc(function(actor, attacker, stack, hit_info)
	if actor.hp < actor.maxhp * 0.5 and 0 >= actor.barrier - hit_info.damage then
		actor:add_barrier(actor.maxbarrier * 0.5)
		local flash = GM.instance_create(actor.x, actor.y, gm.constants.oEfFlash)
		flash.parent = actor
		flash.rate = 0.1
		flash.image_alpha = 0.5
		flash.image_blend = Color.YELLOW
		gm.sound_play_networked(gm.constants.wBarrierActivate, 1, 0.8 + math.random() * 0.2, actor.x, actor.y)
		gm.sound_play_networked(gm.constants.wChildDeath, 2, 0.8 + math.random() * 0.2, actor.x, actor.y)
		actor:item_remove(treatment)
		actor:item_give(treatment_used)
	end
end)

treatment_used:onStageStart(function(actor, stack)
	actor:item_give(treatment, actor:item_stack_count(treatment_used))
	actor:item_remove(treatment_used, actor:item_stack_count(treatment_used))
end)