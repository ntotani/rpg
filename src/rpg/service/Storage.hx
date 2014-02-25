package rpg.service;

import rpg.service.HeroService;
import rpg.service.DungeonService;

interface Storage {
    function getHeros():Array<StoredHero>;
    function setHeros(heros:Array<StoredHero>):Void;
    function getTeam():Array<String>;
    function setTeam(team:Array<String>):Void;
    function getLatestDungeonResult():StoredDungeonResult;
    function setDungeonResult(now:Int, result:StoredDungeonResult):Void;
}
