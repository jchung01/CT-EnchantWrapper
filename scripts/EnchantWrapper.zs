#modloaded contenttweaker zenutils
#loader crafttweaker
#reloadable
import crafttweaker.data.IData;
import crafttweaker.item.IItemStack;
import mods.contenttweaker.ResourceLocation;
import mods.zenutils.DataUpdateOperation.APPEND;
import mods.zenutils.StaticString;

/**
  Makes a wrapper item for enchanted items. 
  This fixes a problem with existing worlds where new enchants being added/removed
  would cause CT recipes that output enchanted items to have the wrong enchants
  due to a shift in enchantment ids that CT cannot account for.
**/

<cotItem:superenchant_wrapper>.itemRightClick = function(stack, world, player, hand) {
  if (world.isRemote()) {
    return "FAIL"; 
  }
  if (stack.definition.id != "contenttweaker:superenchant_wrapper" || !stack.hasTag) {
    return "FAIL"; 
  }
  if (!player.creative) {
    stack.shrink(1);
  }
  player.give(unwrap(stack));
  return "SUCCESS";
};

/**
  From a superenchant_wrapper item, return the actual superenchanted item.
**/
function unwrap(item as IItemStack) as IItemStack {
  var out as IItemStack = <item:${item.tag.id}>.withDamage(item.damage);
  var enchList = {} as IData;
  // Convert delayed enchants to actual enchants.
  for enchant in item.tag.delayedEnch.asList() {
    // A singleton map of the enchant.
    for name, level in enchant.asMap() {
      enchList += <enchantment:${name}>.makeEnchantment(level).makeTag();
    }
  }
  out = out.withTag(item.tag.tag + enchList);
  return out;
}

/**
  Holds a map of (ResourceLocation name, int level) entries with
  predictable iteration order (insertion order).
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

zenClass SuperEnchantedItem {  
  // The wrapperItem.
  var wrapperItem as IItemStack;
  
  // The NBT to write to the wrapper.
  var mapNBT as IData;
  
  /**
    Constructor to make the superenchant_wrapper item and write its necessary data
    to NBT. To get the resultant wrapper IItemStack, call:
    `SuperEnchantedItem(IItemStack item, int[ResourceLocation] enchants).wrapperItem`
    
    item is the IItemStack to be superenchanted, possibly with any metadata/NBT.
    
    enchants expects a map of ResourceLocation -> int,
    where the ResourceLocation is the enchantment id (e.g. ResourceLocation.create("minecraft:sharpness"))
    and the int is the level of the enchantment.
  **/
  zenConstructor(item as IItemStack, enchants as EnchantMap) {
    this.mapNBT = {} as IData;
    writeItemData(item, enchants.getMap());
    this.wrapperItem = <contenttweaker:superenchant_wrapper>.withTag(this.mapNBT);
  }
  
  // Writes all necessary item data to wrapper's NBT.
  function writeItemData(item as IItemStack, enchants as int[ResourceLocation]) {
    this.mapNBT += {
      "id": item.definition.id
    } as IData;
    if (item.isDamageable) {
      this.mapNBT += {
        "damage": item.damage
      } as IData;
    }
    if (item.hasTag) {
      this.mapNBT += {
        "tag": item.tag - "ench"
      } as IData;
    }
    this.mapNBT += writeDelayedEnchants(enchants);
    writeDisplayData();
  }
  
  // Write enchants to "delayedEnch" tag.
  function writeDelayedEnchants(enchants as int[ResourceLocation]) as IData {
    var enchantTags = {
      "delayedEnch": {
      }
    } as IData;
    for name, level in enchants {
      enchantTags = enchantTags.deepUpdate(this.writeTag(name, level), APPEND);
    }
    return enchantTags;
  }
  
  // Writes tag for a single enchant.
  function writeTag(loc as ResourceLocation, level as int) as IData {
    val enchantTag = {
      "delayedEnch": [{
        `${loc.domain}:${loc.path}`: level
      }]
    } as IData;
    return enchantTag;
  }
  
  // Writes the name/tooltip to display on the wrapper item.
  function writeDisplayData() {
    this.mapNBT += {
      "display": {
        "Lore": ["line1", "line2"],
        "Name": "test"
      }
    } as IData;
  }
  
  function getItem() as IItemStack {
    return this.wrapperItem;
  }
}