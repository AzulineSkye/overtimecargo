local sprite_boungus = Resources.sprite_load(NAMESPACE, "boundingFungus", path.combine(PATH, "Sprites/boundingFungus.png"), 1, 16, 16)
local sprite_boing_short = Resources.sprite_load(NAMESPACE, "boundingFungusBoingShort", path.combine(PATH, "Sprites/boingShort.png"), 5, 13, 37)
local sprite_boing_long = Resources.sprite_load(NAMESPACE, "boundingFungusBoingLong", path.combine(PATH, "Sprites/boingLong.png"), 14, 13, 37)
local sound_boing = Resources.sfx_load(NAMESPACE, "boundingFungusBoingSFX", path.combine(PATH, "Sprites/boing.ogg"))

local boungus = Item.new(NAMESPACE, "boundingFungus")
boungus:set_sprite(sprite_boungus)
boungus:set_tier(Item.TIER.common)
boungus:set_loot_tags(Item.LOOT_TAG.category_utility)
boungus:clear_callbacks()

local boing = Object.new(NAMESPACE, "boundingFungusBoing")
boing:set_sprite(sprite_boing_short)
boing:clear_callbacks()

boing:onCreate(function(self)
	self.image_speed = 0.25
end)

local boinged = false

boing:onStep(function(self)
	if self.parent:get_data().shroomjumpheight == -5 then
		self.sprite_index = sprite_boing_short
	elseif self.parent:get_data().shroomjumpheight == -10 then
		self.sprite_index = sprite_boing_long
	end
	
	if self.parent and self:is_colliding(self.parent) and self.parent:get_data().shroomjumped == nil then
		self.parent.pVspeed = self.parent:get_data().shroomjumpheight
		gm.sound_play_networked(sound_boing, 1, 0.8 + math.random() * 0.2, self.x, self.y)
	end
	
	if self.parent.pVspeed <= self.parent:get_data().shroomjumpheight then
		self.parent:get_data().shroomjumped = true
	end
	
	if self.parent:get_data().shroomjumpheight == -5 and self.image_index >= 4 then
		self:destroy()
	end
	
	if self.parent:get_data().shroomjumpheight == -10 and self.image_index >= 13 then
		self:destroy()
	end
end)

boungus:onAcquire(function(actor, stack)
	boinged = false
end)

boungus:onDamagedProc(function(actor, attacker, stack, hit_info)
	if boinged then
		if hit_info.damage > actor.maxhp * (1 - 1 / (1 + stack) ^ 0.2) then
			actor.hp = actor.hp + hit_info.damage * ((0.25 * stack) / (0.25 * stack + 1))
			actor:get_data().shroomjumped = nil
			actor:get_data().shroomjumpheight = -5
			local shroom = boing:create(actor.x, actor.y + 12)
			shroom.parent = actor
		else
			actor.hp = actor.hp + hit_info.damage
			actor:get_data().shroomjumped = nil
			actor:get_data().shroomjumpheight = -10
			local shroom = boing:create(actor.x, actor.y + 12)
			shroom.parent = actor
		end
	end
end)

gm.pre_script_hook(gm.constants.actor_phy_on_landed, function(self, other, result, args)
    local real_self = Instance.wrap(self)
    if not gm.bool(self.invincible) and real_self:item_stack_count(boungus) > 0 then
		boinged = true
    end
end)

gm.post_script_hook(gm.constants.actor_phy_on_landed, function(self, other, result, args)
	local real_self = Instance.wrap(self)
    if boinged then
		boinged = false
    end
end)