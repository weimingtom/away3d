package away3d.test;

    import flash.display.*;

    /**
    * Simple rounded rectangle button
    */ 
    class Button extends SimpleButton {
        
        public var selected:Bool ;

        public function new(text:String, ?pwidth:Int = 80, ?pheight:Int = 20)
        {
            
            selected = false;
            upState = new ButtonState(pwidth, pheight, text, 0x000000);
            overState = new ButtonState(pwidth, pheight,text, 0x666666);
            downState = new ButtonState(pwidth, pheight, text, 0xFFFFFF);
            hitTestState = new ButtonState(pwidth, pheight);
        }
    }
