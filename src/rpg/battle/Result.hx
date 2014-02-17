package rpg.battle;

import haxe.ds.IntMap;

typedef BattleResult = {
    heros : IntMap<BattleHero>,
    turns : Array<Turn>,
}

typedef Turn =  Array<Action>;

typedef Action = {
    actor  : Int,
    target : Int,
    skill  : Int,
    effect : Int,
}
