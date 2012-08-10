package
{
import away3d.containers.View3D;

import away3d.debug.AwayStats;
import away3d.lights.PointLight;

import away3d.materials.ColorMaterial;

import com.li.away3d.camera.MKSOCameraController;

import com.li.away3d.primitives.MengerSponge;

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.geom.Vector3D;

/*
    Understanding primitives and adding missing primitives to Away4.
    Also making fractal primitives.
 */
public class Intermediate_CustomGeometryPrimitives extends Sprite
{
    private var _view:View3D;
    private var _mksoCameraController:MKSOCameraController;
    private var _traceCameraLight:PointLight;
    private var _objectCameraLight:PointLight;
    private var _objectMaterial:ColorMaterial;
    private var _traceMaterial:ColorMaterial;
    private var angles:Vector3D = new Vector3D();
    private var angleSpeeds:Vector3D = new Vector3D(0.01, 0.02, 0.03);
    private var color:Vector3D = new Vector3D(0, 0, 0);

    public function Intermediate_CustomGeometryPrimitives()
    {
        addEventListener(Event.ADDED_TO_STAGE, stageInitHandler);
    }

	private function stageInitHandler(evt:Event):void
	{
	    removeEventListener(Event.ADDED_TO_STAGE, stageInitHandler);

	    // Init stage.
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;
        stage.frameRate = 60;

        // Init 3D core.
        _view = new View3D();
        addChild(_view);

        // Show Away3D stats.
        var stats:AwayStats = new AwayStats(_view);
        stats.x = stage.stageWidth - stats.width;
        addChild(stats);

        // Init camera controller.
        _view.camera.z = -1000;
        _view.camera.x = 1000;
        _view.camera.y = 500;
        _view.camera.lens.far = 10000;
        _mksoCameraController = new MKSOCameraController(_view.camera);
        _mksoCameraController.soCameraController.oCameraController.minRadius = 10;
        _mksoCameraController.soCameraController.oCameraController.maxRadius = 25000;
        _view.parent.addChildAt(_mksoCameraController, 0);

        // Lights.
        _objectCameraLight = new PointLight();
        _objectCameraLight.color = 0x0000FF;
        _view.scene.addChild(_objectCameraLight);
        _traceCameraLight = new PointLight();
        _traceCameraLight.color = 0xFF0000;
        _view.scene.addChild(_traceCameraLight);

        // Materials.
        _objectMaterial = new ColorMaterial(0xFFFFFF, 1);
        _objectMaterial.lights = [_objectCameraLight];
        _traceMaterial = new ColorMaterial(0xFFFFFF);
        _traceMaterial.lights = [_traceCameraLight];

        // Create sponge.
        var sponge:MengerSponge = new MengerSponge(_objectMaterial, 1000, 3);
        _view.scene.addChild(sponge);

        // Start loop.
        addEventListener(Event.ENTER_FRAME, enterFrameHandler);
	}

    // Loop.
    private function enterFrameHandler(event:Event):void
    {
        // Update color.
        color.x = 127*Math.sin(angles.x) + 127;
        color.y = 127*Math.sin(angles.y) + 127;
        color.z = 127*Math.sin(angles.z) + 127;
        angles.x += angleSpeeds.x;
        angles.y += angleSpeeds.y;
        angles.z += angleSpeeds.z;
        _objectCameraLight.color = color.x << 16 | color.y << 8 | color.z;

        // Update camera.
        _mksoCameraController.update();

        // Update camera lights.
        _objectCameraLight.transform = _view.camera.transform.clone();
        _traceCameraLight.transform = _view.camera.transform.clone();

        // Render.
        _view.render();
    }
}
}
