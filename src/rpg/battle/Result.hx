package rpg.battle;

import haxe.ds.IntMap;

typedef BattleResult = {
    teamRed: Array<Hero>,
    teamBlue: Array<Hero>,
    turns : Array<Turn>,
}

typedef Turn =  Array<Action>;

typedef Action = {
    actor  : Int,
    target : Int,
    skill  : Int,
    effect : Int,
}
