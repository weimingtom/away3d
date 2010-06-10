package modifies
{
	import away3dlite.animators.BonesAnimator;
	import away3dlite.animators.bones.Bone;
	import away3dlite.containers.*;
	import away3dlite.core.base.Mesh;
	import away3dlite.core.utils.*;
	import away3dlite.events.Loader3DEvent;
	import away3dlite.loaders.*;
	import away3dlite.templates.BasicTemplate;

	import flash.events.*;
	import flash.geom.Vector3D;
	import flash.utils.*;

	[SWF(backgroundColor="#000000", frameRate="30", width="800", height="600")]

	/**
	 * Collada Modifier example.
	 */
	public class ExColladaAnimationModifier extends BasicTemplate
	{
		// source
		private var _collada0:Collada;
		private var _loader3D0:Loader3D;
		private var _model0:ObjectContainer3D;
		private var _bonesAnimator0:BonesAnimator;

		// target
		private var _collada1:Collada;
		private var _loader3D1:Loader3D;
		private var _model1:ObjectContainer3D;
		private var _bonesAnimator1:BonesAnimator;

		// test
		private const _TYPE_NAME:Array = ["x,y,z", "x", "y", "z", "x,z"];
		private var _type:int = 0;

		override protected function onInit():void
		{
			// init
			title += " : Collada Example.";
			Debug.active = true;
			camera.y = -500;
			camera.lookAt(new Vector3D());

			// source
			_collada0 = new Collada();
			_collada0.scaling = 10;

			_loader3D0 = new Loader3D();
			scene.addChild(_loader3D0);
			_loader3D0.loadGeometry("../src/loaders/assets/dae/30_box_smooth_translate.dae", _collada0);
			_loader3D0.addEventListener(Loader3DEvent.LOAD_SUCCESS, onSuccess0);

			// target
			_collada1 = new Collada();
			_collada1.scaling = 10;

			_loader3D1 = new Loader3D();
			scene.addChild(_loader3D1);
			_loader3D1.loadGeometry("../src/loaders/assets/dae/30_box_smooth_translate_fat.dae", _collada1);
			_loader3D1.addEventListener(Loader3DEvent.LOAD_SUCCESS, onSuccess1);

			stage.addEventListener(MouseEvent.CLICK, onClick);
		}

		// source
		private function onSuccess0(event:Loader3DEvent):void
		{
			_model0 = _loader3D0.handle as ObjectContainer3D;
			_model0.x = 100;
			_bonesAnimator0 = _model0.animationLibrary.getAnimation("default").animation as BonesAnimator;
		}

		// target
		private function onSuccess1(event:Loader3DEvent):void
		{
			_model1 = _loader3D1.handle as ObjectContainer3D;
			_bonesAnimator1 = _model1.animationLibrary.getAnimation("default").animation as BonesAnimator;
		}

		// modify uitl
		private function modify(source:ObjectContainer3D, target:ObjectContainer3D, percent:Number = 1):void
		{
			for each (var _mesh0:Mesh in source.children)
			{
				if (_mesh0 is Bone)
					continue;

				var _mesh1:Mesh = ObjectContainer3D(target).getChildByName(_mesh0.name) as Mesh;
				if (_mesh1 is Bone)
					continue;

				var _vertices0:Vector.<Number> = _mesh0.vertices;
				var _vertices1:Vector.<Number> = _mesh1.vertices;
				var _length0:int = _vertices0.length;

				for (var i:int = 0; i < _length0; i++)
				{
					switch (_type)
					{
						case 0:
							// x,y,z
							_vertices0[i] = _vertices0[i] + (_vertices1[i] - _vertices0[i]) * percent;
							break;
						case 1:
							// x
							_vertices0[i] = _vertices0[i] + (_vertices1[i] - _vertices0[i]) * percent;
							// skip y
							i++;
							// skip z
							i++;
							break;
						case 2:
							// skip x
							i++;
							// y
							_vertices0[i] = _vertices0[i] + (_vertices1[i] - _vertices0[i]) * percent;
							// skip z
							i++;
							break;
						case 3:
							// skip x
							i++;
							// skip y
							i++;
							// z
							_vertices0[i] = _vertices0[i] + (_vertices1[i] - _vertices0[i]) * percent;
							break;
						case 4:
							// x
							_vertices0[i] = _vertices0[i] + (_vertices1[i] - _vertices0[i]) * percent;
							// skip y
							i++;
							// z
							_vertices0[i] = _vertices0[i] + (_vertices1[i] - _vertices0[i]) * percent;
							break;
					}
				}
			}
		}

		private function onClick(event:Event):void
		{
			if (++_type == _TYPE_NAME.length)
				_type = 0;
		}

		override protected function onPreRender():void
		{
			var _percent:Number = mouseX / _screenRect.width;
			var _timer:Number = getTimer() / 1000;

			title = "Click = Toggle Modify : " + _TYPE_NAME[_type] + " | Move MouseX = Percent : " + _percent;

			if (_bonesAnimator0 && _bonesAnimator1)
			{
				// source
				_bonesAnimator0.update(_timer);

				// target
				_bonesAnimator1.update(_timer);

				// modify
				modify(_model0, _model1, _percent);
			}

			scene.rotationY++;
		}
	}
}