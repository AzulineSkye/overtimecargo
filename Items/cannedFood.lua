local sprite_food = Resources.sprite_load(NAMESPACE, "cannedFood", path.combine(PATH, "Sprites/item/cannedFood.png"), 1, 18, 17)
local sprite_rotten = Resources.sprite_load(NAMESPACE, "rottenFood", path.combine(PATH, "Sprites/fx/rottenFood.png"), 1, 8, 5)
local sprite_proj = Resources.sprite_load(NAMESPACE, "foodProjectile", path.combine(PATH, "Sprites/fx/foodProjectile.png"), 1, 8, 6)

local fud = Item.new(NAMESPACE, "cannedFood")
fud:set_sprite(sprite_food)
fud:set_tier(Item.TIER.common)
fud:set_loot_tags(Item.LOOT_TAG.category_damage)
fud:clear_callbacks()

local fudBuff = Buff.new(NAMESPACE, "cannedFoodPoison")
fudBuff.is_debuff = true
fudBuff.show_icon = false
fudBuff:clear_callbacks()

local rottenFood = Object.new(NAMESPACE, "cannedFoodDrops")
rottenFood:set_sprite(sprite_proj)
rottenFood:clear_callbacks()

rottenFood:onCreate(function(self)
	local data = self:get_data()
	data.food = true
	if data.grounded == nil then
		data.grounded = 0
	end

end)

rottenFood:onStep(function(self)
local data = self:get_data()
	if data.food then
		self.image_angle = self.image_angle + (-15 + self.image_xscale)
		if self:is_colliding(gm.constants.pBlock, self.x, self.y) then
			self.image_speed = 0.25
			self.image_angle = 0
			self.sprite_index = sprite_rotten
			self.image_index = 0
			self.direction = 0
			self.gravity = 0
			self.speed = 0
			data.lifespan = 60 * 5
			data.food = false
		end
	else
		if data.grounded == 1 then
			local buffed = 0
			for _, victim in ipairs(self:get_collisions(gm.constants.pActor)) do
				if victim.team ~= data.parent.team and victim:get_buff_time(victim, fudBuff) < 1 then
					if not victim:get_data().foodDmg then
						victim:get_data().foodDmg = data.parent.damage
					end
					victim:buff_apply(fudBuff, 60 * 5, 1)
					victim:get_data().applier = data.parent
					self:destroy()
				end
			end
		else
			self:move_contact_solid(270, 64)
			data.grounded = 1
		end
	end
end)

fud:onInteractableActivate(function(actor, stack, interactable)
	--old effect
	-- local poison = List.new()
	-- interactable:collision_ellipse_list(interactable.x - 135, interactable.y - 135, interactable.x + 135, interactable.y + 135, gm.constants.pActor, false, true, poison, false)
	-- for _, victim in ipairs(poison) do
		-- if victim.team ~= actor.team and victim:get_buff_time(victim, fudBuff) <= 1 then
			-- if not victim:get_data().foodDmg then
				-- victim:get_data().foodDmg = actor.damage
			-- end
			-- victim:get_data().applier = actor
			-- victim:buff_apply(fudBuff, 60 * 5)
		-- end
	-- end
	-- gm.draw_set_colour(Color.from_rgb(0, 163, 40))
	-- gm.draw_set_alpha(1)
	-- gm.draw_circle(interactable.x, interactable.y, 1, true)
	-- gm.draw_set_alpha(1)
	-- poison:destroy()
	
	if (#Instance.find_all(rottenFood)) < 21 then
		for i = 0, 2 * stack, 1 do
			local foodProj = rottenFood:create(interactable.x, interactable.y - 15)
			foodProj.direction = math.random(45, 135)
			foodProj.speed = math.random(4, 6)
			foodProj.gravity = 0.2
			foodProj:get_data().parent = actor
		end
	end
end)

fudBuff:onApply(function(actor, stack)
	actor:get_data().foodTick = 0
	gm.sound_play_networked(gm.constants.wUse2, 1, 0.7, actor.x, actor.y)
end)

fudBuff:onPostStep(function(actor, stack)
	if gm._mod_net_isClient() then return end
	
	local data = actor:get_data()
	
	data.foodTick = data.foodTick - 1
	
	if data.foodTick <= 0 then
		local dmg = data.foodDmg * (0.25 + (0.15 * data.applier:item_stack_count(fud)))
		actor:damage_inflict(actor, dmg, 0, data.applier, actor.x, actor.y, dmg, data.applier.team, Color.from_rgb(0, 163, 40))
		data.foodTick = 30
	end

end)