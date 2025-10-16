local sprite_nanomachines = Resources.sprite_load(NAMESPACE, "nanomachines", path.combine(PATH, "Sprites/item/nanomachines.png"), 1, 16, 15)

local son = Item.new(NAMESPACE, "nanomachines")
son:set_sprite(sprite_nanomachines)
son:set_tier(Item.TIER.rare)
son:set_loot_tags(Item.LOOT_TAG.category_utility, Item.LOOT_TAG.category_healing)
son:clear_callbacks()

local buffArmor = Buff.new(NAMESPACE, "nanoArmorBuff")
buffArmor:clear_callbacks()
buffArmor.max_stack = 1
buffArmor.show_icon = false

buffArmor:onStatRecalc(function(actor, stack)
	actor.armor = actor.armor + ((actor.maxshield_base * stack) * 0.5)
end)

son:onAcquire(function(actor, stack)

	if actor.nanCooldown == nil then
		actor.nanCooldown = 0
	end

	if not actor.shieldStore then
		actor.shieldStore = 0
	end
	
	if not actor.procced then
		actor.procced = false
	end

end)

son:onDamagedProc(function(actor, attacker, stack, hit_info)
--credit to TryAgain211 for helping with most of this implementation

	if actor.nanCooldown <= 0 and actor.shield < 1 and actor.hp <= actor.maxhp * 0.5 then
		actor.maxshield_base = actor.maxshield_base + (30 * stack)
		actor.shieldStore = actor.shieldStore + (30 * stack)
		actor.shield = actor.maxshield_base
		actor:recalculate_stats()
		gm.sound_play_networked(gm.constants.wDroneUpgrader_Activate, 2, 1.2, actor.x, actor.y)
		
		local flash = GM.instance_create(actor.x, actor.y, gm.constants.oEfFlash)
		flash.parent = actor
		flash.rate = 0.05
		flash.image_alpha = 1
		flash.image_blend = Color.BLACK
		
		actor.nanCooldown = 60 * 15
		actor.procced = true
	end
	
	if actor.shield < actor.maxshield_base then
		local lost = math.min(actor.maxshield_base - actor.shield, actor.shieldStore)
		actor.maxshield_base = actor.maxshield_base - lost
		actor.shieldStore = actor.shieldStore - lost
	end

end)

son:onPostStep(function(actor, stack)
	if gm.bool(actor.shield) then
		actor:buff_apply(buffArmor, 30)
	end
	
	if actor.nanCooldown and actor.nanCooldown > 0 then
		actor.nanCooldown = actor.nanCooldown - 1
	end
	
	if actor.nanCooldown and actor.nanCooldown <= 0 and actor.procced == true then
		gm.sound_play_networked(gm.constants.wDroneUpgrader_Activate, 2, 0.8, actor.x, actor.y)
		local flash = GM.instance_create(actor.x, actor.y, gm.constants.oEfFlash)
		flash.parent = actor
		flash.rate = 0.05
		flash.image_alpha = 0.8
		flash.image_blend = Color.AQUA
		actor.procced = false
	end

end)