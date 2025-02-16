local sprite_manip = Resources.sprite_load(NAMESPACE, "unstableManipulator", path.combine(PATH, "Sprites/unstableManipulator.png"), 1, 16, 16)

local manip = Item.new(NAMESPACE, "unstableManipulator")
manip:set_sprite(sprite_manip)
manip:set_tier(Item.TIER.uncommon)
manip:set_loot_tags(Item.LOOT_TAG.category_utility)

Callback.add(Callback.TYPE.onDirectorPopulateSpawnArrays, "unstableManipulatorCreditIncrease", function()
	local count = 0
	for _, player in ipairs(Instance.find_all(gm.constants.oP)) do
		count = count + player:item_stack_count(manip)
	end
	--print("og credits", GM._mod_game_getDirector().pos_points)
	--print("final mult", math.max(1 + ((math.sqrt(count) - 0.5) / 5), 1))
	--print("increase mult", (math.sqrt(count) - 0.5) / 5)
	--print("final credits prediction", GM._mod_game_getDirector().pos_points * math.max(1 + ((math.sqrt(count) - 0.5) / 5), 1))
	GM._mod_game_getDirector().pos_points = GM._mod_game_getDirector().pos_points * math.max(1 + ((math.sqrt(count) - 0.5) / 5), 1)
	--print("final credits", GM._mod_game_getDirector().pos_points)
end)