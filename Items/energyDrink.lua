local sprite_nrg = Resources.sprite_load(NAMESPACE, "energyDrinkSprite", path.combine(PATH, "Sprites/item/energyDrink.png"), 1, 16, 14)
local sprite_buff = Resources.sprite_load(NAMESPACE, "drinkBuffIcon", path.combine(PATH, "Sprites/buffs/moonrockBuff1.png"), 1, 8, 8)

local sound_drink = Resources.sfx_load(NAMESPACE, "drinkSound", path.combine(PATH, "Sounds/energyDrink.ogg"))

local nrg = Item.new(NAMESPACE, "energyDrink")
nrg:set_sprite(sprite_nrg)
nrg:set_tier(Item.TIER.common)
nrg:set_loot_tags(Item.LOOT_TAG.category_damage, Item.LOOT_TAG.category_utility)
nrg:clear_callbacks()

local buff = Buff.new(NAMESPACE, "drinkBuff")
buff.show_icon = true
buff.icon_sprite = sprite_buff
buff:clear_callbacks()

buff:onApply(function(actor, stack)

gm.sound_play_networked(sound_drink, 1, 0.9 + math.random() * 0.2, actor.x, actor.y)

end)

buff:onStatRecalc(function(actor, stack)
	actor.pHmax = actor.pHmax + (0.22 + (0.48 * stack))
	actor.attack_speed = actor.attack_speed + (0.08 + (0.17 * stack))
end)

nrg:onStageStart(function(actor, stack)

actor:buff_apply(buff, (60 * (25 + (5 * stack))))

end)