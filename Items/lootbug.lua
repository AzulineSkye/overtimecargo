local sprite_mask = Resources.sprite_load(NAMESPACE, "lootbugMask", path.combine(PATH, "Sprites/lootbugMask.png"), 1, 15, 11)
local sprite_idle = Resources.sprite_load(NAMESPACE, "lootbugIdle", path.combine(PATH, "Sprites/lootbugIdle.png"), 1, 15, 11)
local sprite_walk = Resources.sprite_load(NAMESPACE, "lootbugWalk", path.combine(PATH, "Sprites/lootbugWalk.png"), 8, 15, 11)
local sprite_run = Resources.sprite_load(NAMESPACE, "lootbugRun", path.combine(PATH, "Sprites/lootbugRun.png"), 8, 15, 11)
local sprite_spawn = Resources.sprite_load(NAMESPACE, "lootbugSpawn", path.combine(PATH, "Sprites/lootbugSpawn.png"), 14, 24, 20)
local sprite_burrow = Resources.sprite_load(NAMESPACE, "lootbugBurrow", path.combine(PATH, "Sprites/lootbugBurrow.png"), 15, 24, 20)
local sprite_death = Resources.sprite_load(NAMESPACE, "lootbugDeath", path.combine(PATH, "Sprites/lootbugDeath.png"), 12, 20, 21)

local sound_idle1 = Resources.sfx_load(NAMESPACE, "lootbugIdle1", path.combine(PATH, "Sprites/lootbugIdle1.ogg"))
local sound_idle2 = Resources.sfx_load(NAMESPACE, "lootbugIdle2", path.combine(PATH, "Sprites/lootbugIdle2.ogg"))
local sound_run = Resources.sfx_load(NAMESPACE, "lootbugRun", path.combine(PATH, "Sprites/lootbugRun.ogg"))
local sound_death = Resources.sfx_load(NAMESPACE, "lootbugDeath", path.combine(PATH, "Sprites/lootbugDeath.ogg"))

local lootbug = Object.new(NAMESPACE, "Lootbug", Object.PARENT.enemyClassic)
lootbug.obj_sprite = sprite_idle
lootbug.obj_depth = 11
lootbug:clear_callbacks()

lootbug:onCreate(function(actor)
	actor.sprite_spawn = sprite_spawn
	actor.sprite_idle = sprite_idle
	actor.sprite_walk = sprite_walk
	actor.sprite_jump = sprite_walk
	actor.sprite_jump_peak = sprite_walk
	actor.sprite_fall = sprite_walk
	actor.sprite_death = sprite_death

	actor.can_jump = true

	actor.mask_index = sprite_mask

	actor.sound_spawn = gm.constants.wLizardSpawn
	actor.sound_hit = gm.constants.wImpHit
	actor.sound_death = sound_death

	actor:enemy_stats_init(0, 300, 99999, 0)
	actor.pHmax_base = 2.6

	actor:init_actor_late()
	actor.lifetime = 20 * 60
	actor.burrowing = 0
	actor.madesound = actor.lifetime
end)

lootbug:onStep(function(actor)
	actor:buff_apply(Buff.find("ror", "fear"), 99999)
	if actor.lifetime > 0 then
		actor.lifetime = actor.lifetime - 1
	else
		actor.sprite_index = sprite_burrow
		actor.burrowing = 1
	end
	
	if actor.madesound - actor.lifetime > 120 and math.random() <= 0.05 then
		if math.random() <= 0.5 then
			gm.sound_play_networked(sound_idle1, 1, 1, actor.x, actor.y)
		else
			gm.sound_play_networked(sound_idle2, 1, 1, actor.x, actor.y)
		end
		actor.madesound = actor.lifetime
	end
	
	if actor.burrowing == 1 then
		local body = gm.instance_create(actor.x, actor.y, gm.constants.oBody)
		body.sprite_index = sprite_burrow
		body.image_xscale = actor.image_xscale
		body.image_index = 0
		body.image_speed = 0.15
		body.image_blend = actor.image_blend
		body.sprite_palette = actor.sprite_palette
		body.elite_type = actor.elite_type
		gm.sound_play_networked(gm.constants.wGolemGSpawn, 1, 1, actor.x, actor.y)
		actor:destroy()
	end
end)

lootbug:onDestroy(function(actor)
	if actor.hp <= 0 and actor.burrowing == 0 then
	local itemcount = actor.itemcount
		for i = 0, itemcount, 1 do
			local tier = Item.TIER.common
			if math.random() <= 0.2 then 
				tier = Item.TIER.uncommon
			end
			if math.random() <= 0.05 then 
				tier = Item.TIER.rare
			end
			
			local item = Item.get_random(tier):create(actor.x, actor.y, actor)
			item.item_stack_kind = 1
		end
	end
end)