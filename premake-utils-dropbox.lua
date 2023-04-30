--[[
    SPDX-License-Identifier: BSD-3-Clause
    Copyright (C) 2016-2023 Raúl Ramos
    See the LICENSE file in the project root for more information.
--]]

-- =========================================================
-- Prevent Dropbox from synchronising some files and folders
-- =========================================================
--
function remove_leading_space(_text)
    local lines = {}
    for line in _text:gmatch("[^\n]+") do
        local cleanedLine = line:gsub("^%s*", "")
        table.insert(lines, cleanedLine)
    end
    return table.concat(lines, "\n")
end

function exclude_folders_from_dropbox(_folders)
    local script = ""

    if os.target() == "windows" then
        for _, folder in ipairs(_folders) do
            print(string.format("[] Excluding \"%s\" from Dropbox sync...", folder))
            script = script .. remove_leading_space(string.format([[
                New-Item %s -type directory -force | Out-Null
                Set-Content -Path '%s' -Stream com.dropbox.ignored -Value 1 | Out-Null
            ]], folder, folder))

        end

        -- Feed the script to powershell process stdin
        local pipe = io.popen("powershell -command -", "w")
        pipe:write(script)
        pipe:close()

    elseif os.target() == "macosx" then
        for _, folder in ipairs(_folders) do
            print(string.format("[] Excluding \"%s\" from Dropbox sync...", folder))
            script = script .. remove_leading_space(string.format([[
                mkdir -p "%s"
                xattr -w com.dropbox.ignored 1 "%s"
            ]], folder, folder))
        end
        script = remove_leading_space(script)

        -- Run the script
        local pipe = io.popen("bash", "w")
        pipe:write(script)
        pipe:close()
    end
end

function exclude_files_from_dropbox(_files)

    local script = ""

    if os.target() == "windows" then
        for _, file in ipairs(_files) do
            print(string.format("[] Excluding \"%s\" from Dropbox sync...", file))
            script = script .. remove_leading_space(string.format([[
                if (Test-Path "%s" -PathType Leaf) {
                    Set-Content -Path "%s" -Stream com.dropbox.ignored -Value 1
                }
            ]], file, file))
        end

        -- Feed the script to powershell process stdin
        local pipe = io.popen("powershell -command -", "w")
        pipe:write(script)
        pipe:close()

    elseif os.target() == "macosx" then
        for _, file in ipairs(_files) do
            print(string.format("[] Excluding \"%s\" from Dropbox sync...", file))
            script = script .. remove_leading_space(string.format([[
                if [ -f "%s" ]; then
                    xattr -w com.dropbox.ignored 1 "%s"
                fi
            ]], file, file))
        end

        -- Run the script
        local pipe = io.popen("bash", "w")
        pipe:write(script)
        pipe:close()
    end
end
