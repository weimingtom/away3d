package
{
    import flash.display.*;
    import flash.events.*;
    import flash.text.*;
    import flash.utils.*;

    import mx.core.BitmapAsset;
    
    import away3d.cameras.*;
    import away3d.objects.*;
    import away3d.loaders.*;
    import away3d.test.*;
    import away3d.core.*;
    import away3d.core.material.*;
    import away3d.core.render.*;
    import away3d.core.proto.*;
    import away3d.core.geom.*;
    import away3d.core.draw.*;
    
    [SWF(backgroundColor="#222266", frameRate="60", width="800", height="600")]
    public class SculptTest extends BaseDemo
    {
        public function SculptTest()
        {
            super("Sculpt demo");
                        
            camera.mintiltangle = -70;

            addSlide("Sculpting", 
"",
            new Scene3D(new Sculp(4)), 
            new BasicRenderer());
            //new QuadrantRenderer(new AnotherRivalFilter));

        }
    }
}

    import flash.display.*;
    import flash.events.*;
    import flash.text.*;
    import flash.utils.*;
    import flash.geom.*;

    import mx.core.BitmapAsset;
    
    import away3d.cameras.*;
    import away3d.objects.*;
    import away3d.loaders.*;
    import away3d.core.*;
    import away3d.core.render.*;
    import away3d.core.proto.*;
    import away3d.core.geom.*;
    import away3d.core.draw.*;
    import away3d.core.material.*;

class Asset
{
}

class Sculp extends ObjectContainer3D
{
    public var light1:Light3D;
    public var light2:Light3D;
    public var light3:Light3D;
    public var light4:Light3D;
                       
    public function Sculp(n:int = 1)
    {
        light1 = new Light3D(0xFFFFFF, 1, 1, 0, {x:900, z:900, y:900});
        light2 = new Light3D(0x555500, 1, 1, 0, {x:-900, z:900, y:900});
        light3 = new Light3D(0x999999, 1, 1, 0, {x:900, z:-900, y:900});
        light4 = new Light3D(0xFFFFFF, 1, 1, 0, {x:-900, z:-900, y:900});

        super(light1, light2, light3, light4);

        build(n);
    }

    public function build(n:int):void
    {
        var white:IMaterial = new ColorShadingBitmapMaterial(0xFFFFFF, 0xFFFFFF, 0xFFFFFF, {alpha:20});
        var i:int;
        var j:int;
        var h:int;
        var vertices:Array = new Array();
        for (i = 0; i <= n; i++)
        {
            vertices[i] = new Array();
            for (j = 0; j <= n; j++)
            {
                vertices[i][j] = new Array();
                for (h = 0; h <= n; h++)
                    vertices[i][j][h] = new Vertex3D(i/n*1000-500, j/n*1000-500, h/n*1000-500);
            }
        }

        var centers:Array = new Array();
        for (i = 0; i < n; i++)
        {
            centers[i] = new Array();
            for (j = 0; j < n; j++)
            {
                centers[i][j] = new Array();
                for (h = 0; h < n; h++)
                    centers[i][j][h] = new Vertex3D((i+0.5)/n*1000-500, (j+0.5)/n*1000-500, (h+0.5)/n*1000-500);
            }
        }

        var meshes:Array = new Array();
        for (i = 0; i < n; i++)
        {
            meshes[i] = new Array();
            for (j = 0; j < n; j++)
            {
                meshes[i][j] = new Array();
                for (h = 0; h < n; h++)
                {
                    meshes[i][j][h] = new Array();
                    //meshes[i][j][h]["i+"] = new Pyramid(white, centers[i][j][h], vertices[i+1][j][h], vertices[i+1][j+1][h], vertices[i+1][j+1][h+1], vertices[i+1][j][h+1], {parent:this});
                    //meshes[i][j][h]["i-"] = new Pyramid(white, centers[i][j][h], vertices[i][j][h], vertices[i][j][h+1], vertices[i][j+1][h+1], vertices[i][j+1][h], {parent:this});
//                    meshes[i][j][h]["j+"] = new Pyramid(white, centers[i][j][h], vertices[i][j+1][h], vertices[i][j+1][h+1], vertices[i+1][j+1][h+1], vertices[i+1][j+1][h], {parent:this});
//                    meshes[i][j][h]["j-"] = new Pyramid(white, centers[i][j][h], vertices[i][j][h], vertices[i+1][j][h], vertices[i+1][j][h+1], vertices[i][j][h+1], {parent:this});
                    meshes[i][j][h]["h+"] = new Pyramid(white, centers[i][j][h+1], vertices[i][j][h+1], vertices[i+1][j][h+1], vertices[i+1][j][h+1], vertices[i][j][h+1], {parent:this});
                }
            }
        }

    }
    
}

class Pyramid extends Mesh3D
{
    public function Pyramid(material:IMaterial, top:Vertex3D, a:Vertex3D, b:Vertex3D, c:Vertex3D, d:Vertex3D, init:Object = null)
    {
        super(material, init);

        faces.push(new Face3D(a, d, c));
        faces.push(new Face3D(c, b, a));
        faces.push(new Face3D(top, a, b));
        faces.push(new Face3D(top, b, c));
        faces.push(new Face3D(top, c, d));
        faces.push(new Face3D(top, d, a));
    }
}
