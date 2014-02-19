package rpg;

import massive.munit.Assert;

class ColorTest {

    @Test
    public function testRate():Void {
        var from = Color.FIRE;
        var to = Color.TREE;
        Assert.areEqual(2.0, Color.Colors.rate(from, to));
    }

    @Test
    public function testValueOf():Void {
        var color = Color.Colors.valueOf('SUN');
        Assert.areEqual(Color.SUN, color);
    }

}
