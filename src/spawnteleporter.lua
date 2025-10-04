local config = {
    targetPos = Vector3.new(243, 72, 435),
    pillarRadius = 50,
    pillarHeight = 150,
    pillarSpawnHeightPadding = 5,
    blockToCreatePillars = "bedrock",
    pickAxeToGiveOnSpawn = "wood_pickaxe"
}
local personalPillars = {}
local function createPillarAtPos(pos, height, blockToCreatePillars)
    task.spawn(function()
        local block = blockToCreatePillars or config.blockToCreatePillars
        local pillarHeight = height or 150
        
        for i = 0, pillarHeight - 1 do
            local pillarPos = Vector3.new(pos.X, pos.Y + i, pos.Z)
            BlockService.placeBlock(block, pillarPos)
            task.wait(0.004)
        end
        
        local chestPos = Vector3.new(pos.X, pos.Y + pillarHeight, pos.Z)
        BlockService.placeBlock("chest", chestPos)
    end)
end
Events.EntitySpawn(function(event)
    local player = event.entity:getPlayer()
    if not player then
        return
    end
    InventoryService.clearInventory(player)
    InventoryService.giveItem(player, config.pickAxeToGiveOnSpawn, 1)
    if not personalPillars[player] then
        local pillarPos = config.targetPos + Vector3.new(math.random(-config.pillarRadius, config.pillarRadius), 0, math.random(-config.pillarRadius, config.pillarRadius))
        createPillarAtPos(pillarPos, config.pillarHeight, config.blockToCreatePillars)
        personalPillars[player] = pillarPos
    end
    local IWantToSpawnAt = personalPillars[player] + Vector3.new(0, config.pillarHeight + config.pillarSpawnHeightPadding, 0)
    local isSucceededInBlockChecking = false
    repeat
        task.spawn(function()
            if BlockService.getBlockAt(IWantToSpawnAt) or BlockService.getBlockAt(IWantToSpawnAt + Vector3.new(0, 1, 0)) then
                IWantToSpawnAt += Vector3.new(0, 1, 0)
                return
            end
            isSucceededInBlockChecking = true
        end)
    until isSucceededInBlockChecking == true
    event.entity:setPosition(IWantToSpawnAt)
end)