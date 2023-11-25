# ❓ About SimpleHUD

- _SimpleHUD was made by the same creator as SimpleCore, SimpleBlacklist, Simple911, and much more scripts. Just like others, this script is "simple" as it adds a hud to your screen regarding the following:_
  1. _Your location._
  2. _Your closest postal._
  3. _What the Current AOP is._
  4. _Current Priority status._
  5. _A hud to put your discord server link._
  6. _How many players there are in the server out of the max you can have (For instance: 1/32)_
  7. _Your user ID in the server, so you don't have to look at a player list again to see it._
  8. _Speedometer showing how fast you are going._
- _Other than those simple things being added, it also adds some commands with permissions based requirements as well!_

# ❓ How to install SimpleHUD

- _Just like any other resource, SimpleHUD is easy to install, and configure to your likings. 1st things first, download the latest release from github and open the file._
- _If the folder has `-main` at the end, edit the folder name to remove the extension part to make sure the script works as intended._
- _Drag and drop the files from whatever you used to extract them, whether it was 7.zip or WinRar and put the files in your `\resources` directory._
- _Restart your server and everything should work as intended._

# ⚙️ Configuring SimpleHUD

- _Now that you installed SimpleHUD, you're going to want to configure some of the options that come with the script! To do so, all you have to do is open the Config.lua file and anything there is available to be either turned off, or edited in someway._

# ⌨️ Script Commands

- _/pstart - Starts a priority_
- _/pend - Ends a priority_
- _/pjoin - Join an ongoing priority_
- _/pleave - Leave any ongoing priority_
- _/pcooldown - Starts priority cooldown (Cancels ongoing priorities)_
- _/p - Set a waypoint to a postal given on the map!_
- _/postal - Set a waypoint to a postal given on the map!_
- _/aop - Changes the current Area of Patrol in the server!_
- _/pt - Turns on or off the server's peacetime, restricting players from violence for an x amount of time._

# 🔧 Ace Permission Groups

- _Priority Cooldown Ace Group - `add_ace group.admin sh.ptcd allow`_
- _Peacetime Ace Group - `add_ace group.admin sh.pt allow`_
- _Peacetime LEO / Admin byepass Ace Group - `add_ace group.staff pt.bypass allow`_
- _Peacetime Staff Bypass Ace Group - `add_ace group.staff sh.pts allow`_
- _AOP Ace Group - `add_ace group.admin sh.aop allow`_

# ❗ Notice

- _Some scripts listed given with this release may require permissions to use them, the permission it will go off of is ACE permissions! If you have trouble or don't understand ask for help and I will help you out, or you can join our [discord](https://discord.gg/mxcu8Az8XG) for support._

# 💭 Planned updates.

1. _Add logging to priority script. To show who activates commands._
2. _Add a vehicle hud (Add GUIs to show your plate, engine, etc.)_
3. _Add support for helicopters / planes when it comes to the Speedometer._
