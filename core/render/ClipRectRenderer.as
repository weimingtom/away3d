package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;
    import flash.geom.*;
    import flash.display.*;

    public class ClipRectRenderer implements IRenderer
    {
        public function ClipRectRenderer()
        {
        }

        public function render(scene:Scene3D, camera:Camera3D, container:Sprite, clip:Clipping):void
        {
            if (clip is RectangleClipping)
            {
                var cliprect:RectangleClipping = clip as RectangleClipping;
                var graphics:Graphics = container.graphics;
                graphics.lineStyle(0, 0xFF0000);
                graphics.drawRect(cliprect.minX, cliprect.minY, (cliprect.maxX - cliprect.minX), (cliprect.maxY - cliprect.minY));
                graphics.lineStyle(0, 0xFF00FF);
                graphics.drawRect(cliprect.minX+10, cliprect.minY+10, (cliprect.maxX - cliprect.minX)-20, (cliprect.maxY - cliprect.minY)-20);
                graphics.lineStyle(0, 0x00FF00);
                graphics.drawRect(cliprect.minX+20, cliprect.minY+20, (cliprect.maxX - cliprect.minX)-40, (cliprect.maxY - cliprect.minY)-40);
                graphics.lineStyle(0, 0x0000FF);
                graphics.drawRect(cliprect.minX+(cliprect.maxX - cliprect.minX)*0.1, cliprect.minY+(cliprect.maxY - cliprect.minY)*0.1, (cliprect.maxX - cliprect.minX)*0.8, (cliprect.maxY - cliprect.minY)*0.8);
            }
        }
    }
}
