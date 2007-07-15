package away3d.core
{
    import away3d.core.math.*;
    import away3d.core.scene.*;
    import away3d.core.material.*;

    import flash.display.BitmapData;

    /** Convinient object initialization support */
    public class Init
    {
        private var init:Object;

        public function Init(init:Object)
        {
            this.init = init;
        }

        public static function parse(init:Object):Init
        {
            if (init == null)
                return new Init(null);
            if (init is Init)
                return init as Init;

            inits.push(init);
            return new Init(init);
        }

        public function getInt(name:String, def:int, bounds:Object = null):int
        {
            if (init == null)
                return def;
        
            if (!init.hasOwnProperty(name))
                return def;
        
            var result:int = init[name];

            if (bounds != null)
            {
                if (bounds.hasOwnProperty("min"))
                {
                    var min:int = bounds["min"];
                    if (result < min)
                        result = min;
                }
                if (bounds.hasOwnProperty("max"))
                {
                    var max:int = bounds["max"];
                    if (result > max)
                        result = max;
                }
            }
        
            delete init[name];
        
            return result;
        }

        public function getNumber(name:String, def:Number, bounds:Object = null):Number
        {
            if (init == null)
                return def;
        
            if (!init.hasOwnProperty(name))
                return def;
        
            var result:Number = init[name];
                                        
            if (bounds != null)
            {
                if (bounds.hasOwnProperty("min"))
                {
                    var min:Number = bounds["min"];
                    if (result < min)
                        result = min;
                }
                if (bounds.hasOwnProperty("max"))
                {
                    var max:Number = bounds["max"];
                    if (result > max)
                        result = max;
                }
            }
        
            delete init[name];
        
            return result;
        }

        public function getString(name:String, def:String):String
        {
            if (init == null)
                return def;
        
            if (!init.hasOwnProperty(name))
                return def;
        
            var result:String = init[name];

            delete init[name];
        
            return result;
        }

        public function getBoolean(name:String, def:Boolean):Boolean
        {
            if (init == null)
                return def;
        
            if (!init.hasOwnProperty(name))
                return def;
        
            var result:Boolean = init[name];

            delete init[name];
        
            return result;
        }

        public function getObject(name:String, def:Object = null):Object
        {
            if (init == null)
                return def;
        
            if (!init.hasOwnProperty(name))
                return def;
        
            var result:Object = init[name];

            delete init[name];
        
            return result;
        }

        public function getObject3D(name:String):Object3D
        {
            if (init == null)
                return null;
        
            if (!init.hasOwnProperty(name))
                return null;
        
            var result:Object3D = init[name];

            delete init[name];
        
            return result;
        }

        public function getNumber2D(name:String):Number2D
        {
            if (init == null)
                return new Number2D();
        
            if (!init.hasOwnProperty(name))
                return new Number2D();
        
            var result:Number2D = init[name];

            delete init[name];
        
            return result;
        }

        public function getNumber3D(name:String):Number3D
        {
            if (init == null)
                return new Number3D();
        
            if (!init.hasOwnProperty(name))
                return new Number3D();
        
            var result:Number3D = init[name];

            delete init[name];
        
            return result;
        }

        public function getArray(name:String):Array
        {
            if (init == null)
                return [];
        
            if (!init.hasOwnProperty(name))
                return [];
        
            var result:Array = init[name];

            delete init[name];
        
            return result;
        }

        public function getInit(name:String):Init
        {
            if (init == null)
                return new Init(null);
        
            if (!init.hasOwnProperty(name))
                return new Init(null);
        
            var result:Init = Init.parse(init[name]);

            delete init[name];
        
            return result;
        }

        public function getMaterial(name:String):IMaterial
        {
            if (init == null)
                return null;
        
            if (!init.hasOwnProperty(name))
                return null;
        
            var result:IMaterial = Cast.material(init[name]);

            delete init[name];
        
            return result;
        }

        public function getColor(name:String, def:uint):uint
        {
            if (init == null)
                return def;
        
            if (!init.hasOwnProperty(name))
                return def;
        
            var result:uint = Cast.color(init[name]);

            delete init[name];
        
            return result;
        }

        public function getBitmap(name:String):BitmapData
        {
            if (init == null)
                return null;
        
            if (!init.hasOwnProperty(name))
                return null;
        
            var result:BitmapData = Cast.bitmap(init[name]);

            delete init[name];
        
            return result;
        }

        public function getTriangleMaterial(name:String):ITriangleMaterial
        {
            return getMaterial(name) as ITriangleMaterial;
        }

        public function getSegmentMaterial(name:String):ISegmentMaterial
        {
            return getMaterial(name) as ISegmentMaterial;
        }

        private static var inits:Array = [];

        public static function checkUnusedArguments():void
        {
            if (inits.length == 0)
                return;

            var list:Array = inits;
            inits = [];
            for each (var init:Object in list)
            {
                var s:String = null;
                for (var name:String in init)
                {
                    if (s == null)
                        s = "";
                    else
                        s +=", ";
                    s += name+":"+init[name];
                }
                if (s != null)
                {
                    Debug.warning("Unused arguments: {"+s+"}"); // warning
                }
            }
        }
    }
}
