local sprite_holy = Resources.sprite_load(NAMESPACE, "holyPauldronSprite", path.combine(PATH, "Sprites/item/holyPauldron.png"), 1, 17, 17)
local sprite_buff = Resources.sprite_load(NAMESPACE, "holyBuffIcon", path.combine(PATH, "Sprites/buffs/moonrockBuff1.png"), 1, 8, 8)

local holy = Item.new(NAMESPACE, "holyPauldron")
holy:set_sprite(sprite_holy)
holy:set_tier(Item.TIER.rare)
holy:set_loot_tags(Item.LOOT_TAG.category_utility, Item.LOOT_TAG.category_healing)
holy:clear_callbacks()

local holyBuff = Buff.new(NAMESPACE, "holyPauldronNoDecay")
holyBuff.show_icon = true
holyBuff.icon_sprite = sprite_buff
holyBuff:clear_callbacks()

-- holy:onAcquire(function(actor, stack)

-- end)

holy:onKillProc(function(actor, victim, stack)
	
	if victim:actor_is_elite(victim) then
		actor:add_barrier(actor.maxbarrier * (0.10 + (0.15 * stack)))
		actor:buff_apply(holyBuff, 60 * (2 + (3 * stack)))
	end
	
end)

holyBuff:onPostStep(function(actor)

--stops barrier decay by adding the decay formula directly to barrier stat
if gm.bool(actor.barrier) then
	actor.barrier = actor.barrier + ((actor.maxbarrier / 30 / 60) * gm.lerp(0.5, 3, actor.barrier / actor.maxbarrier))
end

end)
