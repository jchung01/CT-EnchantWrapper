#priority 4
#reloadable

import crafttweaker.data.IData;
import crafttweaker.enchantments.IEnchantment;
import crafttweaker.item.IItemStack;
import mods.contenttweaker.ResourceLocation;
import mods.zenutils.StaticString;

/**
  Same as IEnchantment#makeTag(), but uses int enchant id.
  Useful if you have JEID extending enchantment ids.
**/
function makeIntTag(enchant as IEnchantment) as IData {
  return {
    ench: [{
      id: enchant.definition.id,
      lvl: enchant.level
    }]
  } as IData;
}

/**
  From a superenchant_wrapper item, return the actual superenchanted item.
**/
function unwrap(item as IItemStack) as IItemStack {
  if (item.definition.id != "contenttweaker:superenchant_wrapper" || !item.hasTag) {
    return null; 
  }
  var out as IItemStack = <item:${item.tag.id}>.withDamage(item.damage);
  var enchList = {} as IData;
  // Convert delayed enchants to actual enchants.
  for enchant in item.tag.delayedEnch.asList() {
    // A singleton map of the enchant.
    for name, level in enchant.asMap() {
      enchList += makeIntTag(<enchantment:${name}>.makeEnchantment(level));
    }
  }
  out = out.withTag(item.tag.tag + enchList);
  return out;
}

/**
  From a superenchant_wrapper item, return a representation of the superenchanted item.
  Because of how JEI loads, the NBT is dynamically transformed on tooltip hover.
**/
function unwrapJEI(item as IItemStack) as IItemStack {
  if (item.definition.id != "contenttweaker:superenchant_wrapper" || !item.hasTag) {
    return null; 
  }
  var base as IItemStack = <item:${item.tag.id}>.withDamage(item.damage);
  // Add a dummy enchant for the glow, removed in transformer.
  val dummyEnch = <enchantment:minecraft:unbreaking>.makeEnchantment(1).makeTag();
  // Build NBT
  val delayedEnch = {
    delayedEnch: item.tag.delayedEnch
  } as IData;
  base = base.withTag(item.tag.tag + delayedEnch + dummyEnch);
  // Setup item transformer to run later.
  val transformed = base.transformNew(function(item) {
    var enchList = {} as IData;
    for enchant in item.tag.delayedEnch.asList() {
      // A singleton map of the enchant.
      for name, level in enchant.asMap() {
        enchList += makeIntTag(<enchantment:${name}>.makeEnchantment(level));
      }
    }
    return item.withTag(item.tag - dummyEnch - delayedEnch + enchList);
  });
  // Late execute transformer on item hover.
  base.addAdvancedTooltip(function(item) {
    if (item.hasTag && !isNull(item.tag.delayedEnch)) {
      transformed.applyNewTransform(item);
    }
    return "";
  });
  return base;
}

/**
  Holds a map of (ResourceLocation name, int level) enchantment entries with
  predictable iteration order (insertion order).
  
  Making an instance would look something like this:
  `EnchantMap().add(name1, level1).add(name2, level2)...;`
**/
zenClass EnchantMap {
  val enchants as int[ResourceLocation];
  
  zenConstructor() {
    enchants = {} as int[ResourceLocation]$orderly;
  }
  
  function add(name as string, level as int) as EnchantMap {
    if (StaticString.countMatches(name, ':') != 1) {
      print("EnchantWrapper.EnchantMap.zs - Add to map failed! name: " + name + " level:" + level);
    }
    else {
      enchants[ResourceLocation.create(name)] = level;
    }
    return this;
  }
  
  function getMap() as int[ResourceLocation] {
    return this.enchants;
  }
}

/**
  Singleton instance of a map that holds all registered superenchant_wrapper items.
  For use in EnchantWrapper.SuperEnchantedItem.
**/
zenClass WrapperMap {
  static INSTANCE = WrapperMap();
  
  val wrapperItems as IItemStack[int];
  var index as int;
  
  zenConstructor() {
    wrapperItems = {} as IItemStack[int];
    index = 0;
  }
  
  function add(wrapper as IItemStack) {
    wrapperItems[index] = wrapper;
    index += 1;
  }
  
  function getMap() as IItemStack[int] {
    return this.wrapperItems;
  }
}