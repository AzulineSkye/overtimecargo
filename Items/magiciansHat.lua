local sprite_hat = Resources.sprite_load(NAMESPACE, "magiciansHat", path.combine(PATH, "Sprites/magiciansHat.png"), 2, 16, 16)
local sprite_hat_ready = Resources.sprite_load(NAMESPACE, "magiciansHatReady", path.combine(PATH, "Sprites/magiciansHatReady.png"), 2, 16, 16)

local hat = Equipment.new(NAMESPACE, "magiciansHat")
hat:set_sprite(sprite_hat)
hat:set_loot_tags(Item.LOOT_TAG.category_utility, Item.LOOT_TAG.equipment_blacklist_chaos, Item.LOOT_TAG.equipment_blacklist_activator, Item.LOOT_TAG.equipment_blacklist_enigma)
hat:set_cooldown(90)
hat:clear_callbacks()

local parselect = Particle.new(NAMESPACE, "particleMagiciansHatSelect")
parselect:set_color_rgb(64, 191, 46, 46, 133, 133)
parselect:set_life(30, 90)
parselect:set_shape(Particle.SHAPE.line)
parselect:set_orientation(90, 90, 0, 0, false)
parselect:set_speed(0.75, 1.5, -0.01, 0)
parselect:set_scale(0.1, 0.1)
parselect:set_alpha3(1, 1, 0)
parselect:set_size(1, 2, -0.02, 0.005)
parselect:set_direction(90, 90, 0, 0)

local parstar = Particle.new(NAMESPACE, "particleMagiciansHatStar")
parstar:set_color_rgb(255, 255, 255, 255, 255, 255)
parstar:set_life(50, 70)
parstar:set_shape(Particle.SHAPE.star)
parstar:set_orientation(0, 360, -4, 0.5, false)
parstar:set_speed(3, 4, -0.1, 0)
parstar:set_scale(0.2, 0.2)
parstar:set_size(0.7, 1.4, 0.02, 0)
parstar:set_direction(30, 150, 0, 0)
parstar:set_gravity(0.05, 270)
parstar:set_alpha3(1, 1, 0)

hat:onPickup(function(actor)
	actor:get_data().magiciansHatItems = List.new()
	actor:get_data().magiciansHatObjects = List.new()
	actor:get_data().magiciansHatTiers = List.new()
end)

hat:onPostStep(function(actor)
	local detecteditems = List.new()
	local validitems = List.new()
	actor:collision_rectangle_list(actor.x, actor.y - 25, actor.x + 200 * actor.image_xscale, actor.y + 25, gm.constants.pPickupItem, false, true, detecteditems, false)
	for _, item in ipairs(detecteditems) do
		if (item.tier == 0 or item.tier == 1 or item.tier == 2 or item.tier == 4) and item.speed == 0 and item.item_stack_kind == 0 and item.item_id ~= -1 then
			if math.random(10) < 6 then
				parselect:create(item.x + math.random(-15, 15), item.y - math.random(-15, 15))
			end
			validitems:add(item)
		end
	end
	if validitems:size() > 0 then
		hat:set_sprite(sprite_hat_ready)
		hat:set_cooldown(0.5)
	else
		hat:set_sprite(sprite_hat)
		hat:set_cooldown(90)
	end
	detecteditems:destroy()
	validitems:destroy()
end)

hat:onUse(function(actor)
	local detecteditems = List.new()
	local validitems = List.new()
	actor:collision_rectangle_list(actor.x, actor.y - 25, actor.x + 200 * actor.image_xscale, actor.y + 25, gm.constants.pPickupItem, false, true, detecteditems, false)
	for _, item in ipairs(detecteditems) do
		if (item.tier == 0 or item.tier == 1 or item.tier == 2 or item.tier == 4) and item.item_stack_kind == 0 and item.item_id ~= -1 then
			validitems:add(item)
		end
	end
	if validitems:size() > 0 then
		for _, item in ipairs(validitems) do
			if item.tier == 0 and item.item_stack_kind == 0 then
				parstar:set_color_rgb(255, 255, 255, 255, 255, 255)
			elseif item.tier == 1 and item.item_stack_kind == 0 then
				parstar:set_color_rgb(115, 115, 175, 175, 88, 88)
			elseif item.tier == 2 and item.item_stack_kind == 0 then
				parstar:set_color_rgb(192, 192, 44, 44, 65, 65)
			elseif item.tier == 4 and item.item_stack_kind == 0 then
				parstar:set_color_rgb(218, 218, 205, 205, 65, 65)
			end
			parstar:set_direction(30, 150, 0, 0)
			parstar:create(item.x, item.y)
			actor:get_data().magiciansHatItems:add(item.item_id)
			actor:get_data().magiciansHatObjects:add(item.object_index)
			actor:get_data().magiciansHatTiers:add(item.tier)
			item:destroy()
		end
		gm.sound_play_networked(gm.constants.wDagger_Fly, 0.8, 0.9 + math.random() * 0.1, actor.x, actor.y)
		gm.sound_play_networked(gm.constants.wRevive, 0.8, 0.9 + math.random() * 0.1, actor.x, actor.y)
	else
		for _, id in ipairs(actor:get_data().magiciansHatItems) do
			actor:item_give(id, 2, Item.STACK_KIND.temporary_red)
		end
		for _, tier in ipairs(actor:get_data().magiciansHatTiers) do
			if tier == 0 then
				parstar:set_color_rgb(255, 255, 255, 255, 255, 255)
			elseif tier == 1 then
				parstar:set_color_rgb(115, 115, 175, 175, 88, 88)
			elseif tier == 2 then
				parstar:set_color_rgb(192, 192, 44, 44, 65, 65)
			elseif tier == 4 then
				parstar:set_color_rgb(218, 218, 205, 205, 65, 65)
			end
			parstar:set_direction(0, 360, 0, 0)
			parstar:create(actor.x, actor.y, 2)
		end
		gm.sound_play_networked(gm.constants.wJackbox, 1, 0.9 + math.random() * 0.1, actor.x, actor.y)
		gm.sound_play_networked(gm.constants.wUI_Trials_Success, 1, 0.9 + math.random() * 0.1, actor.x, actor.y)
		gm.sound_play_networked(gm.constants.wRevive, 1, 0.9 + math.random() * 0.1, actor.x, actor.y)
	end
	detecteditems:destroy()
	validitems:destroy()
end)

hat:onDrop(function(actor)
	for _, objectid in ipairs(actor:get_data().magiciansHatObjects) do
		for i = 1, 2 do
			local item = Object.wrap(objectid):create(actor.x, actor.y - 24)
			item.item_stack_kind = 1
		end
	end
	actor:get_data().magiciansHatItems:destroy()
	actor:get_data().magiciansHatObjects:destroy()
	actor:get_data().magiciansHatTiers:destroy()
	hat:set_sprite(sprite_hat)
	hat:set_cooldown(90)
end)

Callback.add(Callback.TYPE.onGameEnd, "resetMagiciansHatSprite", function()
	hat:set_sprite(sprite_hat)
	hat:set_cooldown(90)
end)