local sprite_block = Resources.sprite_load(NAMESPACE, "knifeBlock", path.combine(PATH, "Sprites/knifeBlock.png"), 2, 16, 17)
local sprite_block_empty = Resources.sprite_load(NAMESPACE, "knifeBlockEmpty", path.combine(PATH, "Sprites/knifeBlockEmpty.png"), 2, 16, 17)
local sprite_cut = Resources.sprite_load(NAMESPACE, "skillCut", path.combine(PATH, "Sprites/skillCut.png"), 9, 55, 70)
local sprite_cut_throw = Resources.sprite_load(NAMESPACE, "skillCutThrow", path.combine(PATH, "Sprites/skillCutThrow.png"), 1, 25, 5)
local sprite_cut_icon = Resources.sprite_load(NAMESPACE, "skillCutIcon", path.combine(PATH, "Sprites/skillCutIcon.png"), 1)

local block = Equipment.new(NAMESPACE, "knifeBlock")
block:set_sprite(sprite_block)
block:set_loot_tags(Item.LOOT_TAG.category_damage, Item.LOOT_TAG.equipment_blacklist_chaos)
block:set_cooldown(0.5)

local swipe = Object.new(NAMESPACE, "knifeBlockCutSwipe")
swipe:clear_callbacks()
swipe:set_sprite(sprite_cut)

local wound = Buff.find("ror", "commandoWound")

swipe:onDraw(function(self)
	local parent = self:get_data().parent
	self.x = parent.x
	self.y = parent.y
	self.image_speed = parent.attack_speed * 0.25
	if self.image_index >= 8 then
		self:destroy()
		return
	end
end)

local knife = Object.new(NAMESPACE, "knifeBlockCutThrow")
knife:clear_callbacks()
knife:set_sprite(sprite_cut_throw)

knife:onCreate(function(self)
	self.speed = 20
	self:get_data().trailtimer = 0
	self:get_data().hit = 0
	self:get_data().lifetime = 0
	self:sound_play(gm.constants.wMercenary_Parry_StandardSlash, 1, 0.9 + math.random() * 0.1)
end)

knife:onStep(function(self)
	if not self.parent:exists() then
		self:destroy()
		return
	end
	local data = self:get_data()
	
	data.trailtimer = data.trailtimer + 1
	data.lifetime = data.lifetime + 1
	
	if data.trailtimer >= 3 and data.hit == 0 then
		local trail = GM.instance_create(self.x, self.y, gm.constants.oEfTrail)
		trail.sprite_index = self.sprite_index
		trail.image_index = self.image_index
		trail.image_blend = gm.merge_colour(self.image_blend, Color.BLACK, 0.5)
		trail.image_xscale = self.image_xscale
		trail.image_yscale = self.image_yscale
		trail.depth = self.depth + 1
		data.trailtimer = 0
	end
	
	if self.parent:is_authority() and data.hit == 0 then
		for _, victim in ipairs(self:get_collisions(gm.constants.pActor)) do
			if victim.team ~= self.team then
				if not GM.skill_util_update_heaven_cracker(self.parent, damage, self.parent.image_xscale) then
					local buff_shadow_clone = Buff.find("ror", "shadowClone")
					for i=0, self.parent:buff_stack_count(buff_shadow_clone) do
						data.hit = 1
						self.gravity = 0.3
						self.direction = 90 + math.random(0, 30) * self.image_xscale
						self.speed = math.random(5, 7)
						local direct = self.parent:fire_direct(victim, 2, self.direction, victim.x, victim.y, gm.constants.sSparks9, false).attack_info
						if victim:buff_stack_count(wound) > 0 then
							victim:apply_dot(1, self.parent, 4, 30, Color.RED)
							direct.knifeBlockWound = 1
						end
						direct.climb = i * 8
						break
					end
				end
			end
		end
	end
	
	if data.hit == 1 then
		self.image_angle = self.image_angle + 8 * self.image_xscale
	end
	
	if data.lifetime > 60 * 20 then
		self:destroy()
		return
	end
end)

local cut = Skill.new(NAMESPACE, "knifeBlockCut")
cut:clear_callbacks()
cut:set_skill_icon(sprite_cut_icon, 1)
cut.cooldown = 15
cut.is_primary = true
cut.damage = 0.5
cut.hold_facing_direction = true
cut.required_interrupt_priority = State.ACTOR_STATE_INTERRUPT_PRIORITY.any

local state_cut = State.new(NAMESPACE, "knifeBlockCut")
state_cut:clear_callbacks()

cut:onActivate(function(actor)
	actor:enter_state(state_cut)
end)

state_cut:onEnter(function(actor, data)
	data.fired = 0
	actor.activity_type = 4
	actor:get_data().swipe = swipe:create(actor.x, actor.y)
	actor:get_data().swipe.image_xscale = actor.image_xscale
	actor:get_data().swipe:get_data().parent = actor
	actor:sound_play(gm.constants.wCrit2, 1, 0.9 + math.random() * 0.1)
end)

state_cut:onStep(function(actor, data)
	actor.pHspeed = actor.pHspeed * 0.65

	if actor:is_authority() and data.fired == 0 and actor:get_data().swipe.image_index >= 4 then
		local damage = actor:skill_get_damage(cut)
		
		actor:sound_play(gm.constants.wMinerShoot1_1, 1, 0.8 + math.random() * 0.4)
		if not GM.skill_util_update_heaven_cracker(actor, damage, actor.image_xscale) then
			local buff_shadow_clone = Buff.find("ror", "shadowClone")
			for i=0, actor:buff_stack_count(buff_shadow_clone) do
				local slash = actor:fire_explosion(actor.x + actor.image_xscale * 30, actor.y - 15, 130, 110, damage, nil, gm.constants.sSparks9).attack_info
				slash.climb = i * 8
				slash.knifeBlockWound = 1
			end
		end
		
		data.fired = 1
	end
	
	if actor:get_data().swipe:exists() == false then
		actor:skill_util_reset_activity_state()
	end
end)

state_cut:onExit(function(actor, data)
	actor:get_data().swipe:destroy()
end)

state_cut:onGetInterruptPriority(function(actor, data)
	if actor:get_data().swipe.image_index >= 5 then
		return State.ACTOR_STATE_INTERRUPT_PRIORITY.skill_interrupt_period
	end
end)

Callback.add(Callback.TYPE.onAttackHit, "knifeBlockWound", function(hit_info)
	local woundmaxstack = hit_info.attack_info.knifeBlockWound
	if woundmaxstack and woundmaxstack > 0 then
		victim = hit_info.target
		if victim:buff_stack_count(wound) <  woundmaxstack then
			GM.apply_buff(victim, wound, 6 * 60, 1)
		else
			GM.set_buff_time(victim, wound, 6 * 60)
		end
	end
end)

Callback.add(Callback.TYPE.onGameEnd, "resetKnifeBlockSprite", function()
	block:set_sprite(sprite_block)
	block:set_cooldown(0.5)
end)

block:clear_callbacks()
block:onUse(function(actor)
	if actor:get_data().holdingknife == nil then
		block:set_sprite(sprite_block_empty)
		block:set_cooldown(8)
		actor:get_data().holdingknife = true
		actor:add_skill_override(Skill.SLOT.primary, cut, 10)
	else
		block:set_sprite(sprite_block)
		block:set_cooldown(0.5)
		actor:get_data().holdingknife = nil
		actor:remove_skill_override(Skill.SLOT.primary, cut, 10)
		
		local knifethrow = knife:create(actor.x + 30 * actor.image_xscale, actor.y)
		knifethrow.parent = actor
		knifethrow.team = actor.team
		knifethrow.direction = actor:skill_util_facing_direction()
		knifethrow.image_xscale = actor.image_xscale
	end
end)

block:onDrop(function(actor)
	if actor:get_data().holdingknife ~= nil then
		local knifethrow = knife:create(actor.x - 12 * actor.image_xscale, actor.y)
		knifethrow.parent = actor
		knifethrow.team = actor.team
		knifethrow.direction = actor:skill_util_facing_direction()
		knifethrow.image_xscale = actor.image_xscale
	end
	block:set_sprite(sprite_block)
	block:set_cooldown(0.5)
	actor:get_data().holdingknife = nil
	actor:remove_skill_override(Skill.SLOT.primary, cut, 10)
end)