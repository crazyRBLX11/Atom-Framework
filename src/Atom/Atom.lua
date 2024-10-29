local RunService = game:GetService("RunService")

if RunService:IsServer() then
	return require(script.AtomServer_OOP)
else
	local AtomServer = script:FindFirstChild("AtomServer_OOP")
	if AtomServer and RunService:IsRunning() then
		AtomServer:Destroy()
	end
	
	return require(script.AtomClient_OOP)
end