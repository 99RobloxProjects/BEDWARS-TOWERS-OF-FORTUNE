-- leaderboard.lua

local board = UIService.createLeaderboard()
local leaderboardStats = {
    players = {

    },
    teams = {

    }
}
local personalProgressBarService = require("personalProgress")
local function addScoreToLeaderboard(player, amount)
    local thisLeaderboardPlayer = leaderboardStats.players[player]
    if not thisLeaderboardPlayer then
        thisLeaderboardPlayer = {score = 0}
        leaderboardStats.players[player] = thisLeaderboardPlayer
        board:addKey(player.name, 0)
    end
    thisLeaderboardPlayer.score += amount
    board:addScore(player.name, amount)
end
Events.PlayerAdded(function(event)
    addScoreToLeaderboard(event.player.name, 0)
end)
local function giveKillMessage(message, player)
    task.spawn(function()
        local thisUIProgressBar = personalProgressBarService.createPersonalProgressBar({player}, 1)
        thisUIProgressBar:set(1)
        thisUIProgressBar:setColor(Color3.fromRGB(0, 255, 0))
        thisUIProgressBar:setText(message)
        task.wait(2)
        thisUIProgressBar:destroy()
    end)
end
local function formatDeathMessage()

end
Events.EntityDeath(function(event)
    local thisPlayer = event.entity:getPlayer() 
    local killerPlayer = event.killer and event.killer:getPlayer()
    if (thisPlayer == nil) then
        return
    end
    local finalPlayerText = ""
    for i, entity in ipairs(event.assists) do
        local thisAssistPlayer = entity:getPlayer()
        if not thisAssistPlayer then
            continue
        end
        addScoreToLeaderboard(thisAssistPlayer, 0.5)
        finalPlayerText = finalPlayerText.." + "..thisAssistPlayer.name
        SoundService.playSoundForPlayer(thisAssistPlayer, SoundType.UI_REWARD)
        giveKillMessage(`ASSIST <b><font color='rgb(255, 255, 0)'>{thisPlayer.name}</font></b>`, thisAssistPlayer)
    end
    if killerPlayer then
        addScoreToLeaderboard(killerPlayer, 1)
        finalPlayerText = finalPlayerText.." + "..killerPlayer.name
        SoundService.playSoundForPlayer(killerPlayer, SoundType.UI_REWARD)
        giveKillMessage(`ELIMINATED <b><font color='rgb(255, 255, 0)'>{thisPlayer.name}</font></b>`, killerPlayer)
    end
    SoundService.playSoundForPlayer(thisPlayer, SoundType.UI_REWARD)
    giveKillMessage(`DEATH <b><font color='rgb(255, 255, 0)'>{thisPlayer.name}</font></b>`, thisPlayer)
    ChatService.sendMessage(`<b><font color='rgb(255, 97, 97)'>{finalPlayerText:sub(3, #finalPlayerText)} eliminated {thisPlayer.name}</font></b>`)
end)