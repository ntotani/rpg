package;

import massive.munit.Assert;

class DungeonTest {

    @Test
    public function testSolveAuto():Void {
        var dungeon:Dungeon = new Dungeon();
        var hero:Hero = HeroTest.createMaxHero();
        var result:Dungeon.Result = dungeon.solveAuto([hero]);
        Assert.areEqual(0, result.exp.attack);
        Assert.areEqual(92, hero.getHp());
    }

}
