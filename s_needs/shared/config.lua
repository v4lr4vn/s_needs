--[[ s_needs — hunger & thirst config. Values are 0-100. ]]

Needs = Needs or {}

Needs.config = {
    tickSeconds   = 60,    -- how often needs decay
    hungerPerTick = 1.0,   -- hunger lost each tick
    thirstPerTick = 1.4,   -- thirst lost each tick (you get thirsty faster)
    start         = 100,   -- value for a fresh character
    damageAtZero  = true,  -- take a little health damage while starving/parched
    damagePerTick = 3,     -- HP lost per tick at zero (never kills outright; floors at near-dead)
}

return Needs.config
