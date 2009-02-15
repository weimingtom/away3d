package
{
    import flash.display.*;
    import flash.events.*;
    import flash.text.*;
    import flash.utils.*;

    import mx.core.BitmapAsset;
    
    import away3d.containers.*;
    import away3d.cameras.*;
    import away3d.test.*;
    import away3d.arcane;
    import away3d.core.draw.*;
    import away3d.core.render.*;
    import away3d.materials.*;
    import away3d.loaders.*;
    import away3d.primitives.*;
    
    [SWF(backgroundColor="#222266", frameRate="60")]
    public class Skybox6Test extends BaseDemo
    {
    	public var session:SpriteRenderSession = new SpriteRenderSession();
    	
        public function Skybox6Test()
        {
            super("Peter Kapelyan's skyboxes");

            camera.mintiltangle = -70;
            camera.targettiltangle = -10;
            camera.targetpanangle = -80;

            addSlide("Skybox #1", 
"Skybox textures by Peter Kapelyan\n"+
"One image is mapped on inner faces of cube.\n"+
"All skyboxes use precise bitmap texture with 4 pixel precision without smoothing.\n"+
"<b>[CTRL]</b> to hide gui\n",
            new Scene3D(new PreciseSkybox(1, 4, false)), 
            Renderer.BASIC, session);

            addSlide("Skybox #2", 
"",
            new Scene3D(new PreciseSkybox(2, 4, false)), 
            Renderer.BASIC, session);

            addSlide("Skybox #4", 
"Some faces are one pixel short.",
            new Scene3D(new PreciseSkybox(4, 4, false)), 
            Renderer.BASIC, session);

            addSlide("Skybox #5", 
"Back face seems to be overblurred comparing to other side faces.",
            new Scene3D(new PreciseSkybox(5, 4, false)), 
            Renderer.BASIC, session);

            addSlide("Skybox #3", 
"Some inconsistency in bottom face.",
            new Scene3D(new PreciseSkybox(3, 4, false)), 
            Renderer.BASIC, session);

        }
    }
}

    import flash.display.*;
    import flash.events.*;
    import flash.text.*;
    import flash.utils.*;
    import flash.geom.*;

    import mx.core.BitmapAsset;
    
    import away3d.containers.*;
    import away3d.cameras.*;
    import away3d.test.*;
    import away3d.arcane;
    import away3d.core.draw.*;
    import away3d.core.render.*;
    import away3d.materials.*;
    import away3d.loaders.*;
    import away3d.primitives.*;

class Asset
{
    [Embed(source="images/peterskybox1.jpg")]
    public static var Skybox1Image:Class;

    public static function get skybox1():BitmapData
    {
        return (new Skybox1Image as BitmapAsset).bitmapData;
    }

    [Embed(source="images/peterskybox2.jpg")]
    public static var Skybox2Image:Class;

    public static function get skybox2():BitmapData
    {
        return (new Skybox2Image as BitmapAsset).bitmapData;
    }

    [Embed(source="images/peterskybox3.jpg")]
    public static var Skybox3Image:Class;

    public static function get skybox3():BitmapData
    {
        return (new Skybox3Image as BitmapAsset).bitmapData;
    }

    [Embed(source="images/peterskybox4.jpg")]
    public static var Skybox4Image:Class;

    public static function get skybox4():BitmapData
    {
        return (new Skybox4Image as BitmapAsset).bitmapData;
    }

    [Embed(source="images/peterskybox5.jpg")]
    public static var Skybox5Image:Class;

    public static function get skybox5():BitmapData
    {
        return (new Skybox5Image as BitmapAsset).bitmapData;
    }

    public static var skyboxes:Array = [skybox1, skybox2, skybox3, skybox4, skybox5];
}

class PreciseSkybox extends ObjectContainer3D
{
    public var skybox:Skybox6;
                       
    public function PreciseSkybox(n:int, precision:Number, smooth:Boolean = false)
    {
        skybox = new Skybox6(new BitmapMaterial(Asset.skyboxes[n-1], {precision:precision, smooth:smooth}));

        super(null, skybox);
    }
    
}

