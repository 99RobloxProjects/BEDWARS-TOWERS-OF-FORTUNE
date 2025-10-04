-- randomItems.lua
local module = {}
module.convertDictionaryToKeyArray = function(dictionaryTable)
    local arrayTable = {}
    for key, value in pairs(dictionaryTable) do
        table.insert(arrayTable, key)
    end
    return arrayTable
end
module.pickRandomFromDictionary = function(dictionaryTable)
    local arrayToPickFrom = module.convertDictionaryToKeyArray(dictionaryTable)
    local pickedIndex = arrayToPickFrom[math.random(1, #arrayToPickFrom)]
    return dictionaryTable[pickedIndex]
end
module.getRandomItem = function(itemsTable)
    local itemConfig = itemsTable or ItemType
    return module.pickRandomFromDictionary(itemConfig)
end
module.givePlayerRandomItemUsingInventoryService = function(playerPlayer, amountNumber, playWorldEffectBoolean)
    local randomItem = module.getRandomItem()
    InventoryService.giveItem(playerPlayer, randomItem, amountNumber or 1, playWorldEffectBoolean)
    return randomItem
end
return module