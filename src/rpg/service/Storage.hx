package rpg.service;

interface Storage {

    function get(key:String):Null<Dynamic>;
    function set(key:String, value:Dynamic):Void;

}
