#modloaded contenttweaker zenutils
#loader crafttweaker
#priority 3
#reloadable

import crafttweaker.data.IData;
import crafttweaker.item.IItemStack;
import mods.contenttweaker.ResourceLocation;
import mods.zenutils.DataUpdateOperation.APPEND;
import scripts.EnchantUtil;
import scripts.EnchantUtil.EnchantMap;
import scripts.EnchantUtil.WrapperMap;

/**
  This script makes a wrapper item for enchanted items. 
  This fixes a problem with existing worlds where new enchants being added/removed
  would cause CT recipes that output enchanted items to have the wrong enchants
  due to a shift in enchantment ids that CT cannot account for.
**/

/**
  Controls the actual conversion of the wrapper item to the enchanted item on right click.
**/
<cotItem:superenchant_wrapper>.itemRightClick = function(stack, world, player, hand) {
  if (world.isRemote()) {
    return "FAIL"; 
  }
  val result as IItemStack = EnchantUtil.unwrap(stack);
  if (isNull(result)) {
    return "FAIL";
  }
  if (!player.creative) {
    stack.shrink(1);
  }
  player.give(result);
  return "SUCCESS";
};

zenClass SuperEnchantedItem {  
  // The wrapperItem.
  var wrapperItem as IItemStack;
  
  // The NBT to write to the wrapper.
  var mapNBT as IData;
  
  /**
    Constructor to make the superenchant_wrapper item and write its necessary data
    to NBT. To get the resultant wrapper IItemStack, call:
    `SuperEnchantedItem(IItemStack item, EnchantMap enchants).getItem()`
    
    item is the IItemStack to be superenchanted, possibly with any metadata/NBT.
    
    enchants expects a populated EnchantMap object.
  **/
  zenConstructor(item as IItemStack, enchants as EnchantMap) {
    this.mapNBT = {} as IData;
    writeItemData(item, enchants.getMap());
    this.wrapperItem = <contenttweaker:superenchant_wrapper>.withTag(this.mapNBT);
    WrapperMap.INSTANCE.add(this.getItem());
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