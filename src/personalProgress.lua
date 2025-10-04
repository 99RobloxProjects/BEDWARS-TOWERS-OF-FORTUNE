local module = {}
local personalBars = {}
Events.PlayerAdded(function(event)
    for i, bar in pairs(personalBars) do
        if bar then
            bar.removePlayer(event.player)
        end
    end
end)
module.createPersonalProgressBar = function(players, maxProgress)
    local progressBar = UIService.createProgressBar(maxProgress)
    table.insert(personalBars, progressBar)
    for i, player in pairs(PlayerService.getPlayers()) do
        progressBar:removePlayer(player)
    end
    for i, player in pairs(players) do
        progressBar:addPlayer(player)
    end
    return progressBar
end

return module