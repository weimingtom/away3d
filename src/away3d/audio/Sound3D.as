package away3d.audio
{
	import away3d.core.base.Object3D;
	import flash.media.Sound;

	public class Sound3D extends Object3D
	{
		private var _sound:Sound;
		
		public function Sound3D(sound:Sound, init:Object)
		{
			super(init);
		}
		
	}
}