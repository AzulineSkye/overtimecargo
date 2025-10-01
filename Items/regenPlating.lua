local sprite_plate = Resources.sprite_load(NAMESPACE, "regenPlating", path.combine(PATH, "Sprites/item/regenPlating.png"), 1, 16, 16)
local sprite_plate_used = Resources.sprite_load(NAMESPACE, "regenPlatingUsed", path.combine(PATH, "Sprites/item/regenPlatingUsed.png"), 1, 16, 16)

local plate = Item.new(NAMESPACE, "regenPlating")
plate:set_sprite(sprite_plate)
plate:set_tier(Item.TIER.uncommon)
plate:set_loot_tags(Item.LOOT_TAG.category_utility, Item.LOOT_TAG.category_healing)
plate:clear_callbacks()

local plate_used = Item.new(NAMESPACE, "regenPlatingUsed")
plate_used:set_sprite(sprite_plate_used)
plate_used:toggle_loot(false)
plate_used:set_loot_tags(Item.LOOT_TAG.item_blacklist_vendor, Item.LOOT_TAG.item_blacklist_infuser)
plate_used:clear_callbacks()

--Create var in actor used to track drone purchases
plate:onAcquire(function(actor, stack)
	local data = actor:get_data()

	--Tracks number of drones bought
	if not data.platingDroneBuy then
		data.platingDroneBuy = 0 

		--prevents free extra uses if you get
		--an extra stack while having a semi-used stack
	elseif data.platingDroneBuy == 1 then
		data.platingDroneBuy = 1
		
	elseif data.platingDroneBuy == 2 then
		data.platingDroneBuy = 2

		--default, resets at stage start
	else 
		data.platingDroneBuy = 0
	end

	--Limit for drones that can be bought
	if not data.platingDroneLimit then
		data.platingDroneLimit = 3
	end

end)

--shoutouts to On_x for helping me understand hooks
--called when a drone is spawned
--post script bc that's after it determines its master
gm.post_script_hook(gm.constants.init_drone, function(self, other)
	--"Master" is the drone's variable for its owner/parent/the player actor
	--needs to be wrapped to be used in hook
	local master = Instance.wrap(self.master)
	local data = master:get_data()
	if master:item_stack_count(plate) > 0 then
	
		gm.sound_play_networked(gm.constants.wCrit2, 1, 0.5, master.x, master.y)
		local flash = GM.instance_create(self.x, self.y, gm.constants.oEfFlash)
		flash.parent = self
		flash.rate = 0.05
		flash.image_alpha = 0.8
		flash.image_blend = Color.YELLOW
	
		if data.platingDroneBuy and data.platingDroneBuy < data.platingDroneLimit then
			--Buff drone stats
			self.armor = self.armor + 100
			self.hp_regen = self.hp_regen + 0.06

			--Increment drones bought var
			data.platingDroneBuy = data.platingDroneBuy + 1
		end
		
		--If our drones bought equals the limit, consume a stack of the item
		--(+temp item handling)
		if data.platingDroneBuy >= data.platingDroneLimit then
			gm.sound_play_networked(gm.constants.wDroneDeath, 1, 0.7, master.x, master.y)
			local normal = master:item_stack_count(plate, Item.STACK_KIND.normal)
			local temp = master:item_stack_count(plate, Item.STACK_KIND.temporary_blue)
			local temp2 = master:item_stack_count(plate, Item.STACK_KIND.temporary_red)
		
			if normal > 0 and not (temp > 0 or temp2 > 0) then
				master:item_remove(plate, 1, Item.STACK_KIND.normal)
				master:item_give(plate_used, 1, Item.STACK_KIND.normal)
			end
		
			if temp > 0 then
				master:item_remove(plate, 1, Item.STACK_KIND.temporary_blue)
				master:item_give(plate_used, 1, Item.STACK_KIND.temporary_blue)
			end
		
			if temp2 > 0 then
				master:item_remove(plate, 1, Item.STACK_KIND.temporary_red)
				master:item_give(plate_used, 1, Item.STACK_KIND.temporary_red)
			end
			
			--reset drones bought variable
			data.platingDroneBuy = 0
			
		end
	end
end)

--replenish Regen Plate frome used plate
plate_used:onStageStart(function(actor, stack)

	local normal = actor:item_stack_count(plate_used, Item.STACK_KIND.normal)
    local temp = actor:item_stack_count(plate_used, Item.STACK_KIND.temporary_blue)
	local temp2 = actor:item_stack_count(plate, Item.STACK_KIND.temporary_red)
	
	if normal > 0 then
		actor:item_give(plate, normal, Item.STACK_KIND.normal)
		actor:item_remove(plate_used, normal, Item.STACK_KIND.normal)
	end
	
	if temp > 0 then
		actor:item_give(plate, temp, Item.STACK_KIND.temporary_blue)
		actor:item_remove(plate_used, temp, Item.STACK_KIND.temporary_blue)
	end
	
	if temp > 0 then
		actor:item_give(plate, temp, Item.STACK_KIND.temporary_red)
		actor:item_remove(plate_used, temp, Item.STACK_KIND.temporary_red)
	end

end)

plate:onStageStart(function(actor, stack)
	local data = actor:get_data()
	data.platingDroneBuy = 0 	
end)