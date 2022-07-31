# Lua API Mockup
This mockup represents the Lua API in the Dual Universe game, it is public and free to use.
It is intended to help players developing in Lua in the game.

# Change Log
All notable changes to this mockup will be documented in this file.
 
## [0.31.1] - 2022-07-26
 
The Lua API for industries has been reworked to integrate schematics v2.
 
### Added
 * Added new industry Lua API:
   * **setOutput(**[int] **itemId)** : Set the item to produce from its id.
   * [table] **getOutputs()** : Returns the id list of items currently produced, the first entry in the table is always the main product.
   * [table] **getInputs()** : Returns the id list of items required to run the current production.
   * [table] **getInfo()** : The complete state of the industry (the schematicsRemaining and currentProducts fields have been added).
   * [float] **updateBank()** : Send a request to get an update of the content of the schematic bank, limited to one request allowed per 30 seconds.
   * [table] **getBank()** : Returns a table describing the content of the schematic bank, as a pair item id and quantity per slot.
   * [event] **onBankUpdate()** : Emitted when the schematic bank is updated.

 * Added new system Lua API:
   * [table] **getRecipes(**[int] **itemId)** : Returns a list of recipes producing the given item from its id.
 
### Changed
 * Changed existing industry Lua API:
   * Deprecated `getCurrentSchematic` function.
   * Deprecated `setCurrentSchematic` function.
   
 * Changed existing system Lua API:
   * [table] **system.getItem(**[int] **itemId)** : Added two new fields ; `products` to list product item ids if the item is a schematic and `schematics` to list item ids of schematics producing this item.
   * Deprecated getSchematic function.
   
 * Changed existing core unit Lua API:
   * [table] **core.getElementIndustryInfoById(**[int] **localId)** : Description update (always returns the getInfo from the industry Lua API).

#### Fixes on the API mockup
 * Added missing system.print() function.
 * Fixed incorrect documentation type for core.getIndustryInfoById().state, was int instead of string.
