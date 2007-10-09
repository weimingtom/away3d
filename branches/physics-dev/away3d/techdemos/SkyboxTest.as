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
    public class SkyboxTest extends BaseDemo
    {
        public function SkyboxTest()
        {
            super("Skybox test", 160);

            camera.mintiltangle = -70;

            DrawTriangle.test();
            DrawSegment.test();

            addSlide("Skybox #1", 
"Skybox from Half-Life\n"+
            new Scene3D(new SimpleSkybox(0)), 
            new BasicRenderer());

            addSlide("Skybox 768 tri", 
"",
            new Scene3D(new SimpleSkybox(1)), 
            new BasicRenderer());

            addSlide("Skybox 3072 tri", 
"",
            new Scene3D(new SimpleSkybox(2)), 
            new BasicRenderer());

            addSlide("Skybox 7 px precision", 
"",
            new Scene3D(new SmoothSkybox(7)), 
            new BasicRenderer());

            addSlide("Skybox 6 px precision", 
"",
            new Scene3D(new SmoothSkybox(6)), 
            new BasicRenderer());

            addSlide("Skybox 5 px precision", 
"",
            new Scene3D(new SmoothSkybox(5)), 
            new BasicRenderer());

            addSlide("Skybox 4 px precision", 
"",
            new Scene3D(new SmoothSkybox(4)), 
            new BasicRenderer());

            addSlide("Skybox 3 px precision", 
"",
            new Scene3D(new SmoothSkybox(3)), 
            new BasicRenderer());

            addSlide("Skybox 2 px precision", 
"",
            new Scene3D(new SmoothSkybox(2)), 
            new BasicRenderer());

            addSlide("Skybox 1 px precision", 
"",
            new Scene3D(new SmoothSkybox(1)), 
            new BasicRenderer());

            addSlide("Smooth skybox 192 tri", 
"",
            new Scene3D(new SimpleSkybox(0, true)), 
            new BasicRenderer);

            addSlide("Smooth skybox 768 tri", 
"",
            new Scene3D(new SimpleSkybox(1, true)), 
            new BasicRenderer);

            addSlide("Smooth skybox 3072 tri", 
"",
            new Scene3D(new SimpleSkybox(2, true)), 
            new BasicRenderer);

            addSlide("Smooth skybox 7 px precision", 
"",
            new Scene3D(new SmoothSkybox(7, true)), 
            new BasicRenderer());

            addSlide("Smooth skybox 6 px precision", 
"",
            new Scene3D(new SmoothSkybox(6, true)), 
            new BasicRenderer());

            addSlide("Smooth skybox 5 px precision", 
"",
            new Scene3D(new SmoothSkybox(5, true)), 
            new BasicRenderer());

            addSlide("Smooth skybox 4 px precision", 
"",
            new Scene3D(new SmoothSkybox(4, true)), 
            new BasicRenderer());

            addSlide("Smooth skybox 3 px precision", 
"",
            new Scene3D(new SmoothSkybox(3, true)), 
            new BasicRenderer());

            addSlide("Smooth skybox 2 px precision", 
"",
            new Scene3D(new SmoothSkybox(2, true)), 
            new BasicRenderer());

            addSlide("Smooth skybox 1 px precision", 
"",
            new Scene3D(new SmoothSkybox(1, true)), 
            new BasicRenderer());
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
    [Embed(source="images/morning-back.jpg")]
    public static var MorningBackImage:Class;

    public static function get morningBack():BitmapData
    {
        return (new MorningBackImage as BitmapAsset).bitmapData;
    }

    [Embed(source="images/morning-down.jpg")]
    public static var MorningDownImage:Class;

    public static function get morningDown():BitmapData
    {
        return (new MorningDownImage as BitmapAsset).bitmapData;
    }

    [Embed(source="images/morning-front.jpg")]
    public static var MorningFrontImage:Class;

    public static function get morningFront():BitmapData
    {
        return (new MorningFrontImage as BitmapAsset).bitmapData;
    }

    [Embed(source="images/morning-left.jpg")]
    public static var MorningLeftImage:Class;

    public static function get morningLeft():BitmapData
    {
        return (new MorningLeftImage as BitmapAsset).bitmapData;
    }

    [Embed(source="images/morning-right.jpg")]
    public static var MorningRightImage:Class;

    public static function get morningRight():BitmapData
    {
        return (new MorningRightImage as BitmapAsset).bitmapData;
    }

    [Embed(source="images/morning-up.jpg")]
    public static var MorningUpImage:Class;

    public static function get morningUp():BitmapData
    {
        return (new MorningUpImage as BitmapAsset).bitmapData;
    }
}

class SimpleSkybox extends ObjectContainer3D
{
    public var skybox:Skybox;
                       
    public function SimpleSkybox(n:int, smooth:Boolean = false)
    {
        skybox = new Skybox(new BitmapMaterial(Asset.morningFront, {smooth:smooth}), 
                            new BitmapMaterial(Asset.morningLeft, {smooth:smooth}), 
                            new BitmapMaterial(Asset.morningBack, {smooth:smooth}), 
                            new BitmapMaterial(Asset.morningRight, {smooth:smooth}), 
                            new BitmapMaterial(Asset.morningUp, {smooth:smooth}), 
                            new BitmapMaterial(Asset.morningDown, {smooth:smooth}));

        while (n-- > 0)
            skybox.quarterFaces();

        super(null, skybox);
    }
    
}

class SmoothSkybox extends ObjectContainer3D
{
    public var skybox:Skybox;
                       
    public function SmoothSkybox(precision:Number, smooth:Boolean = false)
    {
        skybox = new Skybox(new PreciseBitmapMaterial(Asset.morningFront, {precision:precision, smooth:smooth}), 
                            new PreciseBitmapMaterial(Asset.morningLeft, {precision:precision, smooth:smooth}), 
                            new PreciseBitmapMaterial(Asset.morningBack, {precision:precision, smooth:smooth}), 
                            new PreciseBitmapMaterial(Asset.morningRight, {precision:precision, smooth:smooth}), 
                            new PreciseBitmapMaterial(Asset.morningUp, {precision:precision, smooth:smooth}), 
                            new PreciseBitmapMaterial(Asset.morningDown, {precision:precision, smooth:smooth}));

        super(null, skybox);
    }
    
}

