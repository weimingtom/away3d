package away3d.core
{
    import away3d.core.scene.*;
    import away3d.core.mesh.*;
    import away3d.core.material.*;
    import away3d.loaders.*;

    import flash.display.BitmapData;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    //import mx.core.BitmapAsset;

    /** Helper class for casting assets to usable objects */
    public class Cast
    {
        public static function string(data:*):String
        {
            if (data is Class)
                data = new data;

            if (data is String)
                return data;

            return String(data);
        }
    
        public static function bytearray(data:*):ByteArray
        {
            if (data is Class)
                data = new data;

            if (data is ByteArray)
                return data;

            return ByteArray(data);
        }
    
        public static function xml(data:*):XML
        {
            if (data is Class)
                data = new data;

            if (data is XML)
                return data;

            return XML(data);
        }
    
        private static var colornames:Dictionary;

        public static function color(data:*):uint
        {
            if (data is uint)
                return data as uint;

            if (data is int)
                return data as uint;

            if (data is String)
            {
                if (data == "random")
                    return uint(Math.random()*0x1000000);
            
                if (colornames == null)
                {
                    colornames = new Dictionary();
                    colornames["black"]  = 0x000000;
                    colornames["white"]  = 0xFFFFFF;
                    colornames["grey"]   = 0x808080;
                    colornames["red"]    = 0xFF0000;
                    colornames["green"]  = 0x00FF00;
                    colornames["blue"]   = 0x0000FF;
                    colornames["yellow"] = 0xFFFF00;
                    colornames["cyan"]   = 0x00FFFF;
                    colornames["purple"] = 0xFF00FF;
                    colornames["transparent"] = 0xFF000000;
                }
            
                if (colornames[data] != null)
                    return colornames[data];
            
                //throw new Error(data+" "+parseInt("0x"+data));
                if (data.length == 6)
                    return parseInt("0x"+data);
            }

            throw new Error("Can't cast to color: "+data);
        }

        public static function bitmap(data:*):BitmapData
        {
            if (data == null)
                return null;

            if (data is Class)
                data = new data;

            if (data is BitmapData)
                return data;

            // if (data is BitmapAsset)
            if (data.bitmapData) 
                return data.bitmapData;

            throw new Error("Can't cast to bitmap: "+data);
        }

        public static function material(data:*):IMaterial
        {
            if (data == null)
                return null;

            if (data is Class)
                data = new data;

            if (data is IMaterial)
                return data;

            if (data is int) 
                return new ColorMaterial(data);

            if (data is String) 
            {
                if (data == "")
                    return null;

                if (data == "transparent")
                    return new TransparentMaterial();

                if (data.indexOf("#") == -1)
                    return new ColorMaterial(color(data));
                else
                {
                    if (data == "#")
                        return new WireframeMaterial();

                    var hash:Array = data.split("#");
                    if (hash[1] == "")
                        return new WireColorMaterial(color(hash[0]));

                    if (hash[1].indexOf("|") == -1)
                    {
                        if (hash[0] == "")
                            return new WireframeMaterial(color(hash[1]));
                        else
                            return new WireColorMaterial(color(hash[0]), color(hash[1]));
                    }
                    else
                    {
                        var line:Array = hash[1].split("|");
                        if (hash[0] == "")
                            //throw new Error(line[0]+" <-> "+line[1]); 
                            return new WireframeMaterial(color(line[0]), 1, parseFloat(line[1]));
                        else
                            return new WireColorMaterial(color(hash[0]), color(line[0]), 1, 1, parseFloat(line[1]));
                    }
                }
            }

            if (data is BitmapData)
                return new BitmapMaterial(data, {smooth:true});

            // if (data is BitmapAsset)
            if (data.bitmapData) 
                return new BitmapMaterial(data.bitmapData, {smooth:true});

            throw new Error("Can't cast to material: "+data);
        }

        public static function library(data:*):MaterialLibrary
        {
            if (data == null)
                return new MaterialLibrary();

            if (data is Class)
                data = new data;

            if (data is MaterialLibrary)
                return data;

            /*
            if (data is IMaterial)
                return new MaterialLibrary(data);

            if (data is BitmapData)
                return new MaterialLibrary(new BitmapMaterial(data, {smooth:true}));

            // if (data is BitmapAsset)
            if (data.bitmapData) 
                return new MaterialLibrary(new BitmapMaterial(data.bitmapData, {smooth:true}));
            */

            var result:MaterialLibrary = new MaterialLibrary();
            for (var name:String in data)
                result.add(Cast.material(data[name]), name);

            return result;
        }

    }
}
