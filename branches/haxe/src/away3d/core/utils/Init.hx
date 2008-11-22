package away3d.core.utils;

    import away3d.arcane;
    import away3d.core.base.*;
    import away3d.core.math.*;
    import away3d.materials.*;
    import away3d.primitives.data.*;
    
    import flash.display.BitmapData;

	use namespace arcane;
	
    /** Convinient object initialization support */
    class Init
     {
		/** @private */
        
		/** @private */
        arcane var init:Dynamic;

        public function new(init:Dynamic)
        {
            this.init = init;
        }

        public static function parse(init:Dynamic):Init
        {
            if (init == null)
                return new Init(null);
            if (Std.is( init, Init))
                return cast( init, Init);

            inits.push(init);
            return new Init(init);
        }

        public function getInt(name:String, def:Int, ?bounds:Dynamic = null):Int
        {
            if (init == null)
                return def;
        
            if (!init.hasOwnProperty(name))
                return def;
        
            var result:Int = init[name];

            if (bounds != null)
            {
                if (bounds.hasOwnProperty("min"))
                {
                    var min:Int = bounds["min"];
                    if (result < min)
                        result = min;
                }
                if (bounds.hasOwnProperty("max"))
                {
                    var max:Int = bounds["max"];
                    if (result > max)
                        result = max;
                }
            }
        
            Reflect.deleteField(init, name);
        
            return result;
        }

        public function getNumber(name:String, def:Float, ?bounds:Dynamic = null):Float
        {
            if (init == null)
                return def;
        
            if (!init.hasOwnProperty(name))
                return def;
        
            var result:Int = init[name];
                                        
            if (bounds != null)
            {
                if (bounds.hasOwnProperty("min"))
                {
                    var min:Int = bounds["min"];
                    if (result < min)
                        result = min;
                }
                if (bounds.hasOwnProperty("max"))
                {
                    var max:Int = bounds["max"];
                    if (result > max)
                        result = max;
                }
            }
        
            Reflect.deleteField(init, name);
        
            return result;
        }

        public function getString(name:String, def:String):String
        {
            if (init == null)
                return def;
        
            if (!init.hasOwnProperty(name))
                return def;
        
            var result:String = init[name];

            Reflect.deleteField(init, name);
        
            return result;
        }

        public function getBoolean(name:String, def:Bool):Bool
        {
            if (init == null)
                return def;
        
            if (!init.hasOwnProperty(name))
                return def;
        
            var result:Bool = init[name];

            Reflect.deleteField(init, name);
        
            return result;
        }

        public function getObject(name:String, ?type:Class = null):Dynamic
        {
            if (init == null)
                return null;
        
            if (!init.hasOwnProperty(name))
                return null;
        
            var result:Dynamic = init[name];

            Reflect.deleteField(init, name);

            if (result == null)
                return null;

            if (type != null)
                if (!(Std.is( result, type)))
                    throw new CastError("Parameter \""+name+"\" is not of class "+type+": "+result);

            return result;
        }

        public function getObjectOrInit(name:String, ?type:Class = null):Dynamic
        {
            if (init == null)
                return null;
        
            if (!init.hasOwnProperty(name))
                return null;
        
            var result:Dynamic = init[name];

            Reflect.deleteField(init, name);

            if (result == null)
                return null;

            if (type != null)
                if (!(Std.is( result, type)))
                    return new type(result);

            return result;
        }

        public function getObject3D(name:String):Object3D
        {
            return cast( getObject(name, Object3D), Object3D);
        }

        public function getNumber3D(name:String):Number3D
        {
            return cast( getObject(name, Number3D), Number3D);
        }

        public function getPosition(name:String):Number3D
        {
            var value:Dynamic = getObject(name);

            if (value == null)
                return null;

            if (Std.is( value, Number3D))
                return cast( value, Number3D);

            if (Std.is( value, Object3D))
            {
                var o:Object3D = cast( value, Object3D);
                return o.scene ? o.scenePosition : o.position;
            }

            if (Std.is( value, String))
                if (value == "center")
                    return new Number3D();

            throw new CastError("Cast get position of "+value);
        }

        public function getArray(name:String):Array<Dynamic>
        {
            if (init == null)
                return [];
        
            if (!init.hasOwnProperty(name))
                return [];
        
            var result:Array<Dynamic> = init[name];

            Reflect.deleteField(init, name);
        
            return result;
        }

        public function getInit(name:String):Init
        {
            if (init == null)
                return new Init(null);
        
            if (!init.hasOwnProperty(name))
                return new Init(null);
        
            var result:Init = Init.parse(init[name]);

            Reflect.deleteField(init, name);
        
            return result;
        }
		
        public function getCubeMaterials(name:String):CubeMaterialsData
        {
            if (init == null)
                return null;
        
            if (!init.hasOwnProperty(name))
                return null;
        	
        	var result:CubeMaterialsData;
        	
        	if (Std.is( init[name], CubeMaterialsData))
        		result = cast( init[name], CubeMaterialsData);
        	else if (Std.is( init[name], Object))
        		result = new CubeMaterialsData(init[name]);

            Reflect.deleteField(init, name);
        
            return result;
        }
        
        public function getColor(name:String, def:UInt):UInt
        {
            if (init == null)
                return def;
        
            if (!init.hasOwnProperty(name))
                return def;
        
            var result:UInt = Cast.color(init[name]);

            Reflect.deleteField(init, name);
        
            return result;
        }

        public function getBitmap(name:String):BitmapData
        {
            if (init == null)
                return null;
        
            if (!init.hasOwnProperty(name))
                return null;
        
            var result:BitmapData = Cast.bitmap(init[name]);

            Reflect.deleteField(init, name);
        
            return result;
        }

        public function getMaterial(name:String):ITriangleMaterial
        {
            if (init == null)
                return null;
        
            if (!init.hasOwnProperty(name))
                return null;
        
            var result:ITriangleMaterial = Cast.material(init[name]);

            Reflect.deleteField(init, name);
        
            return result;
        }

        public function getSegmentMaterial(name:String):ISegmentMaterial
        {
            if (init == null)
                return null;
        
            if (!init.hasOwnProperty(name))
                return null;
        
            var result:ISegmentMaterial = Cast.wirematerial(init[name]);

            Reflect.deleteField(init, name);
        
            return result;
        }

        static var inits:Array<Dynamic> = [];

        arcane function removeFromCheck():Void
        {
            if (init == null)
                return;

            init["dontCheckUnused"] = true;
        }

        arcane function addForCheck():Void
        {
            if (init == null)
                return;

            init["dontCheckUnused"] = false;
            inits.push(init);
        }

        arcane static function checkUnusedArguments():Void
        {
            if (inits.length == 0)
                return;

            var list:Array<Dynamic> = inits;
            inits = [];
            for (init in list)
            {
                if (init.hasOwnProperty("dontCheckUnused"))
                    if (init["dontCheckUnused"])
                        continue;
                        
                var s:String = null;
                for (var name:String in init)
                {
                    if (name == "dontCheckUnused")
                        continue;

                    if (s == null)
                        s = "";
                    else
                        s +=", ";
                    s += name+":"+init[name];
                }
                if (s != null)
                {
                    Debug.warning("Unused arguments: {"+s+"}");
                }
            }
        }
    }
