Config = {}

Config.Main = {

    -- Vehicle Scripts
    useKMH = false, -- Change the speedometer to use Kilometers per hour rather than miles per hour.
    hideRadarOnFoot = true, -- Enable / Disable the ability to make your radar hide whilst out of a vehicle.
    speedlimitHUD = true, -- Enable / Disable the speedlimit HUD that shows the speed on any road.

    -- Priority Scripts
    priorityScript = true, -- Enable / Disable the priority system
    priorityCooldown = 25, -- How long in minutes someone will have to wait before starting another priority.
    PrioCDPermissions = true, -- Enable / Disable the permission system for /pcooldown (Ace permissions: ``add_ace group.admin sh.ptcd allow``)

    -- Peacetime Scripts
    peacetimeScript = true, -- Enable / Disable the peacetime script. (Prevent people from always doing priorities!) (add_ace group.admin sh.pt)
    peacetimeBypass = true, -- Enable / Disable the ability for law enforcement officers or staff to bypass the peacetime restrictions given. (``add_ace group.admin pt.bypass``)

    -- AOP Scripts
    aopScript = true, -- Enable / Disable the AOP system.
    defaultAOP = "Sandy Shores", -- Where the AOP will default to anytime the server or script restarts.
    aopPermissions = true, -- Enable / Disable the permission system for /aop (Ace permissions: ``add_ace group.admin sh.aop allow``)

    -- Postal Scripts
    postalScript = true, -- Enable / Disable the postal system.

    -- Misc. Huds
    discordScript = true, -- Enable / Disable the Discord HUD
    DiscordURL = "https://discord.gg/CHANGEME", -- Discord link for Discord HUD
    onlinePlayers = true, -- Enable / Disable the online players HUD
    maxPlayers = 32, -- Change this number to the max amount of players that can be in your server!
    playerID = true, -- Enable / Disable your own ID showing as a HUD.

    -- Weapon Hud
    realisticWeaponNames = true, -- Use the weapons real life names rather than GTA knockoffs. (Recommended to run with https://github.com/Fadinlaws123/Realistic_Weapon_Wheel)
    mark2Support = true, -- Enable / Disable the name support for mark 2 weapons. 
    customWeaponNames = false, -- Enable / Disable the usage of custom weapon names (Names you can put yourself! edit "Config.WeaponNames")

}