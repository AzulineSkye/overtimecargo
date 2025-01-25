local sprite_fin = Resources.sprite_load(NAMESPACE, "knockupFin", path.combine(PATH, "Sprites/knockupFin.png"), 1, 16, 16)
local eLem = Object.find("ror", "LizardF")
local eLemG = Object.find("ror", "LizardFG")

local fin = Item.new(NAMESPACE, "knockupFin")
fin:set_sprite(sprite_fin)
fin:set_tier(Item.TIER.common)
fin:set_loot_tags(Item.LOOT_TAG.category_damage)

local debuffknockup = Buff.new(NAMESPACE, "debuffknockup")
debuffknockup.show_icon = false
debuffknockup.is_debuff = true
debuffknockup.max_stack = 1

local rubble = Particle.find("ror", "Rubble1")

debuffknockup:clear_callbacks()
debuffknockup:onApply(function(actor, stack)
	actor:get_data().knockup_timer = 0
	actor.pVspeed = -14
end)

debuffknockup:onPostStep(function(actor, stack)
	if gm._mod_net_isClient() then return end
	
	local data = actor:get_data()
	data.knockup_timer = data.knockup_timer + 1
	
	if actor:is_colliding(gm.constants.pBlock, actor.x, actor.y - 6) and GM.actor_is_classic(actor) then
		data.knockup_timer = 25
	end

	if not GM.actor_is_boss(actor) and not GM.actor_is_classic(actor) and data.knockup_timer < 24 then
		actor.y = actor.y - 11
	end

	if data.knockup_timer > 25 then
		if GM.actor_is_classic(actor) then
			actor.pVspeed = actor.pVspeed + 5
			actor.fallImmunity = true
			if actor:is_grounded() then
				local explosion = actor.parent:fire_explosion(actor.x, actor.y + 12, 152, 32, 0.3 * actor.parent:item_stack_count(fin), nil, nil, false).attack_info
				explosion:set_stun(0.5)
				rubble:create(actor.x, actor.y, 5)
				gm.sound_play_networked(gm.constants.wGolemAttack1, 1, 0.8 + math.random() * 0.2, actor.x, actor.y)
				actor:screen_shake(15)
				actor:buff_remove(debuffknockup)
			end
		end
		if not GM.actor_is_boss(actor) and not GM.actor_is_classic(actor) then
			actor.y = actor.y + 25
			if actor:is_colliding(gm.constants.pBlock, actor.x, actor.y + 5) then
				local explosion = actor.parent:fire_explosion(actor.x, actor.y + 12, 152, 32, 0.3 * actor.parent:item_stack_count(fin), nil, nil, false).attack_info
				explosion:set_stun(0.5)
				rubble:create(actor.x, actor.y, 5)
				gm.sound_play_networked(gm.constants.wGolemAttack1, 1, 0.8 + math.random() * 0.2, actor.x, actor.y)
				actor:screen_shake(15)
				actor:buff_remove(debuffknockup)
			end
		end
	end
end)

local guarded = false

gm.pre_script_hook(gm.constants.actor_phy_on_landed, function(self, other, result, args)
	local real_self = Instance.wrap(self)
    if not gm.bool(self.invincible) and real_self.fallImmunity then
        self.invincible = 1
		guarded = true
		real_self.fallImmunity = false
    end
end)

gm.post_script_hook(gm.constants.actor_phy_on_landed, function(self, other, result, args)
    if guarded then
        self.invincible = 0
        guarded = false
    end
end)

fin:clear_callbacks()
fin:onHitProc(function(actor, victim, stack, hit_info)
	if math.random() <= 0.9 or hit_info.attack_info:get_attack_flag(Attack_Info.ATTACK_FLAG.force_proc) then
		victim.parent = actor
		if GM.actor_is_classic(victim) or not GM.actor_is_boss(victim) then -- doesnt work
			if victim.object_index ~= gm.constants.oLizardFG and victim.object_index ~= gm.constants.oLizardF then
				victim:buff_apply(debuffknockup, 600)
			end
		end
	end
end)