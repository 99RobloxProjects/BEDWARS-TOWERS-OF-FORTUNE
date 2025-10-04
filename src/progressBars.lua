local module = {}

local defaults = {
	baseProgressBarColour = Color3.fromRGB(48, 188, 78),
    timeInterval = 1,
    totalTime = 60,
    defaultText = "PROGRESS BAR"
}

local function createNewTimedProgressBar(text, colourColor3, timeIntervalNumber, timeStartTimeStampNumber, timeEndTimeStampNumber, onProgressBarUpdateFunction)
	local progressBar = UIService.createProgressBar(1)
	progressBar:setColor(colourColor3)
    progressBar:set(0)
	progressBar:setText(text)
	
	local progressObject = {}
    progressObject.isEnabled = false

	local function updateTimeProgressed()
		progressObject.timeProgressed = os.time() - progressObject.timeStart
	end
	
	local function updateProgressBarVisually()
		progressBar:set(progressObject.timeProgressed / progressObject.totalTime)
	end
	
	progressObject.hookTimeLoop = function()
		local function updateTimeFinished()
			progressObject.isEnabled = progressObject.timeProgressed < progressObject.totalTime
		end
		
		updateTimeProgressed()
		updateTimeFinished()
		updateProgressBarVisually()
        onProgressBarUpdateFunction(progressObject)

		while progressObject.isEnabled do
			task.wait(progressObject.timeInterval)
			updateTimeProgressed()
			updateTimeFinished()
			updateProgressBarVisually()
            onProgressBarUpdateFunction(progressObject)
		end
		
		return true
	end
	
	progressObject.beginProgressBar = function(timeIntervalNumber, timeStartTimeStampNumber, timeEndTimeStampNumber)
		if progressObject.isEnabled then
			return false, "progress object is already running"
		end
		
        progressObject.timeStart = timeStartTimeStampNumber
		progressObject.timeEnd = timeEndTimeStampNumber
		progressObject.timeInterval = timeIntervalNumber
		progressObject.totalTime = progressObject.timeEnd - progressObject.timeStart
		progressObject.timeProgressed = 0
		progressObject.isEnabled = true
        progressObject.EasyGGObject = progressBar
		
		task.spawn(function()
			progressObject.hookTimeLoop()
		end)
		
		return true
	end
	
	progressObject.stop = function()
		progressObject.isEnabled = false
	end
	
	progressObject.destroy = function()
		progressObject.stop()
		progressBar:destroy()
	end
	
	return progressObject
end

module.newTimedProgressBarTracker = function(textString, colourColor3, timeIntervalNumber, timeStartTimeStampNumber, timeEndTimeStampNumber, callBack)
	local timeStart = timeStartTimeStampNumber or os.time()
	local timeEnd = timeEndTimeStampNumber or (timeStart + defaults.totalTime)
	local timeInterval = timeIntervalNumber or defaults.timeInterval
	local text = textString or defaults.defaultText
    local colour = colourColor3 or defaults.baseProgressBarColour
    local onUpdate = callBack or function() end

	local progressObject = createNewTimedProgressBar(text, colour, timeInterval, timeStart, timeEnd, onUpdate)
	
	progressObject.beginProgressBar(timeInterval, timeStart, timeEnd)
	
	return progressObject
end

return module