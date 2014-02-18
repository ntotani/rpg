package rpg.battle;

import massive.munit.Assert;
import rpg.battle.Result;

class EngineTest {

    @Test
    public function testInitHeros():Void {
        var engine:Engine = this.createEngine();
        engine.applyNewTurn();
        engine.applyAction({actor:1, target:0, skill:0, effect:1});
        var result:BattleResult = engine.getResult();
        Assert.isTrue(result.teamRed[0].getHp() > engine.getHero(0).getHp());
    }

    @Test
    public function testSolveOrder():Void {
        var engine:Engine = this.createEngine();
        var order:Array<Int> = engine.solveOrder([]);
        Assert.areEqual([0, 1].toString(), order.toString());
    }
    
    @Test
    public function testCalcDamage():Void {
        var engine:Engine = this.createEngine();
        var max:BattleHero = engine.getHero(0);
        var min:BattleHero = engine.getHero(1);
        var max2min:Int = Engine.calcDamage(max, min, max.getHero().getSkill(0));
        var min2max:Int = Engine.calcDamage(min, max, min.getHero().getSkill(0));
        Assert.isTrue(max2min >= min2max);
    }
    
    @Test
    public function testAction():Void {
        var engine:Engine = createEngine();
        var cmd:Engine.Command = {actor:0, target:1, skill:0}
        var act:Action = engine.action(cmd);
        Assert.isTrue(act.effect > 0);
        var currentHp:Int = engine.getHero(1).getHp();
        var maxHp:Int = engine.getHero(1).getHero().getParameter().health;
        Assert.isTrue(currentHp == maxHp);
    }
    
    @Test
    public function testActionZero():Void {
        var engine:Engine = this.createEngine();
        var cmd:Engine.Command = {actor:1, target:0, skill:0}
        var act:Action = engine.action(cmd);
        Assert.isTrue(act.effect > 0);
        var currentHp:Int = engine.getHero(0).getHp();
        var maxHp:Int = engine.getHero(0).getHero().getParameter().health;
        Assert.isTrue(currentHp == maxHp);
    }

    @Test
    public function testActionDeadActor():Void {
        var engine:Engine = this.createEngine();
        engine.getHero(0).damage(1000);
        var cmd:Engine.Command = {actor:0, target:1, skill:0}
        var act:Action = engine.action(cmd);
        Assert.areEqual(0, act.effect);
    }

    @Test
    public function testActionDeadTarget():Void {
        var engine:Engine = this.createEngine();
        engine.getHero(1).damage(1000);
        var cmd:Engine.Command = {actor:0, target:1, skill:0}
        var act:Action = engine.action(cmd);
        Assert.areEqual(0, act.effect);
    }

    @Test
    public function testIsFinish():Void {
        var engine:Engine = this.createEngine();
        Assert.isFalse(engine.isFinish());
        engine.getHero(1).damage(1000);
        Assert.isTrue(engine.isWin(0));
        Assert.isTrue(engine.isFinish());
    }

    @Test
    public function testExecute():Void {
        var engine:Engine = this.createEngine();
        var expected:Turn = [{
                actor:0,
                target:1,
                skill:0,
                effect:14,
        }];
        var friendRequest:RequestEqual = new RequestEqual([{actor:0, target:1, skill:0}], expected);
        engine.execute(friendRequest);
        engine.execute(new RequestImpl([{actor:1, target:0, skill:0}]));
        Assert.isTrue(engine.getHero(0).getHp() < engine.getHero(0).getHero().getParameter().health);
        Assert.isTrue(engine.getHero(1).getHp() < engine.getHero(1).getHero().getParameter().health);
    }

    @Test
    public function testExecuteRepeat():Void {
        var engine:Engine = this.createEngine();
        var req:RequestRepeat = new RequestRepeat([], engine);
        req.next();
    }

    @Test
    public function testRecordAndPlay():Void {
        var engine1:Engine = this.createEngine();
        var req:RequestRepeat = new RequestRepeat([], engine1);
        req.next();
        var result1:BattleResult = engine1.getResult();
        var engine2:Engine = new Engine(result1.teamRed, result1.teamBlue);
        for (turn in result1.turns) {
            engine2.applyNewTurn();
            for (act in turn) {
                engine2.applyAction(act);
            }
        }
        var result2:BattleResult = engine2.getResult();
        Assert.areEqual(Std.string(result1), Std.string(result2));
    }

    function createEngine():Engine {
        var red:Hero = HeroTest.createMaxHero();
        var blue:Hero = HeroTest.createMinHero();
        return new Engine([red], [blue]);
    }

}

class RequestImpl implements Engine.Request {

    var commands:Array<Engine.Command>;
    
    public function new(commands:Array<Engine.Command>) {
        this.commands = commands;
    }

    public function getCommands():Iterable<Engine.Command> {
        return this.commands;
    }

    public function callback(turn:Turn, finish:Bool):Void {
    }

}

class RequestEqual extends RequestImpl {

    var turn:Turn;

    public function new(commands:Array<Engine.Command>, turn:Turn) {
        super(commands);
        this.turn = turn;
    }

    public override function callback(turn:Turn, finish:Bool):Void {
        //Assert.areEqual(Std.string(this.result), Std.string(res));
        Assert.areEqual(0, turn[0].actor);
        Assert.areEqual(1, turn[1].actor);
    }

}

class RequestRepeat extends RequestImpl {

    var engine:Engine;

    public function new(commands:Array<Engine.Command>, engine:Engine) {
        super(commands);
        this.engine = engine;
    }

    public override function callback(turn:Turn, finish:Bool):Void {
        if (!finish) {
            this.next();
        } else {
            Assert.areEqual(0, this.engine.getHero(1).getHp());
        }
    }
    
    public function next():Void {
        this.engine.execute(new RequestRepeat([{actor:0, target:1, skill:0}], this.engine));
        this.engine.execute(new RequestRepeat([{actor:1, target:0, skill:0}], this.engine));
    }

}
