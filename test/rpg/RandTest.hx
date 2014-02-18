package rpg;

import massive.munit.Assert;

class RandTest {

    @Test
    public function testRand():Void {
        Assert.isNotNull(Rand.next());
    }

    @Test
    public function testDebug():Void {
        Rand.startDebug([33, 22, 11]);
        Assert.areEqual(33, Rand.next());
        Assert.areEqual(22, Rand.next());
        Assert.areEqual(11, Rand.next());
        Rand.endDebug();
    }

}
