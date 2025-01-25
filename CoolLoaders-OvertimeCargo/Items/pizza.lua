local sprite_pizza = Resources.sprite_load(NAMESPACE, "Pizza", path.combine(PATH, "Sprites/pizza.png"), 1, 18, 18)

local pizza = Item.new(NAMESPACE, "pizza")
pizza:set_sprite(sprite_pizza)
pizza:set_tier(Item.TIER.rare)
pizza:set_loot_tags(Item.LOOT_TAG.category_damage, Item.LOOT_TAG.category_utility, Item.LOOT_TAG.category_healing)

local maxhp_old
local hp_old
gm.pre_script_hook(gm.constants.recalculate_stats, function(self, other, result, args)
	maxhp_old = self.maxhp
	hp_old = self.hp
end)

pizza:clear_callbacks()
pizza:onStatRecalc(function(actor, stack)
	-- ive nerfed some stats here, og ones will be highlighted in comments
	actor.hp_regen = actor.hp_regen + 0.05 * stack
	actor.armor = actor.armor + 14 * stack -- 30
	actor.attack_speed = actor.attack_speed + 0.25 * stack -- 0.75
	actor.critical_chance = actor.critical_chance + 15 * stack -- 25
	actor.pHmax = actor.pHmax + 0.56 * stack -- 2.2
	actor.pVmax = actor.pVmax + 1 * stack
	actor.equipment_cdr = 0.12 -- one second flat
end)

pizza:onPostStatRecalc(function(actor, stack)
	actor.damage = math.ceil(actor.damage * (1 + (0.15 * stack))) -- 8
	actor.maxhp = math.ceil(actor.maxhp * (1 + (0.15 * stack))) -- 100
	local hp_restore = hp_old - actor.hp
	actor.hp = math.min(actor.maxhp, actor.hp + math.max(0, actor.maxhp - maxhp_old + hp_restore))
end)