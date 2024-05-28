#modloaded randomtweaker
#priority 1
#reloadable

import mods.jei.JEI;
import mods.randomtweaker.jei.IJeiPanel;
import mods.randomtweaker.jei.IJeiUtils;
import scripts.EnchantUtil;
import scripts.EnchantUtil.WrapperRegistry;

var superenchantJEI as IJeiPanel = JEI.createJei("custom_superenchant", "Superenchants");
superenchantJEI.setModid("MeatballCraft");
superenchantJEI.setIcon(<contenttweaker:superenchant_wrapper>);
superenchantJEI.setBackground(IJeiUtils.createBackground(150, 50));
superenchantJEI.addSlot(IJeiUtils.createItemSlot(40, 20, true)); // input
superenchantJEI.addSlot(IJeiUtils.createItemSlot(95, 20, false)); // output
superenchantJEI.addElement(IJeiUtils.createArrowElement(64, 20, 0));
superenchantJEI.addElement(IJeiUtils.createImageElement("mouseLeft", 68, 1, 13, 14, 0, 0, "contenttweaker:textures/gui/mouse_right.png", 16, 16));
superenchantJEI.onTooltip(function(mouseX, mouseY) as string[]{
  if (mouseX <= 81 && mouseX >= 68 && mouseY <= 18 && mouseY >= 1) {
    return ["Right-click"];
  }  
  return [];
});
superenchantJEI.register();

for wrapperItem in WrapperRegistry.INSTANCE.get() {
  val recipe = JEI.createJeiRecipe("custom_superenchant");
  recipe.addInput(wrapperItem);
  recipe.addOutput(EnchantUtil.unwrapJEI(wrapperItem));
  recipe.build();
}