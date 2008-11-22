package away3d.core.utils;


    /** Static helper class for color manipulations */
    class Color 
     {
        
        inline public static var white:Int = 0xFFFFFF;
        inline public static var black:Int = 0x000000;
        inline public static var red:Int = 0xFF0000;
        inline public static var green:Int = 0x00FF00;
        inline public static var blue:Int = 0x0000FF;
        inline public static var yellow:Int = 0xFFFF00;
        inline public static var cyan:Int = 0x00FFFF;
        inline public static var purple:Int = 0xFF00FF;

        public static function multiply(color:Int, k:Float):Int
        {
            var r:Int = color & 0xFF0000 >> 16;
            var g:Int = color & 0xFF00 >> 8;
            var b:Int = color & 0xFF;

            return fromIntsCheck(int(r*k), int(g*k), int(b*k));
        }

        public static function add(colora:Int, colorb:Int):Int
        {
            var ra:Int = colora & 0xFF0000 >> 16;
            var ga:Int = colora & 0xFF00 >> 8;
            var ba:Int = colora & 0xFF;

            var rb:Int = colorb & 0xFF0000 >> 16;
            var gb:Int = colorb & 0xFF00 >> 8;
            var bb:Int = colorb & 0xFF;

            return fromIntsCheck(ra+rb, ga+gb, ba+bb);
        }

        public static function inverseAdd(colora:Int, colorb:Int):Int
        {
            var ra:Int = 255 - colora & 0xFF0000 >> 16;
            var ga:Int = 255 - colora & 0xFF00 >> 8;
            var ba:Int = 255 - colora & 0xFF;

            var rb:Int = 255 - colorb & 0xFF0000 >> 16;
            var gb:Int = 255 - colorb & 0xFF00 >> 8;
            var bb:Int = 255 - colorb & 0xFF;

            return fromIntsCheck(255 - (ra+rb), 255 - (ga+gb), 255 - (ba+bb));
        }

        public static function fromHSV(hue:Float, saturation:Float, value:Float):Int
        {
            var h:Int = ((hue % 360) + 360) % 360;
            var s:Int = saturation;
            var v:Int = value;
            var hi:Int = int(h / 60) % 6;
            var f:Int = h / 60 - hi;
            var p:Int = v * (1 - s);
            var q:Int = v * (1 - f*s);
            var t:Int = v * (1 - (1 - f)*s);
            switch (hi)
            {
                case 0: return fromFloats(v, t, p); break;
                case 1: return fromFloats(q, v, p); break;
                case 2: return fromFloats(p, v, t); break;
                case 3: return fromFloats(p, q, v); break;
                case 4: return fromFloats(t, p, v); break;
                case 5: return fromFloats(v, p, q); break;
            }
            return 0;
        }

        public static function fromFloats(red:Float, green:Float, blue:Float):Int
        {
            return 0x10000*int(red*0xFF) + 0x100*int(green*0xFF) + int(blue*0xFF);
        }

        public static function fromInts(red:Int, green:Int, blue:Int):Int
        {
            return 0x10000*red + 0x100*green + blue;
        }

        public static function fromIntsCheck(red:Int, green:Int, blue:Int):Int
        {
            red = Math.max(0, Math.min(255, red));
            green = Math.max(0, Math.min(255, green));
            blue = Math.max(0, Math.min(255, blue));
            return 0x10000*red + 0x100*green + blue;
        }
    }
