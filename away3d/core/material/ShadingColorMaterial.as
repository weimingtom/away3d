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

    public class ShadingColorMaterial extends CenterLightingMaterial
    {
        public var ambient:int;
        public var diffuse:int;
        public var specular:int;

        public function ShadingColorMaterial(ambient:int, diffuse:int, specular:int, init:Object = null)
        {
            super(init);

            this.ambient = ambient;
            this.diffuse = diffuse;
            this.specular = specular;
        }

        public override function renderTri(tri:DrawTriangle, session:RenderSession, kar:Number, kag:Number, kab:Number, kdr:Number, kdg:Number, kdb:Number, ksr:Number, ksg:Number, ksb:Number):void
        {
            var v0:Vertex2D = tri.v0;
            var v1:Vertex2D = tri.v1;
            var v2:Vertex2D = tri.v2;

            var fr:int = int(((ambient & 0xFF0000) * kar + (diffuse & 0xFF0000) * kdr + (specular & 0xFF0000) * ksr) >> 16);
            var fg:int = int(((ambient & 0x00FF00) * kag + (diffuse & 0x00FF00) * kdg + (specular & 0x00FF00) * ksg) >> 8);
            var fb:int = int(((ambient & 0x0000FF) * kab + (diffuse & 0x0000FF) * kdb + (specular & 0x0000FF) * ksb));

            if (fr > 0xFF)
                fr = 0xFF;
            if (fg > 0xFF)
                fg = 0xFF;
            if (fb > 0xFF)
                fb = 0xFF;

            var color:int = int(fr*0x10000) + int(fg*0x100) + fb;

            RenderTriangle.renderColor(session.graphics, color, 1, v0.x, v0.y, v1.x, v1.y, v2.x, v2.y);
        }

        public override function get visible():Boolean
        {
            return true;
        }
 
    }
}
