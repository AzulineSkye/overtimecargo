local sprite_key = Resources.sprite_load(NAMESPACE, "windupKey", path.combine(PATH, "Sprites/windupKey.png"), 1, 16, 16)
local sprite_bolts = Resources.sprite_load(NAMESPACE, "windupKeyParticles", path.combine(PATH, "Sprites/windupKeyParticles.png"), 5, 3, 3)

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
				local attack = actor:fire_bullet(actor.x, actor.y, 1000, actor:skill_util_facing_direction() + math.random(-2, 2), 0.15, nil, gm.constants.sSparks3, Attack_Info.TRACER.sniper1)
				actor:screen_shake(1)
			end
		else
			data.windupkeyshooting = false
		end
	end
end)

key:onHitProc(function(actor, victim, stack, hit_info)
	if hit_info.damage >= actor.damage * 2.0 then
		actor:get_data().windupkeyshooting = true
	end
end)