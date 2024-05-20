#reloadable
// OLD IMPORTS
import crafttweaker.data.IData;
import crafttweaker.enchantments.IEnchantmentDefinition;
// NEW IMPORTS
import scripts.EnchantUtil.EnchantMap;
import scripts.EnchantWrapper.SuperEnchantedItem;

// ---- OLD WAY ----
val enclistSword as IEnchantmentDefinition[] = [<enchantment:minecraft:sharpness>, <enchantment:cofhcore:vorpal>];
var mapSword as IData = {};
mapSword += enclistSword[0].makeEnchantment(5).makeTag();
mapSword += enclistSword[1].makeEnchantment(10).makeTag();

// Old method using nbt map, id shifts
recipes.addShapeless("mapEnch", <minecraft:diamond_sword>.withTag(mapSword),
  [<minecraft:paper>, <minecraft:diamond>]
);

// ---- NEW WAY ----
val enclistSwordWrapped as EnchantMap = EnchantMap()
  .add("minecraft:sharpness", 5)
  .add("cofhcore:vorpal", 10);

// Wrapper method, id does not shift
recipes.addShapeless("wrapperEnch", 
  SuperEnchantedItem(
    <minecraft:diamond_sword>.withTag( // Don't include an "ench" tag here! It will be ignored.
      {display: {Name:"§6§oDiamond Sword§r",Lore:["§d§oSuper-Enchanted§r"]}}
    ),
    enclistSwordWrapped
  ).getItem(), // Make sure to get the IItemStack!
  [<minecraft:chest>, <minecraft:diamond>]
);

val enclistMantleWrapped as EnchantMap = EnchantMap()
  .add("minecraft:protection", 10)
  .add("minecraft:fire_protection", 10)
  .add("openblocks:last_stand", 30)
  .add("minecraft:unbreaking", 100)
  .add("minecraft:mending", 1)
  .add("minecraft:blast_protection", 10)
  .add("minecraft:projectile_protection", 10);
  
mods.extendedcrafting.TableCrafting.addShaped(
  SuperEnchantedItem(
    <astralsorcery:itemcape>.withTag(
      {RepairCost: 1, astralsorcery: {constellationName: "astralsorcery.constellation.armara"}}
    ),
    enclistMantleWrapped
  ).getItem(),
  [[<minecraft:diamond_helmet>, <minecraft:book>, null, null, null, null, null], 
   [null, null, null, null, null, null, null], 
   [null, null, null, null, null, null, null], 
   [null, null, null, null, null, null, null], 
   [null, null, null, null, null, null, null], 
   [null, null, null, null, null, null, null], 
   [null, null, null, null, null, null, null]]
);