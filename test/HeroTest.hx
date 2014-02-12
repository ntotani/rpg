package;

import massive.munit.Assert;

class HeroTest {
    
    @Test
    public function testCalcParameter():Void {
        var hight:Int = Hero.calcParameter(Hero.MAX_TALENT, 0);
        var low:Int = Hero.calcParameter(0, 0);
        Assert.isTrue(hight > low);
    }
    
    @Test
    public function testGetParameterZero():Void {
        var hero:Hero = createZeroHero();
        var actual:Parameter = hero.getParameter();
        Assert.areEqual(1, actual.attack);
    }
    
    @Test
    public function testGetParameterMax():Void {
        var maxHero:Hero = createMaxHero();
        var maxPrm:Parameter = maxHero.getParameter();
        var zeroHero:Hero = createZeroHero();
        var zeroPrm:Parameter = zeroHero.getParameter();
        Assert.isTrue(maxPrm.attack > zeroPrm.attack);
    }

    static var heroId:Int = 0;

    public static function createZeroHero():Hero {
        var paramZero = {attack:0, block:0, speed:0, health:0};
        var id:String = Std.string(heroId++);
        return Hero.create(id, paramZero, paramZero);
    }

    public static function createMaxHero():Hero {
        var paramZero = {attack:0, block:0, speed:0, health:0};
        var paramMax = {
            attack:Hero.MAX_TALENT,
            block:Hero.MAX_TALENT,
            speed:Hero.MAX_TALENT,
            health:Hero.MAX_TALENT,
        };
        var id:String = Std.string(heroId++);
        return Hero.create(id, paramMax, paramZero);
    }

}
