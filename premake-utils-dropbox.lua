--[[
    SPDX-License-Identifier: BSD-3-Clause
    Copyright (C) 2016-2023 Raúl Ramos
    See the LICENSE file in the project root for more information.
--]]

-- =========================================================
-- Prevent Dropbox from synchronising some files and folders
-- =========================================================

function exclude_from_dropbox(_items)

    print("[] Excluding files and folders from Dropbox sync...")

    local script = ""

    if os.target() == "windows" then

        -- Do not allow Dropbox to sync these temporary files and folders

        for _, item in ipairs(_items) do
            script = script .. string.format([[
                if (Test-Path "%s") {
                    Set-Content -Path "%s" -Stream com.dropbox.ignored -Value 1
                }
            ]], item, item)
        end

        -- Feed the script to powershell process stdin

        local pipe = io.popen("powershell -command -", "w")
        pipe:write(script)
        pipe:close()

    elseif os.target() == "macosx" then

        -- Do not allow Dropbox to sync these temporary files and folders

        for _, item in ipairs(_items) do
            script = script .. string.format([[
                if [ -d "%s" ] || [ -f "%s" ]; then
                    xattr -w com.dropbox.ignored 1 "%s"
                fi
            ]], item, item, item)
        end

        -- Run the script

        local pipe = io.popen("bash", "w")
        pipe:write(script)
        pipe:close()

    end
end
