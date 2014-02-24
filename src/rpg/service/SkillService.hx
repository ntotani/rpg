package rpg.service;

import haxe.ds.IntMap;

class SkillService {

    static var master = new IntMap<Skill>();

    public static function get(id:Int):Skill {
        return master.get(id);
    }

    public static function set(id:Int, skill:Skill) {
        master.set(id, skill);
    }

}
