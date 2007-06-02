package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;
    import flash.utils.*;
    import flash.geom.*;
    import flash.display.*;

    /** Object holding information for one rendering frame */
    public class RenderSession
    {
        public var scene:Scene3D;
        public var camera:Camera3D;
        public var container:Sprite;
        public var clip:Clipping;
        public var lightarray:LightArray;
        public var time:int;

        private var _graphics:Graphics;

        public function get graphics():Graphics
        {
            if (_graphics == null)
            {
                var sprite:Sprite = new Sprite();
                container.addChild(sprite);
                _graphics = sprite.graphics;
            }
            return _graphics;
        }

        public function addDisplayObject(child:DisplayObject):void
        {
            _graphics == null;
            container.addChild(child);
        }

        public function RenderSession(scene:Scene3D, camera:Camera3D, container:Sprite, clip:Clipping, lightarray:LightArray)
        {
            this.scene = scene;
            this.camera = camera;
            this.container = container;
            this.clip = clip;
            this.lightarray = lightarray;
            this.time = getTimer();
        }
    }
}

