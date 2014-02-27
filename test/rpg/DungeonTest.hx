package rpg;

import massive.munit.Assert;
import rpg.battle.*;
import rpg.battle.Result;

class DungeonTest {

    @Test
    public function testSpawnEnemies():Void {
        var dungeon = createEasyDungeon(1);
        var enemies = dungeon.toHeros(dungeon.spawnEnemies(), 1);
        Assert.isTrue(enemies[0].getHp() > 0);
    }

    @Test
    public function testSolveAuto():Void {
        Rand.startDebug([0]);
        var dungeon = createEasyDungeon(1);
        var hero:Hero = HeroTest.createMaxHero();
        var result:Dungeon.DungeonResult = dungeon.solveAuto([hero], 1);
        Assert.isTrue(hero.getHp() < hero.getParameter().health);
        Assert.isTrue(isWin(result.battles[0]));
        Rand.endDebug();
    }

    @Test
    public function testSolveAutoStop():Void {
        var dungeon = createEasyDungeon(2);
        var hero:Hero = HeroTest.createMaxHero();
        var result:Dungeon.DungeonResult = dungeon.solveAuto([hero], 1);
        Assert.areEqual(1, result.battles.length);
    }

    @Test
    public function testSolveAutoFail():Void {
        var dungeon = createExtreamDungeon(2);
        var hero:Hero = HeroTest.createMinHero();
        var result:Dungeon.DungeonResult = dungeon.solveAuto([hero], 2);
        Assert.areEqual(1, result.battles.length);
        Assert.isFalse(isWin(result.battles[0]));
    }

    @Test
    public function testSolveAutoCallback():Void {
        Rand.startDebug([0]);
        var dungeon = createEasyDungeon(1);
        var hero:Hero = HeroTest.createMaxHero();
        var called = false;
        dungeon.solveAuto([hero], 1, function(engine:Engine) {
            called = true;
            Assert.isTrue(engine.isWin(0));
        });
        Assert.isTrue(called);
        Rand.endDebug();
    }

    public static function createEasyDungeon(depth):Dungeon {
        return createDungeon(depth, {attack:0, block:0, speed:0, health:0});
    }

    public static function createExtreamDungeon(depth):Dungeon {
        var max:Parameter = {
            attack:Hero.EFFORT_LIMIT,
            block:0,
            speed:Hero.EFFORT_LIMIT,
            health:0
        };
        return createDungeon(depth, max);
    }

    static function createDungeon(depth, effort):Dungeon {
        var s = [HeroTest.createSkill()];
        var enemies:Array<Dungeon.DungeonEnemy> = [
            {name:'_RAND_', color:Color.SUN, plan:Plan.MONKEY, effort:effort, skills:s}
        ];
        var lot:Dungeon.DungeonLot = {
            enemies:enemies,
            rate:1,
        };
        return new Dungeon(1, 1, '', '', depth, '', '', [lot, lot], ['enemy'], enemies);
    }
    
    function isWin(result:BattleResult):Bool {
        var engine = new Engine(result.teamRed, result.teamBlue);
        for (turn in result.turns) {
            engine.applyNewTurn();
            for (act in turn) {
                engine.applyAction(act);
            }
        }
        return engine.isWin(0);
    }

}
