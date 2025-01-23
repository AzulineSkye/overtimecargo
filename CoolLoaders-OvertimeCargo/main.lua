mods["RoRRModdingToolkit-RoRR_Modding_Toolkit"].auto(true)

PATH = _ENV["!plugins_mod_folder_path"]
NAMESPACE = "OvertimeCargo"

local init = function()
	local folders = {
		"Items",
		"Sprites",
		"Language",
	}

	for _, folder in ipairs(folders) do
		local filepaths = path.get_files(path.combine(PATH, folder))
		for _, filepath in ipairs(filepaths) do
			if string.sub(filepath, -4, -1) == ".lua" then
				require(filepath)
			end
		end
	end

	HOTLOADING = true
end
Initialize(init)

if HOTLOADING then
	init()
end