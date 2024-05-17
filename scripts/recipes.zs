// OLD IMPORTS
import crafttweaker.data.IData;
import crafttweaker.enchantments.IEnchantmentDefinition;
// NEW IMPORTS
import mods.contenttweaker.ResourceLocation;
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
var enclistSwordWrapped as int[ResourceLocation] = {
  ResourceLocation.create("minecraft:sharpness"): 5,
  ResourceLocation.create("cofhcore:vorpal"): 10,
};

// Wrapper method, id does not shift
recipes.addShapeless("wrapperEnch", 
  SuperEnchantedItem(
    <minecraft:diamond_sword>.withTag( // Don't include an "ench" tag here! It will be ignored.
      {display: {Name:"§6§oDiamond Sword§r",Lore:["§d§oSuper-Enchanted§r"]}}
    ),
    enclistSwordWrapped
  ).wrapperItem, // Make sure to get the wrapperItem IItemStack!
  [<minecraft:chest>, <minecraft:diamond>]
);

var enclistMantleWrapped as int[ResourceLocation] = {
  ResourceLocation.create("minecraft:protection"): 10,
  ResourceLocation.create("minecraft:fire_protection"): 10,
  ResourceLocation.create("openblocks:last_stand"): 30,
  ResourceLocation.create("minecraft:unbreaking"): 100,
  ResourceLocation.create("minecraft:mending"): 1,
  ResourceLocation.create("minecraft:blast_protection"): 10,
  ResourceLocation.create("minecraft:projectile_protection"): 10,
};
mods.extendedcrafting.TableCrafting.addShaped(
  SuperEnchantedItem(
    <astralsorcery:itemcape>.withTag(
      {RepairCost: 1, astralsorcery: {constellationName: "astralsorcery.constellation.armara"}}
    ),
    enclistMantleWrapped
  ).wrapperItem,
  [[<minecraft:diamond_helmet>, <minecraft:book>, null, null, null, null, null], 
   [null, null, null, null, null, null, null], 
   [null, null, null, null, null, null, null], 
   [null, null, null, null, null, null, null], 
   [null, null, null, null, null, null, null], 
   [null, null, null, null, null, null, null], 
   [null, null, null, null, null, null, null]]
);