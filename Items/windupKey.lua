local sprite_key = Resources.sprite_load(NAMESPACE, "windupKey", path.combine(PATH, "Sprites/windupKey.png"), 1, 16, 16)
local sprite_bolts = Resources.sprite_load(NAMESPACE, "windupKeyParticles", path.combine(PATH, "Sprites/windupKeyParticles.png"), 5, 3, 3)
local sprite_vfx = Resources.sprite_load(NAMESPACE, "windupKeyVFX", path.combine(PATH, "Sprites/windupKeyVFX.png"), 8, 10, 20)

local key = Item.new(NAMESPACE, "windupKey")
key:set_sprite(sprite_key)
key:set_tier(Item.TIER.uncommon)
key:set_loot_tags(Item.LOOT_TAG.category_damage)
key:clear_callbacks()

local bolts = Particle.new(NAMESPACE, "windupKeyParticles")
bolts:set_life(300, 300)
bolts:set_sprite(sprite_bolts, false, false, true)
bolts:set_orientation(0, 360, -4, 0, false)
bolts:set_gravity(0.2, 270)
bolts:set_speed(5, 7, 0, 0)
bolts:set_scale(1, 1)

local keyvfx = Object.new(NAMESPACE, "windupKeyVFX")
keyvfx:set_sprite(sprite_vfx)
keyvfx:clear_callbacks()

keyvfx:onDraw(function(self)
	local keyparent = self:get_data().keyparent
	
	if keyparent:exists() == false or self:get_data().keyparent == nil then
		self:destroy()
	end
	
	self.x = keyparent.x + keyparent.pHspeed
	self.ghost_x = keyparent.ghost_x + keyparent.pHspeed
	self.y = keyparent.y + keyparent.pVspeed - 60
	self.ghost_y = keyparent.ghost_y + keyparent.pVspeed - 60
	
	if keyparent:get_data().windupkeybullets < 25 + 25 * keyparent:item_stack_count(key) then
		if keyparent:get_data().windupkeyshooting == true then
			self.image_speed = 0.9
		elseif math.abs(keyparent.pHspeed) > 0 then
			self.image_speed = 0.2
		else
			self.image_speed = 0
		end
	else
		self.image_speed = 0
	end
end)

key:onAcquire(function(actor, stack)
	if actor:get_data().windupkeytimer == nil then
		actor:get_data().windupkeytimer = 0
	end
	if actor:get_data().windupkeybullets == nil then
		actor:get_data().windupkeybullets = 0
	end
	if actor:get_data().windupkeyshooting == nil then
		actor:get_data().windupkeyshooting = false
	end
end)

key:onPostStep(function(actor, stack)
	local data = actor:get_data()
	if data.keyvfx == nil or data.keyvfx:exists() == false then
		local instkeyvfx = keyvfx:create(actor.x, actor.y)
		instkeyvfx:get_data().keyparent = actor
		instkeyvfx.image_speed = 0
		data.keyvfx = instkeyvfx
	end
	if data.windupkeyshooting == false then
		if math.abs(actor.pHspeed) > 0 and data.windupkeytimer < 3 then
			data.windupkeytimer = data.windupkeytimer + 1
		else
			data.windupkeytimer = 0
		end
		
		if data.windupkeytimer >= 3 and data.windupkeybullets < 25 + 25 * stack then
			data.windupkeybullets = data.windupkeybullets + 0.125 + 0.125 * stack
			data.windupkeytimer = 0
			if data.windupkeybullets >= 25 + 25 * stack then
				gm.sound_play_networked(gm.constants.wSniperReload, 1, 1, actor.x, actor.y)
				local flash = GM.instance_create(actor.x, actor.y, gm.constants.oEfFlash)
				flash.parent = actor
				flash.rate = 0.05
				flash.image_alpha = 1
				local flashkey = GM.instance_create(data.keyvfx.x, data.keyvfx.y, gm.constants.oEfFlash)
				flashkey.parent = data.keyvfx
				flashkey.rate = 0.05
				flashkey.image_alpha = 1
				data.keyvfx.image_index = 0
			end
		end
	else
		if data.windupkeybullets > 0 then
			if math.random() <= 0.5 then
				data.windupkeybullets = data.windupkeybullets - 1
				gm.sound_play_networked(gm.constants.wSniperShoot3, 0.3, 0.8 + math.random() * 0.4, actor.x, actor.y)
				gm.sound_play_networked(gm.constants.wCasing, 0.2, 1.2 + math.random() * 0.4, actor.x, actor.y)
				if actor:skill_util_facing_direction() < 90 then
					bolts:set_direction(90, 180, 0, 0)
				else
					bolts:set_direction(0, 90, 0, 0)
				end
				bolts:create(actor.x, actor.y, 1, Particle.SYSTEM.below)
				local attack = actor:fire_bullet(actor.x, actor.y, 1000, actor:skill_util_facing_direction() + math.random(-2, 2), 0.1, nil, gm.constants.sSparks3, Attack_Info.TRACER.sniper1)
				actor:screen_shake(1)
			end
		else
			data.windupkeyshooting = false
		end
	end
end)

key:onAttackCreateProc(function(actor, stack, hit_info)
	if hit_info:get_damage_nocrit(damage) > actor.damage * 2 then
		hit_info.keytrigger = true
	end
end)

key:onHitProc(function(actor, victim, stack, hit_info)
	if hit_info.keytrigger then
		actor:get_data().windupkeyshooting = true
	end
end)