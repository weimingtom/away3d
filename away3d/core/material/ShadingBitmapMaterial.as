package away3d.core.material
{
    import away3d.core.*;
    import away3d.core.geom.*;
    import away3d.core.math.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;

    import flash.display.Graphics;
    import flash.display.BitmapData;
    import flash.geom.Matrix;
    import flash.geom.Point;

    import mx.core.BitmapAsset;

    public class ShadingBitmapMaterial extends CenterLightingMaterial implements IUVMaterial
    {
        public var ambient:BitmapData;
        public var diffuse:BitmapData;
        public var specular:BitmapData;
        public var smooth:Boolean;

        protected var _width:int;
        protected var _height:int;

        protected var aminred:int = 255;
        protected var amaxred:int = 0;
        protected var amingreen:int = 255;
        protected var amaxgreen:int = 0;
        protected var aminblue:int = 255;
        protected var amaxblue:int = 0;

        protected var dminred:int = 255;
        protected var dmaxred:int = 0;
        protected var dmingreen:int = 255;
        protected var dmaxgreen:int = 0;
        protected var dminblue:int = 255;
        protected var dmaxblue:int = 0;

        protected var sminred:int = 255;
        protected var smaxred:int = 0;
        protected var smingreen:int = 255;
        protected var smaxgreen:int = 0;
        protected var sminblue:int = 255;
        protected var smaxblue:int = 0;

        public function get width():Number
        {
            return _width;
        }

        public function get height():Number
        {
            return _height;
        }

        public function ShadingBitmapMaterial(ambient:BitmapData, diffuse:BitmapData, specular:BitmapData, alpha:Number = 20, smooth:Boolean = false)
        {
            super(alpha);
            this.ambient = ambient || diffuse;
            this.diffuse = diffuse || ambient;
            this.specular = specular || diffuse;
            this.smooth = smooth;

            calc();
        }

        protected function calc():void
        {
            _width = ambient.width;
            _height = ambient.height;

            for (var i:int = 0; i < _width; i++)
                for (var j:int = 0; j < _height; j++)
                {
                    var acolor:int = ambient.getPixel(i, j);
                    var ared:int = (acolor & 0xFF0000) >> 16;
                    var agreen:int = (acolor & 0xFF00) >> 8;
                    var ablue:int = (acolor & 0xFF);

                    if (ared > 0)
                    {
                        aminred = Math.min(aminred, ared);
                        amaxred = Math.max(amaxred, ared);
                    }

                    if (agreen > 0)
                    {
                        amingreen = Math.min(amingreen, agreen);
                        amaxgreen = Math.max(amaxgreen, agreen);
                    }

                    if (ablue > 0)
                    {
                        aminblue = Math.min(aminblue, ablue);
                        amaxblue = Math.max(amaxblue, ablue);
                    }

                    var dcolor:int = diffuse.getPixel(i, j);
                    var dred:int = (dcolor & 0xFF0000) >> 16;
                    var dgreen:int = (dcolor & 0xFF00) >> 8;
                    var dblue:int = (dcolor & 0xFF);
                    
                    if (dred > 0)
                    {
                        dminred = Math.min(dminred, dred);
                        dmaxred = Math.max(dmaxred, dred);
                    }
                    
                    if (dgreen > 0)
                    {
                        dmingreen = Math.min(dmingreen, dgreen);
                        dmaxgreen = Math.max(dmaxgreen, dgreen);
                    }
                    
                    if (dblue > 0)
                    {
                        dminblue = Math.min(dminblue, dblue);
                        dmaxblue = Math.max(dmaxblue, dblue);
                    }

                    var scolor:int = specular.getPixel(i, j);
                    var sred:int = (scolor & 0xFF0000) >> 16;
                    var sgreen:int = (scolor & 0xFF00) >> 8;
                    var sblue:int = (scolor & 0xFF);
                    
                    if (sred > 0)
                    {
                        sminred = Math.min(sminred, sred);
                        smaxred = Math.max(smaxred, sred);
                    }
                    
                    if (sgreen > 0)
                    {
                        smingreen = Math.min(smingreen, sgreen);
                        smaxgreen = Math.max(smaxgreen, sgreen);
                    }
                    
                    if (sblue > 0)
                    {
                        sminblue = Math.min(sminblue, sblue);
                        smaxblue = Math.max(smaxblue, sblue);
                    }
                }
        }

        public override function renderTri(tri:DrawTriangle, graphics:Graphics, clip:Clipping, kar:Number, kag:Number, kab:Number, kdr:Number, kdg:Number, kdb:Number, ksr:Number, ksg:Number, ksb:Number):void
        {
            var mapping:Matrix = tri.texturemapping || tri.transformUV(this);
            var v0:Vertex2D = tri.v0;
            var v1:Vertex2D = tri.v1;
            var v2:Vertex2D = tri.v2;
            var bitmap:BitmapData = getBitmap(kar, kag, kab, kdr, kdg, kdb, ksr, ksg, ksb);

            RenderTriangle.renderBitmap(graphics, bitmap, mapping.a, mapping.b, mapping.c, mapping.d, mapping.tx, mapping.ty, v0.x, v0.y, v1.x, v1.y, v2.x, v2.y, smooth);
        }

        public function getBitmap(ar:Number, ag:Number, ab:Number, dr:Number, dg:Number, db:Number, sr:Number, sg:Number, sb:Number):BitmapData
        {
            if (specular == diffuse)
            {
                dr += sr;
                dg += sg;
                db += sb;
                sr = 0;
                sg = 0;
                sb = 0;
            }

            if (diffuse == ambient)
            {
                ar += dr;
                ag += dg;
                ab += db;
                dr = 0;
                dg = 0;
                db = 0;
            }

            if (ar*amaxred < 5)
                ar = 0;
            if (ag*amaxgreen < 5)
                ag = 0;
            if (ab*amaxblue < 5)
                ab = 0;

            if (dr*dmaxred < 5)
                dr = 0;
            if (dg*dmaxgreen < 5)
                dg = 0;
            if (db*dmaxblue < 5)
                db = 0;

            if (sr*smaxred < 5)
                sr = 0;
            if (sg*smaxgreen < 5)
                sg = 0;
            if (sb*smaxblue < 5)
                sb = 0;

            if (1 == 2)
            {
                ar = 0;
                ag = 0;
                ab = 0;
                dr = 0;
                dg = 0;
                db = 0;
                sr *= 3;
                sg *= 3;
                sb *= 3;
            }

            ar = ladder(ar);
            ag = ladder(ag);
            ab = ladder(ab);
            dr = ladder(dr);
            dg = ladder(dg);
            db = ladder(db);
            sr = ladder(sr);
            sg = ladder(sg);
            sb = ladder(sb);

            var result:BitmapData = makeBitmap(ar, ag, ab, dr, dg, db, sr, sg, sb);
            return result;
        }

        public function makeBitmap(ar:Number, ag:Number, ab:Number, dr:Number, dg:Number, db:Number, sr:Number, sg:Number, sb:Number):BitmapData
        {
            var result:BitmapData = new BitmapData(_width, _height);
            var width:int = this.width;
            var height:int = this.height;

            for (var i:int = 0; i < width; i++)
                for (var j:int = 0; j < height; j++)
                {
                    // TODO: use ColorTransform
                    var ac:int = ambient.getPixel(i, j);
                    var dc:int = diffuse == null ? 0 : diffuse.getPixel(i, j);
                    var sc:int = specular == null ? 0 : specular.getPixel(i, j);

                    var fr:int = int(((ac & 0xFF0000) * ar + (dc & 0xFF0000) * dr + (sc & 0xFF0000) * sr) >> 16);
                    var fg:int = int(((ac & 0x00FF00) * ag + (dc & 0x00FF00) * dg + (sc & 0x00FF00) * sg) >> 8);
                    var fb:int = int(((ac & 0x0000FF) * ab + (dc & 0x0000FF) * db + (sc & 0x0000FF) * sb));

                    if (fr > 0xFF)
                        fr = 0xFF;
                    if (fg > 0xFF)
                        fg = 0xFF;
                    if (fb > 0xFF)
                        fb = 0xFF;

                    result.setPixel(i, j, int(fr*0x10000) + int(fg*0x100) + fb);
                }
            return result;
        }

        public override function get visible():Boolean
        {
            return true;
        }
 
        protected static function num(v:Number):Number
        {
            return Math.round(v*1000)/1000;
        }

        protected static function ladder(v:Number):Number
        {
            return v;
        }
    }
}
