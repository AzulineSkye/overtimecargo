local sprite_boungus = Resources.sprite_load(NAMESPACE, "boundingFungus", path.combine(PATH, "Sprites/boundingFungus.png"), 1, 16, 16)
local sprite_boing_long = Resources.sprite_load(NAMESPACE, "boundingFungusBoingLong", path.combine(PATH, "Sprites/boingLong.png"), 14, 13, 37)
local sound_boing = Resources.sfx_load(NAMESPACE, "boundingFungusBoingSFX", path.combine(PATH, "Sprites/boing.ogg"))

local boungus = Item.new(NAMESPACE, "boundingFungus")
boungus:set_sprite(sprite_boungus)
boungus:set_tier(Item.TIER.common)
boungus:set_loot_tags(Item.LOOT_TAG.category_utility)
boungus:clear_callbacks()

local boing = Object.new(NAMESPACE, "boundingFungusBoing")
boing:set_sprite(sprite_boing_long)
boing:clear_callbacks()

boing:onCreate(function(self)
	self.image_speed = 0.25
end)

local boinged = false

boing:onStep(function(self)
	if self.parent and self:is_colliding(self.parent) and self.parent:get_data().shroomjumped == nil then
		self.parent.pVspeed = -10
		gm.sound_play_networked(sound_boing, 1, 0.8 + math.random() * 0.2, self.x, self.y)
	end
	
	if self.parent.pVspeed <= -10 then
		self.parent:get_data().shroomjumped = true
	end
	
	if self.image_index >= 13 then
		self:destroy()
	end
end)

boungus:onAcquire(function(actor, stack)
	boinged = false
	if actor:get_data().boungustimer == nil then
		actor:get_data().boungustimer = 15 * 60
	end
end)

boungus:onPostStep(function(actor, stack)
	if actor:get_data().boungustimer <= 60 * (15 * 0.9 ^ (stack - 1)) then
		actor:get_data().boungustimer = actor:get_data().boungustimer + 1
	elseif actor:get_data().boungusrechargeeffects == false then
		gm.sound_play_networked(gm.constants.wEfMushroom, 1, 1.2 + math.random() * 0.4, actor.x, actor.y)
		local flash = GM.instance_create(actor.x, actor.y, gm.constants.oEfFlash)
		flash.parent = actor
		flash.rate = 0.05
		flash.image_blend = 8894686
		flash.image_alpha = 1
		actor:get_data().boungusrechargeeffects = true
	end
end)

gm.pre_script_hook(gm.constants.actor_phy_on_landed, function(self, other, result, args)
    local real_self = Instance.wrap(self)
    if not gm.bool(self.invincible) and real_self:item_stack_count(boungus) > 0 and real_self:get_data().boungustimer >= 60 * (15 * 0.8 ^ (real_self:item_stack_count(boungus) - 1)) and self.pVspeed > 25 then
		self.invincible = 1
		boinged = true
		real_self:get_data().boungustimer = 0
		real_self:get_data().shroomjumped = nil
		real_self:get_data().boungusrechargeeffects = false
		local shroom = boing:create(real_self.x, real_self.y + 12)
		shroom.parent = real_self
    end
end)

gm.post_script_hook(gm.constants.actor_phy_on_landed, function(self, other, result, args)
	local real_self = Instance.wrap(self)
    if boinged then
		self.invincible = 0
		boinged = false
    end
end)