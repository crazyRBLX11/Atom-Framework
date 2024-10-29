local RunService = game:GetService("RunService")

if RunService:IsServer() then
	return require(script:FindFirstChild("AtomServer_OOP", true))
else
	local AtomServer = script:FindFirstChild("AtomServer_OOP", true)
	if AtomServer and RunService:IsRunning() then
		AtomServer:Destroy()
	end
	
	return require(script:FindFirstChild("AtomClient_OOP", true))
end