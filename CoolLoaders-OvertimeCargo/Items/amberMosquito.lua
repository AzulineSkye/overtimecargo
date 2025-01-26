local sprite_amber = Resources.sprite_load(NAMESPACE, "AmberMosquito", path.combine(PATH, "Sprites/amberMosquito.png"), 1, 18, 18)

local amber = Item.new(NAMESPACE, "amberMosquito")
amber:set_sprite(sprite_amber)
amber:set_tier(Item.TIER.rare)
amber:set_loot_tags(Item.LOOT_TAG.category_utility)


amber:clear_callbacks()
Callback.add(Callback.TYPE.onEnemyInit, "amberReduction", function(enemy)
	for _, player in ipairs(Instance.find_all(gm.constants.oP)) do
		local count = player:item_stack_count(amber)
		if count >= 1 then
			print(enemy.maxhp)
			for i = 1, count, 1 do
				if i == 1 then
					enemy.maxhp = enemy.maxhp * 0.75
					enemy.hp = enemy.maxhp
				else
					enemy.maxhp = enemy.maxhp * 0.9
					enemy.hp = enemy.maxhp
				end
			end
			print(enemy.maxhp)
		end
	end
end)