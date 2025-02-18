local sprite_candy = Resources.sprite_load(NAMESPACE, "moltenCandy", path.combine(PATH, "Sprites/moltenCandy.png"), 1, 17, 13)
local sprite_blob = Resources.sprite_load(NAMESPACE, "moltenCandyBlob", path.combine(PATH, "Sprites/moltenCandyBlob.png"), 1, 8, 8)
local sprite_trail = Resources.sprite_load(NAMESPACE, "moltenCandyTrail", path.combine(PATH, "Sprites/moltenCandyTrail.png"), 6, 16, 12)
local sprite_explode = Resources.sprite_load(NAMESPACE, "moltenCandyExplode", path.combine(PATH, "Sprites/moltenCandyExplode.png"), 5, 13, 18)
local sound_explode = Resources.sfx_load(NAMESPACE, "moltenCandyExplodeSnd", path.combine(PATH, "Sprites/moltenCandyExplode.ogg"))
local sprite_buff = Resources.sprite_load(NAMESPACE, "moltenCandyBuff", path.combine(PATH, "Sprites/moltenCandyBuff.png"), 1, 16, 16)

local candy = Item.new(NAMESPACE, "moltenCandy")
candy:set_sprite(sprite_candy)
candy:set_tier(Item.TIER.uncommon)
candy:set_loot_tags(Item.LOOT_TAG.category_damage)

local candydust = Particle.new(NAMESPACE, "candyParticle")

candydust:set_alpha2(1, 0)
candydust:set_shape(Particle.SHAPE.pixel)
candydust:set_life(10, 20)
candydust:set_color_rgb(255, 255, 0, 0, 0, 0)
candydust:set_speed(1, 1.5, -0.01, 0)
candydust:set_size(1.6, 2, -0.02, 0)
candydust:set_direction(90, 90, 0, 0)

local candybuff = Buff.new(NAMESPACE, "moltenCandyBuff")
candybuff.is_debuff = true
candybuff.show_icon = true
candybuff.icon_sprite = sprite_buff
candybuff:clear_callbacks()

candybuff:onApply(function(actor, stack)
	actor:get_data().candyTick = 0
end)

candybuff:onStatRecalc(function(actor, stack)
	actor.pHmax = actor.pHmax * 0.4
end)

candybuff:onPostStep(function(actor, stack)
	if gm._mod_net_isClient() then return end
	
	local data = actor:get_data()
	data.candyTick = data.candyTick + 1
	
	if data.candyTick >= 25 then
		local dmg = data.applier.damage * data.applier:item_stack_count(candy)
		actor:damage_inflict(actor, dmg, 0, data.applier, actor.x, actor.y, dmg, data.applier.team, Color.from_rgb(188, 67, 112))
		data.candyTick = 0
	end
end)

local moltenblob = Object.new(NAMESPACE, "moltenCandyBlob")
moltenblob:set_sprite(sprite_blob)

moltenblob:clear_callbacks()

moltenblob:onCreate(function(self)
	self:get_data().blob = true
	self:get_data().grounded = false
end)

moltenblob:onStep(function(self)
	local data = self:get_data()
	
	if data.blob then
		self.image_angle = self.image_angle + (-15 + self.image_xscale)
		if self:is_colliding(gm.constants.pBlock, self.x, self.y) then
			self.image_speed = 0.25
			self.image_angle = 0
			self.sprite_index = sprite_trail
			self.direction = 0
			self.gravity = 0
			self.speed = 0
			data.lifespan = 60 * 5
			data.blob = false
		end
	else
		if data.grounded then
			local buffed = 0
			for _, victim in ipairs(self:get_collisions(gm.constants.pActor)) do
				if victim.team ~= data.parent.team and victim:get_buff_time(victim, candybuff) <= 1 then
					victim:buff_apply(candybuff, 30)
					victim:get_data().applier = data.parent
					buffed = buffed + 1
				end
				if buffed >= 3 then -- max 3 buffs per tick, a cope to deal with lag
					buffed = 0
					break
				end
			end
			
			data.lifespan = data.lifespan - 1
			
			candydust:create(self.x + math.random(-16, 16), self.y)
			
			if data.lifespan <= 20 then
				self.image_alpha = self.image_alpha - 0.05
			end
			
			if data.lifespan <= 0 or self.image_alpha <= 0 then
				self:destroy()
			end
		else
			local rad = math.rad(90)
			local xx = math.cos(rad)
			local yy = math.sin(rad)
			local attempts = 0
				for i = 1, 10 do
				self.x = self.x + xx
				self.y = self.y + yy
				if self:is_colliding(gm.constants.pBlock, self.x, self.y) then
					self.x = self.x - xx
					self.y = self.y - yy
					gm.sound_play_networked(sound_explode, 1, 1, self.x, self.y)
					local explode = GM.instance_create(self.x, self.y, gm.constants.oEfExplosion)
					explode.sprite_index = sprite_explode
					data.grounded = true
				end
			end
		end
	end
end)

candy:clear_callbacks()
candy:onHitProc(function(actor, victim, stack, hit_info)
	if (math.random() <= 0.05 or hit_info.attack_info:get_attack_flag(Attack_Info.ATTACK_FLAG.force_proc)) and (#Instance.find_all(moltenblob)) < 12 then -- wont spawn if 12 puddles max already exist, another performance cope
		for i = 0, 2, 1 do
			local blob = moltenblob:create(victim.x, victim.y)
			blob.direction = math.random(45, 135)
			blob.speed = math.random(5, 7)
			blob.gravity = 0.2
			blob:get_data().parent = actor
		end
	end
end)