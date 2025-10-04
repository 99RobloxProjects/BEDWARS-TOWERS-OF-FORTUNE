local module = {}

local Config = {
	gridSize = Vector3.new(200, 1, 200),
	gridPosition = Vector3.new(342, 66, 336),
	floorBlock = "magma_block",
	pillarBlock = "bedrock",
	pillarHeight = 90,
	teamCount = 4,
	padding = 5,
	protectBlocks = true,
	protectBlocksCallback = function() end,
    alreadyBuilt = false
}

local protectedBlocks = {}
local isListenerEnabled = false
local currentConfig = nil
local function type(thing) -- easy.gg.. error for tables.. no pcall?
    local typed
    task.spawn(function()
        typed = typeof(thing) 
    end)
    if not typed then
        return "table"
    end
    return typed
end
local function mergeConfig(base, override)
	local merged = {}
	for key, value in pairs(base) do
		merged[key] = value
	end
	if override then
		for key, value in pairs(override) do
			merged[key] = value
		end
	end
	return merged
end

local function createFloorGrid(config)
	local startX = config.gridPosition.X - (config.gridSize.X / 2)
	local startZ = config.gridPosition.Z - (config.gridSize.Z / 2)
	local y = config.gridPosition.Y
	
	for x = 0, config.gridSize.X - 1 do
		for z = 0, config.gridSize.Z - 1 do
			local blockPos = Vector3.new(
				startX + x,
				y,
				startZ + z
			)
            if false then -- doesn't work
                BlockService.placeBlock(config.floorBlock, blockPos)
                task.wait(0.004) -- Reduce ping throttle
            end
			if config.protectBlocks then
				local key = blockPos.X .. "," .. blockPos.Y .. "," .. blockPos.Z
				protectedBlocks[key] = config.floorBlock
			end
		end
	end
end

local function calculateCirclePoints(center, radius, pointCount)
	local points = {}
	local angleStep = (2 * math.pi) / pointCount
	
	for i = 0, pointCount - 1 do
		local angle = i * angleStep
		local x = center.X + radius * math.cos(angle)
		local z = center.Z + radius * math.sin(angle)
		
		table.insert(points, Vector3.new(
			math.floor(x + 0.5),
			center.Y,
			math.floor(z + 0.5)
		))
	end
	
	return points
end
local function buildPillars(config, positions)
	for i, basePos in ipairs(positions) do
		local startY = config.gridPosition.Y + config.gridSize.Y
		
		for height = 0, config.pillarHeight - 1 do
            local pillarPos = Vector3.new(
                basePos.X,
                startY + height,
                basePos.Z
            )
            if not config.alreadyBuilt then
                BlockService.placeBlock(config.pillarBlock, pillarPos)
                task.wait(0.05) -- Reduce ping throttle
            end
			if config.protectBlocks then
				local key = pillarPos.X .. "," .. pillarPos.Y .. "," .. pillarPos.Z
				protectedBlocks[key] = config.pillarBlock
			end
		end
	end
end

module.cleanup = function(config)
	local startX = config.gridPosition.X - (config.gridSize.X / 2)
	local startZ = config.gridPosition.Z - (config.gridSize.Z / 2)
	local startY = config.gridPosition.Y
	local endY = startY + config.gridSize.Y + config.pillarHeight - 1
	
	for x = 0, config.gridSize.X - 1 do
		for z = 0, config.gridSize.Z - 1 do
			for y = 0, endY - startY do
                if not config.alreadyBuilt then
                    local blockPos = Vector3.new(
                        startX + x,
                        startY + y,
                        startZ + z
                    )
                    
                    local block = BlockService.getBlockAt(blockPos)
                    
                    if block then
                        if block.blockType == config.floorBlock or block.blockType == config.pillarBlock then
                            BlockService.destroyBlock(blockPos)
                            task.wait(0.05) -- Reduce ping throttle
                        end
                    end
                end
			end
		end
	end
	
	protectedBlocks = {}
	
	if isListenerEnabled then
		isListenerEnabled = false
	end
end

module.buildArena = function(config)
	config = mergeConfig(Config, config)
	currentConfig = config
	
	isListenerEnabled = false
	
	protectedBlocks = {}
	
	createFloorGrid(config)
	
	local radius = math.min(config.gridSize.X, config.gridSize.Z) / 2 - config.padding
	
	local pillarPositions = calculateCirclePoints(
        config.gridPosition,
		radius,
		config.teamCount
	)
	
	buildPillars(config, pillarPositions)
	
    if config.protectBlocks then
        isListenerEnabled = true
    end
end

Events.BlockBreak(function(event)
	if not isListenerEnabled then
		return
	end
	
	local key = event.position.X .. "," .. event.position.Y .. "," .. event.position.Z
	local blockType = protectedBlocks[key]
	
	if blockType then
		BlockService.placeBlock(blockType, event.position)
        InventoryService.removeItemAmount(event.player, blockType, 1)
		if currentConfig and currentConfig.protectBlocksCallback then
			currentConfig.protectBlocksCallback(event)
		end
	end
end)

return module