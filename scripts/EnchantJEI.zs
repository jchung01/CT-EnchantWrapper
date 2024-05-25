#modloaded randomtweaker
#priority 1
#reloadable

import mods.jei.JEI;
import mods.randomtweaker.jei.IJeiPanel;
import mods.randomtweaker.jei.IJeiUtils;
import scripts.EnchantUtil;
import scripts.EnchantUtil.WrapperMap;

var superenchantJEI as IJeiPanel = JEI.createJei("superenchant_jei", "Superenchants");
superenchantJEI.setModid("MeatballCraft");
superenchantJEI.setIcon(<contenttweaker:superenchant_wrapper>);
superenchantJEI.setBackground(IJeiUtils.createBackground(150, 50));
superenchantJEI.addSlot(IJeiUtils.createItemSlot(40, 18, true));
superenchantJEI.addSlot(IJeiUtils.createItemSlot(95, 18, false));
superenchantJEI.addElement(IJeiUtils.createArrowElement(65, 18, 0));
superenchantJEI.register();

for wrapperItem in WrapperMap.INSTANCE.getMap().values {
  val recipe = JEI.createJeiRecipe("superenchant_jei");
  recipe.addInput(wrapperItem);
  recipe.addOutput(EnchantUtil.unwrapJEI(wrapperItem));
  recipe.build();
}