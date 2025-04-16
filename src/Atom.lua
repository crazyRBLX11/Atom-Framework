local RunService = game:GetService("RunService")

if RunService:IsServer() then
	return require(script:FindFirstChild("AtomServer", true))
else
	local AtomServer = script:FindFirstChild("AtomServer", true)
	if AtomServer and RunService:IsRunning() then
		AtomServer:Destroy()
	end

	return require(script:FindFirstChild("AtomClient", true))
end
