local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = {}

function Remotes.Init()
	local remoteFolder = ReplicatedStorage:FindFirstChild("Remotes")
	if not remoteFolder then
		remoteFolder = Instance.new("Folder")
		remoteFolder.Name = "Remotes"
		remoteFolder.Parent = ReplicatedStorage
	end

	local rebirthRequest = remoteFolder:FindFirstChild("RebirthRequest")
	if not rebirthRequest then
		rebirthRequest = Instance.new("RemoteEvent")
		rebirthRequest.Name = "RebirthRequest"
		rebirthRequest.Parent = remoteFolder
	end

	local petEquipRequest = remoteFolder:FindFirstChild("PetEquipRequest")
	if not petEquipRequest then
		petEquipRequest = Instance.new("RemoteEvent")
		petEquipRequest.Name = "PetEquipRequest"
		petEquipRequest.Parent = remoteFolder
	end
	
	return remoteFolder
end

return Remotes
