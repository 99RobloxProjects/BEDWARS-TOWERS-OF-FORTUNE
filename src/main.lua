local CONFIG = {
    itemReceiveInterval = 10,
    luckyBlockReceiveInterval = 40,
    amazingLuckyBlockPercentChanceThreshold = 10,
    BAR_COLOURS = {
        luckyBlock = Color3.fromRGB(255, 215, 0),
        randomItem = Color3.fromRGB(0, 255, 255)
    },
    text = {
        itemProgressBarText = "NEW ITEM (%ds elapsed of %ds)",
        luckyBlockProgressBarText = "LUCKY BLOCK (%ds elapsed of %ds)",
        randomItemReceiveText = "<b><font color='rgb(0,255,255)'>%s got a %s!</font></b>",
        perfectLuckyBlockText = "%s JUST GOT 1x %s (%d%% chance) %s"
    },
    goated_items = {
        -- Basic Building Blocks
        wool_white = 4, -- lucky number
        wool_red = 4,
        wool_blue = 4,
        wool_green = 4,
        wood_plank_oak = 4,
        stone = 4,
        glass = 4,
        
        -- Weapons - Swords
        wood_sword = 4,
        stone_sword = 4,
        iron_sword = 4,
        diamond_sword = 4,
        emerald_sword = 4, -- OP
        void_sword = 4, -- OP
        
        -- Weapons - Bows
        wood_bow = 4,
        tactical_crossbow = 4,
        head_hunter = 4,
        arrow = 4,
        
        -- Tools
        wood_pickaxe = 4,
        stone_pickaxe = 4,
        iron_pickaxe = 4,
        diamond_pickaxe = 4,
        shears = 4,
        
        -- Armor
        leather_helmet = 4,
        leather_chestplate = 4,
        leather_boots = 4,
        iron_helmet = 4,
        iron_chestplate = 4,
        iron_boots = 4,
        diamond_helmet = 4,
        diamond_chestplate = 4,
        diamond_boots = 4,
        
        -- Resources
        iron = 4,
        gold = 4,
        diamond = 4,
        emerald = 4,
        
        -- Utility Items
        tnt = 4,
        fireball = 4,
        telepearl = 4,
        throwable_bridge = 4,
        invisibility_potion = 4,
        speed_potion = 4,
        
        -- OP Weapons & Tools
        rocket_launcher = 4, -- OP
        void_axe = 4, -- OP
        portal_gun = 4, -- OP
        blackhole_bomb = 4, -- OP
        guided_missile = 4, -- OP
        void_turret = 4, -- OP
        juggernaut_rage_blade = 4, -- OP
        
        -- Basic Items
        apple = 4,
        chest = 4,
        bed = 4,
        mini_shield = 4,
        grappling_hook = 4
    },
    LUCKY_BLOCKS = {
        {
            name = "Common",
            weight = 50,
            items = {{id = "lucky_block", amount = 1}}
        },
        {
            name = "Uncommon",
            weight = 25,
            items = {
                {id = "flying_lucky_block", amount = 1},
                {id = "purple_lucky_block", amount = 1}
            }
        },
        {
            name = "Rare",
            weight = 15,
            items = {
                {id = "cosmic_lucky_block", amount = 1},
                {id = "lucky_block_trap", amount = 1}
            }
        },
        {
            name = "Ultra",
            weight = 7,
            items = {
                {id = "magical_hero_lucky_block", amount = 1},
                {id = "forge_lucky_block", amount = 1},
                {id = "food_lucky_block", amount = 1},
                {id = "halloween_lucky_block", amount = 1},
                {id = "growing_halloween_lucky_block", amount = 1},
                {id = "new_years_lucky_block", amount = 1},
                {id = "huge_lucky_block", amount = 1},
                {id = "glitched_lucky_block", amount = 1},
                {id = "new_years_lucky_block_2024", amount = 1}
            }
        },
        {
            name = "Legendary",
            weight = 3,
            items = {{id = "rainbow_lucky_block", amount = 1}}
        }
    }
}

local randomItems = require("randomItems")
local progressBars = require("progressBars")

local TOTAL_RARITY_WEIGHT = 0
for _, rarity in ipairs(CONFIG.LUCKY_BLOCKS) do
    TOTAL_RARITY_WEIGHT = TOTAL_RARITY_WEIGHT + rarity.weight
end

local function selectWeightedRandomItem()
    local roll = math.random() * TOTAL_RARITY_WEIGHT
    local currentWeight = 0
    
    for _, rarity in ipairs(CONFIG.LUCKY_BLOCKS) do
        currentWeight = currentWeight + rarity.weight
        if roll <= currentWeight then
            local items = rarity.items
            local selectedItem = items[math.random(1, #items)]
            return {
                id = selectedItem.id,
                amount = selectedItem.amount,
                rarity = rarity.name,
                chance = rarity.weight
            }
        end
    end
    
    local fallbackRarity = CONFIG.LUCKY_BLOCKS[1]
    local fallbackItem = fallbackRarity.items[1]
    return {
        id = fallbackItem.id,
        amount = fallbackItem.amount,
        rarity = fallbackRarity.name,
        chance = fallbackRarity.weight
    }
end

local function createItemProgressBar()
    local currentTime = os.time()
    local endTime = currentTime + CONFIG.itemReceiveInterval
    
    return progressBars.newTimedProgressBarTracker(
        CONFIG.text.itemProgressBarText:format(0, CONFIG.itemReceiveInterval),
        CONFIG.BAR_COLOURS.randomItem,
        1,
        currentTime,
        endTime,
        function(progressBar)
            local elapsed = progressBar.timeProgressed
            local total = progressBar.totalTime
            progressBar.EasyGGObject:setText(CONFIG.text.itemProgressBarText:format(elapsed, total))
        end
    )
end

local function createLuckyBlockProgressBar()
    local currentTime = os.time()
    local endTime = currentTime + CONFIG.luckyBlockReceiveInterval
    
    return progressBars.newTimedProgressBarTracker(
        CONFIG.text.luckyBlockProgressBarText:format(0, CONFIG.luckyBlockReceiveInterval),
        CONFIG.BAR_COLOURS.luckyBlock,
        1,
        currentTime,
        endTime,
        function(progressBar)
            local elapsed = progressBar.timeProgressed
            local total = progressBar.totalTime
            progressBar.EasyGGObject:setText(CONFIG.text.luckyBlockProgressBarText:format(elapsed, total))
        end
    )
end

local function distributeItemsToPlayers()
    for _, player in ipairs(PlayerService.getPlayers()) do
        local itemName = randomItems.givePlayerRandomItemUsingInventoryService(player, 1, false)
        if CONFIG.goated_items[itemName] then
            ChatService.sendMessage(CONFIG.text.randomItemReceiveText:format(player.name, itemName))
        end
    end
end

local function distributeLuckyBlocksToPlayers()
    for _, player in ipairs(PlayerService.getPlayers()) do
        local reward = selectWeightedRandomItem()
        
        if reward.chance <= CONFIG.amazingLuckyBlockPercentChanceThreshold then
            ChatService.sendMessage(CONFIG.text.perfectLuckyBlockText:format(
                player.name,
                reward.rarity,
                reward.chance,
                reward.id
            ))
        end
        
        InventoryService.giveItem(player, reward.id, reward.amount)
    end
end

local function startItemDistribution()
    while true do
        local progressBar = createItemProgressBar()
        task.wait(CONFIG.itemReceiveInterval)
        progressBar:destroy()
        distributeItemsToPlayers()
    end
end

local function startLuckyBlockDistribution()
    while true do
        local progressBar = createLuckyBlockProgressBar()
        task.wait(CONFIG.luckyBlockReceiveInterval)
        progressBar:destroy()
        distributeLuckyBlocksToPlayers()
    end
end

local function startRound()
    task.spawn(startItemDistribution)
    task.spawn(startLuckyBlockDistribution)
end

Events.MatchStart(startRound)

if MatchService.getMatchState() == 1 then
    startRound()
end
