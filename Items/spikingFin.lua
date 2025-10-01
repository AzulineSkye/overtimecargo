local sprite_fin = Resources.sprite_load(NAMESPACE, "spikingFin", path.combine(PATH, "Sprites/item/spikingFin.png"), 1, 16, 16)
local eLem = Object.find("ror", "LizardF")
local eLemG = Object.find("ror", "LizardFG")

local fin = Item.new(NAMESPACE, "spikingFin")
fin:set_sprite(sprite_fin)
fin:set_tier(Item.TIER.uncommon)
fin:set_loot_tags(Item.LOOT_TAG.category_damage)
fin:clear_callbacks()

local shockwave = Object.new(NAMESPACE, "spikingFinShockwave")
shockwave:clear_callbacks()
shockwave.obj_sprite = gm.constants.sSparks4

shockwave:onCreate(function(self)
	self.image_speed = 0
	self.image_index = 0
	self.speed = 12
	self.parent = self:get_data().parent
	self:get_data().hit_list = {}
	self:get_data().lifetime = 50
	self:move_contact_solid(270, -1)
end)
shockwave:onStep(function(self)
	if not Instance.exists(self.parent) then
		self:destroy()
		return
	end

	local data = self:get_data()

	data.lifetime = data.lifetime - 1
	if data.lifetime < 0 then
		self:destroy()
		return
	end
	
	self.image_index = math.min(4, math.floor((50 - data.lifetime) / 10))
	
	self.speed = self.speed * 0.95
	self.image_xscale = self.image_xscale * 0.97

	local actors = self:get_collisions(gm.constants.pActorCollisionBase)

	for _, actor in ipairs(actors) do
		if self:attack_collision_canhit(actor) and not data.hit_list[actor.id] then
			if gm._mod_net_isHost() then
				if actor.elite_type ~= -1 then
					local direct = self.parent:fire_direct(actor, 1, self.direction, self.x, self.y, gm.constants.sSparks11).attack_info
					direct:set_damage((self:get_data().enemymaxhp * ((0.13 * self.parent:item_stack_count(fin)) / (1 + 0.13 * self.parent:item_stack_count(fin)))) * 0.5)
					direct:set_stun(1)
				else
					local direct = self.parent:fire_direct(actor, 1, self.direction, self.x, self.y, gm.constants.sSparks11).attack_info
					direct:set_damage(self:get_data().enemymaxhp * ((0.13 * self.parent:item_stack_count(fin)) / (1 + 0.13 * self.parent:item_stack_count(fin))))
					direct:set_stun(1)					
					
				end
			end 	
			data.hit_list[actor.id] = true
		end
	end
end)

local debuffspiking = Buff.new(NAMESPACE, "debuffspiking")
debuffspiking.show_icon = false
debuffspiking.is_debuff = true
debuffspiking.max_stack = 1

local rubble = Particle.find("ror", "Rubble1")

debuffspiking:clear_callbacks()
debuffspiking:onApply(function(actor, stack)
	actor:get_data().spiking_timer = 0
	actor.pVspeed = -14
end)

debuffspiking:onPostStep(function(actor, stack)
	if gm._mod_net_isClient() then return end
	
	actor:set_immune(1)
	
	local data = actor:get_data()
	data.spiking_timer = data.spiking_timer + 1
	
	if actor:is_colliding(gm.constants.pBlock, actor.x, actor.y - 6) and GM.actor_is_classic(actor) then
		data.spiking_timer = 25
	end

	if not GM.actor_is_boss(actor) and not GM.actor_is_classic(actor) and data.spiking_timer < 24 then
		actor.y = actor.y - 11
	end

	if data.spiking_timer > 25 then
		if not GM.actor_is_boss(actor) and GM.actor_is_classic(actor) then
			actor.pVspeed = actor.pVspeed + 5
			actor.fallImmunity = true
			if actor:is_colliding(gm.constants.pBlock, actor.x, actor.y + 5) then
				if data.applier:exists() then
					local wave1 = shockwave:create(actor.x, actor.y + 10)
					wave1.parent = data.applier
					wave1:get_data().enemymaxhp = actor.maxhp
					wave1.team = data.applier.team
					wave1.direction = 0
					wave1.image_xscale = 1
					local wave2 = shockwave:create(actor.x, actor.y + 10)
					wave2.parent = data.applier
					wave2:get_data().enemymaxhp = actor.maxhp
					wave2.team = data.applier.team
					wave2.direction = 180
					wave2.image_xscale = -1
				end
				rubble:create(actor.x, actor.y, 5)
				gm.sound_play_networked(gm.constants.wGolemAttack1, 0.8, 0.8 + math.random() * 0.2, actor.x, actor.y)
				gm.sound_play_networked(gm.constants.wLizardF_FlyingAttackStart, 0.8, 0.8 + math.random() * 0.2, actor.x, actor.y)
				actor:screen_shake(15)
				actor:buff_remove(debuffspiking)
			end
		end
		if not GM.actor_is_boss(actor) and not GM.actor_is_classic(actor) then
			actor.y = actor.y + 25
			if actor:is_colliding(gm.constants.pBlock, actor.x, actor.y + 5) then
				if data.applier:exists() then
					local wave1 = shockwave:create(actor.x, actor.y + 10)
					wave1.parent = data.applier
					wave1.team = data.applier.team
					wave1.direction = 0
					wave1.image_xscale = 1
					local wave2 = shockwave:create(actor.x, actor.y + 10)
					wave2.parent = data.applier
					wave2.team = data.applier.team
					wave2.direction = 180
					wave2.image_xscale = -1
				end
				rubble:create(actor.x, actor.y, 5)
				gm.sound_play_networked(gm.constants.wGolemAttack1, 0.8, 0.8 + math.random() * 0.2, actor.x, actor.y)
				gm.sound_play_networked(gm.constants.wLizardF_FlyingAttackStart, 0.8, 0.8 + math.random() * 0.2, actor.x, actor.y)
				actor:screen_shake(15)
				actor:buff_remove(debuffspiking)
			end
		end
	end
end)

debuffspiking:onRemove(function(actor, stack)
	actor:kill()
end)

local guarded = false

gm.pre_script_hook(gm.constants.actor_phy_on_landed, function(self, other, result, args)
    local real_self = Instance.wrap(self)
    if not gm.bool(self.intangible) and real_self.fallImmunity then
        self.intangible = 1
        guarded = true
        real_self.fallImmunity = false
    end
end)

gm.post_script_hook(gm.constants.actor_phy_on_landed, function(self, other, result, args)
    if guarded then
        self.intangible = 0
        guarded = false
    end
end)

Callback.add(Callback.TYPE.onDamagedProc, "spikingFinExecute", function(actor, hit_info)
	local inflictor = (Instance.wrap(hit_info.inflictor))
	if GM.actor_is_classic(actor) and not GM.actor_is_boss(actor) then
		if actor.object_index ~= gm.constants.oLizardFG and actor.object_index ~= gm.constants.oLizardF then
			if inflictor:exists() and inflictor:item_stack_count(fin) > 0 then
				if actor.elite_type ~= -1 and actor.hp <= actor.maxhp * ((0.13 * inflictor:item_stack_count(fin)) / (1 + 0.13 * inflictor:item_stack_count(fin))) then
					if actor.hp <= 0 then
						actor.hp = 1
						actor.dead = false
					end
					actor:get_data().applier = inflictor
					actor:buff_apply(debuffspiking, 600)
				end
			end
		end
	end
end)
