# ❓ About SimpleHUD

* *SimpleHUD was made by the same creator as SimpleCore, SimpleBlacklist, Simple911, and much more scripts. Just like others, this script is "simple" as it adds a hud to your screen regarding the following:*
  1. *Your location.*
  2. *Your closest postal.*
  3. *What the Current AOP is.*
  4. *Current Priority status.*
  5. *A hud to put your discord server link.*
  6. *How many players there are in the server out of the max you can have (For instance: 1/32)*
  7. *Your user ID in the server, so you don't have to look at a player list again to see it.*
  8. *Speedometer showing how fast you are going.*
* *Other than those simple things being added, it also adds some commands with permissions based requirements as well!*

# ❓ How to install SimpleHUD

* *Just like any other resource, SimpleHUD is easy to install, and configure to your likings. 1st things first, download the latest release from github and open the file.*
* *If the folder has `-main` at the end, edit the folder name to remove the extension part to make sure the script works as intended.*
* *Drag and drop the files from whatever you used to extract them, whether it was 7.zip or WinRar and put the files in your `\resources` directory.*
* *Restart your server and everything should work as intended.*

# ⚙️ Configuring SimpleHUD

* *Now that you installed SimpleHUD, you're going to want to configure some of the options that come with the script! To do so, all you have to do is open the Config.lua file and anything there is available to be either turned off, or edited in someway.*

# ⌨️ Script Commands

* */pstart - Starts a priority*
* */pend -  Ends a priority*
* */pjoin - Join an ongoing priority*
* */pleave - Leave any ongoing priority*
* */pcooldown - Starts priority cooldown (Cancels ongoing priorities)*
* */p - Set a waypoint to a postal given on the map!*
* */postal - Set a waypoint to a postal given on the map!*
* */aop - Changes the current Area of Patrol in the server!*
* */pt - Turns on or off the server's peacetime, restricting players from violence for an x amount of time.*

# 🔧 Ace Permission Groups
* *Priority Cooldown Ace Group - `add_ace group.admin sh.ptcd allow`*
* *Peacetime Ace Group - `add_ace group.admin sh.pt allow`*
* *Peacetime LEO byepass Ace Group - `add_ace group.leo sh.ptl allow`*
* *Peacetime Staff Bypass Ace Group - `add_ace group.staff sh.pts allow`*
* *AOP Ace Group - `add_ace group.admin sh.aop allow`*

# ❗ Notice

* *Some scripts listed given with this release may require permissions to use them, the permission it will go off of is ACE permissions! If you have trouble or don't understand ask for help and I will help you out, or you can join our [discord](https://discord.gg/mxcu8Az8XG) for support.*

# 💭 Planned updates.

1. *Add logging to priority script. To show who activates commands.*
2. *Add a vehicle hud (Add GUIs to show your plate, engine, etc.)*
3. *Add support for helicopters / planes when it comes to the Speedometer.*