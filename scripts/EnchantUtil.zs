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
function makeIntTag(enchant as IEnchantment, isBook as bool) as IData {
  var key = "ench";
  if (isBook) {
    key = "StoredEnchantments";
  }
  return {
    `${key}`: [{
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
      enchList += makeIntTag(<enchantment:${name}>.makeEnchantment(level), false);
    }
  }
  out = out.withTag(item.tag.tag + enchList);
  return out;
}

/**
  From a superenchant_wrapper item, return a representation of the superenchanted item.
  Because of how JEI loads, this representation transforms only the tooltip on hover, not its NBT,
  in order to preserve proper keybind "Show recipes" & "Show usages" functionality.
**/
function unwrapJEI(wrapper as IItemStack) as IItemStack[] {
  if (wrapper.definition.id != "contenttweaker:superenchant_wrapper" || !wrapper.hasTag) {
    return null; 
  }
  var base as IItemStack = <item:${wrapper.tag.id}>.withDamage(wrapper.damage);
  // Unique identifier for running addAdvancedTooltip.
  val identifier = {
    id: wrapper.tag.id,
    delayedEnch: wrapper.tag.delayedEnch
  } as IData;
  base = base.withTag(wrapper.tag.tag);
  // Add a dummy enchant for the glow.
  val dummyEnchant = <enchantment:minecraft:protection>.makeEnchantment(1);
  base.addEnchantment(dummyEnchant);
  base.removeTooltip(dummyEnchant.displayName);
  var book as IItemStack = <minecraft:enchanted_book>.withTag(identifier);
  // Setup item transformer to run later.
  var transformed = book.transformNew(function(item) {
    var enchList = {} as IData;
    for enchant in wrapper.tag.delayedEnch.asList() {
      for name, level in enchant.asMap() {
        enchList += makeIntTag(<enchantment:${name}>.makeEnchantment(level), true);
      }
    }
    return item.withTag(enchList).withLore(["The superenchanted item will have these enchants"]);
  });
  book.addAdvancedTooltip(function(item) {
    transformed.applyNewTransform(item);
    return null;
  });
  return [base, book] as IItemStack[];
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
  Registry that holds all registered superenchant_wrapper items.
  For use in EnchantWrapper.SuperEnchantedItem.
**/
zenClass WrapperRegistry {
  static INSTANCE = WrapperRegistry();
  
  val wrapperItems as IItemStack[];
  
  zenConstructor() {
    wrapperItems = [] as IItemStack[];
  }
  
  function add(wrapper as IItemStack) {
    wrapperItems += wrapper;
  }
  
  function get() as IItemStack[] {
    return this.wrapperItems;
  }
}