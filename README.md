# DroneCompanionsV2

 Fixes:
* Items can be purchased as expected at RipperDocs such as the tech decks and mods
* Mods can now be equipped to teh tech decks and seem to function as expected
* When a drone is manually spawned via console commands, quickhacks function as expected
* Robots now get into the cars and fight while driving

Bugs:
* Tech deck mods work, but are misnamed as Berserks
* Drones DO NOT SPAWN when crafted, which means that behavioral items are difficult/impossible to test (manual spawning is iffy)
* ALL drones get into the cars...even the flying ones. Causes cars to be destroyed when larger robots enter them
* Crash on fast travel relating to legacy saving issues

Suggested fixes, that were unable to be implemented:
1. Rework spawning to use Codeware instead of legacy brute-force LUA script
2. Save robots between sessions via Codeware to prevent CTD on load (see Appearance Menu Mod for details)
3. Change from crafting drones to a grenade (to be purchased at vendor). When grenade is thrown, vehicle summon arrives with robots / drones (behemoth for Octant / mechs, Meridith Stout car for robots / Wyverns). This also prevents robots from following into interiors.
