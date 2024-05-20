#reloadable
import crafttweaker.data.IData;
import mods.contenttweaker.ResourceLocation;
import crafttweaker.enchantments.IEnchantment;
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