package away3d.loaders
{
    import away3d.core.*;
    import away3d.core.proto.*;
    import away3d.core.geom.*;
    import away3d.core.material.*;

    import flash.display.BitmapData;
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
    
        public static function xml(data:*):XML
        {
            if (data is Class)
                data = new data;

            if (data is XML)
                return data;

            return XML(data);
        }
    
        public static function bitmap(data:*):BitmapData
        {
            if (data is Class)
                data = new data;

            if (data is BitmapData)
                return data;

            // if (data is BitmapAsset)
            if (data.bitmapData) 
                return data.bitmapData;

            return null;
        }

        public static function material(data:*):IMaterial
        {
            if (data is Class)
                data = new data;

            if (data is IMaterial)
                return data;

            if (data is BitmapData)
                return new BitmapMaterial(data, {smooth:true});

            // if (data is BitmapAsset)
            if (data.bitmapData) 
                return new BitmapMaterial(data.bitmapData, {smooth:true});

            return null;
        }

        public static function library(data:*):MaterialLibrary
        {
            if (data == null)
                return new MaterialLibrary();

            if (data is Class)
                data = new data;

            if (data is MaterialLibrary)
                return data;

            var result:MaterialLibrary = new MaterialLibrary();
            for (var name:String in data)
                result.add(Cast.material(data[name]), name);

            return result;
        }

    }
}
