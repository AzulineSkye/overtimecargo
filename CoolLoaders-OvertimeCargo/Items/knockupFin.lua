local sprite_fin = Resources.sprite_load(NAMESPACE, "knockupFin", path.combine(PATH, "Sprites/knockupFin.png"), 1, 16, 16)

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
	
	if data.knockup_timer > 25 or actor.pVspeed > 0 then
		actor.pVspeed = actor.pVspeed + 5
		actor.fallImmunity = true
		if actor:is_grounded() then
			local explosion = actor.parent:fire_explosion(actor.x, actor.y + 12, 304, 32, 0.5 * actor.parent:item_stack_count(fin), nil, nil, false)
			explosion.attack_info:set_stun(1)
			rubble:create(actor.x, actor.y, 5)
			gm.sound_play_networked(gm.constants.wGolemAttack1, 1, 0.8 + math.random() * 0.2, actor.x, actor.y)
			actor:screen_shake(15)
			actor:buff_remove(debuffknockup)
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
	if math.random() <= 0.1 or hit_info.attack_info:get_attack_flag(Attack_Info.ATTACK_FLAG.force_proc) then
		if GM.actor_is_classic(victim) and not GM.actor_is_boss(victim) then
			victim.parent = actor
			gm.sound_play_networked(gm.constants.wMushShoot1, 1.5, 1 + math.random() * 0.5, victim.x, victim.y)
			victim:buff_apply(debuffknockup, 600)
		end
	end
end)