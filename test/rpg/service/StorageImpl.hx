package rpg.service;

import haxe.ds.IntMap;
import rpg.service.HeroService;
import rpg.service.DungeonService;

class StorageImpl implements Storage {

    var heros:Array<StoredHero>;
    var team:Array<String>;
    var dungeonResults:IntMap<StoredDungeonResult>;
    var latest:Int;

    public function new() {
        heros = [];
        team = [];
        dungeonResults = new IntMap<StoredDungeonResult>();
        latest = 0;
    }

    public function getHeros():Array<StoredHero> {
        return heros;
    }

    public function setHeros(heros:Array<StoredHero>) {
        this.heros = heros;
    }

    public function getTeam():Array<String> {
        return team;
    }

    public function setTeam(team:Array<String>) {
        this.team = team;
    }

    public function getLatestDungeonResult():StoredDungeonResult {
        return dungeonResults.get(latest);
    }

    public function setDungeonResult(now:Int, result:StoredDungeonResult) {
        dungeonResults.set(now, result);
        latest = now;
    }

}
