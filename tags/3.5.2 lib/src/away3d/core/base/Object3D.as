﻿package away3d.core.base
			if (!_visibilityupdated)
				_visibilityupdated = new Object3DEvent(Object3DEvent.VISIBLITY_UPDATED, this);
			if (!hasEventListener(Object3DEvent.POSITION_CHANGED))
			if (_ownSession && event.object.session.parent)
				event.object.session.parent.removeChildSession(_ownSession);
				_ownSession.renderer = null;
				_ownSession.object3D = null;
				_ownSession.blendMode = _blendMode;
				_ownSession.object3D = this;
			_transformDirty = true;
			addEventListener(Object3DEvent.VISIBLITY_UPDATED, listener, false, 0, true);
			addEventListener(Object3DEvent.SCALE_CHANGED, listener, false, 0, true);