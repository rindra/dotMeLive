package
{
	import As3Math.geo2d.*;
	import As3Math.geo2d.amPoint2d;
	
	import QuickB2.debugging.qb2DebugPanel;
	import QuickB2.objects.tangibles.*;
	import QuickB2.objects.tangibles.qb2Body;
	import QuickB2.stock.*;
	import QuickB2.stock.qb2Stock;
	
	import com.adobe.serialization.json.JSON;
	import com.greensock.TweenMax;
	
	import flash.display.*;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import flash.system.Security;
	
	[SWF(width='420', height='1000', backgroundColor='#ffffff',frameRate='60')]
	
	public class dotMe extends Sprite{
		
		private var world:qb2World;
		private var last_o:Object;
		private var max:uint = 100;
		
		private var url:String = 'http://ripplr.condenast.com/client_feeds/cnbrands';
		//private var url:String = 'http://rindra.com/cnd/dotme/backup.json';
		
		public function dotMe(){
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init($e:Event = null):void{
			var count:uint = 0;
			var first:Boolean = true;
			
			world = new qb2World();
			world.debugDragSource = stage;
			world.actor = stage.addChild(new Sprite());
			world.debugDrawContext = (stage.addChild(new Sprite()) as Sprite).graphics;
			world.timeStep = 1 / stage.frameRate;
			world.gravity.y = 10;
			world.start(); 
			world.addObject(new qb2StageWalls(stage));
			world.lastObject().drawsDebug = false;  
			
			//var panel:qb2DebugPanel = new qb2DebugPanel();
			//addChild(panel);
			
			var l:URLLoader = new URLLoader();
			l.load(new URLRequest(url));
			l.addEventListener(Event.COMPLETE, _complete);
			l.addEventListener(IOErrorEvent.IO_ERROR, _fuck);
			
			var btn:Hit = new Hit();
			btn.x = 20;
			btn.y = 20;
			btn.addEventListener(MouseEvent.MOUSE_DOWN, function ():void{ stage.displayState = StageDisplayState.FULL_SCREEN; })
			addChild(btn);
				
			function _complete($e:Event):void{
				var o:Object = JSON.decode($e.target.data);
				if(first){
					first = false;
					show(o);
				}else{
					if(check(o)){
						TweenMax.to(btn, 60, {onComplete: function ():void{ trace('seeking for new tweets'); count = 0; l.load(new URLRequest('http://ripplr.condenast.com/client_feeds/cnbrands')); }});
					}else{
						trace('found new tweets');
						show(o);
					}
				}
				
				
			/*	for(var i:uint = 0; i<50; i++){
					var l:Loader = new Loader();
					l.load(new URLRequest(o[i].avatar));
					l.contentLoaderInfo.addEventListener(Event.COMPLETE, _bmp);
				}*/
			}
			
			function check(o:Object):Boolean{
				var ok:Boolean;
				for(var i:uint = 0; i<o.length; i++){
					if(last_o[count].avatar == o[i].avatar){
						trace(i, count);
						max = i;
						if(max > 0){
							ok = false;
						}else{
							ok = true;
						}
						break;
					}else{
						ok = false;
					}
				}
				return ok;
			}
			
			function _bmp($e:Event):void{
				var bmp:Bitmap = Bitmap($e.target.content);
				bmp.width = 48;
				bmp.height = 48;
				bmp.smoothing = true;
				generate(bmp);
			}
			
			function show(o:Object):void{
				if(count<max){
					//trace(count)
					TweenMax.to(btn, 1, {onComplete:_loadAvatar, onCompleteParams:[o]});
				}else{
					last_o = o;
					trace(count);//started at 7:00pm
					count = 0;
					l.load(new URLRequest(url));
				}
			}
			
			function _loadAvatar(o:Object):void{
				var l:Loader = new Loader();
				Security.allowDomain('*');
				
				if((String(o[count].avatar).split('http://a0')).length > 1 ){
					Security.loadPolicyFile('http://a0.twimg.com/crossdomain.xml');
				} 
				
				if((String(o[count].avatar).split('http://a1')).length > 1 ){
					Security.loadPolicyFile('http://a1.twimg.com/crossdomain.xml');
				} 
				
				if((String(o[count].avatar).split('http://a2')).length > 1 ){
					Security.loadPolicyFile('http://a2.twimg.com/crossdomain.xml');
				} 
				
				if((String(o[count].avatar).split('http://a3')).length > 1 ){
					Security.loadPolicyFile('http://a3.twimg.com/crossdomain.xml');
				} 
				
				l.load(new URLRequest(o[count].avatar));
				l.contentLoaderInfo.addEventListener(Event.COMPLETE, _bmp);
				l.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, _fuck);
				
				count++;
				
				show(o);
			}
		}
		
		private function _fuck($e:IOErrorEvent):void{
			trace('what the fuck happened?')
		}
		
		private function generate(bmp:Bitmap):void{
			var center:amPoint2d = new amPoint2d(stage.stageWidth / 2, stage.stageHeight / 2);
			var top:amPoint2d = new amPoint2d(stage.stageWidth/2, 0);
			var pic:qb2Body = makePic(bmp.bitmapData, 1);
			
			
			pic.position.copy(top);
			pic.position.x -= pic.getBoundBox().width / 2;
			pic.position.y -= pic.getBoundBox().height / 2;
			
			world.addObject(pic);
		}
		
		private function makePic(bmpData:BitmapData, skin:uint):qb2Body{
			var body:qb2Body = new qb2Body();
			//var img:Bitmap = (new PicOfMe()) as Bitmap;
			var img:Bitmap = new Bitmap(bmpData);
			
			if(skin == 1){
				var wrapper:Sprite = new Sprite();
				var circle:Sprite = new Sprite();
				img.width = 48;
				img.height = 48;
				img.smoothing = true;
				circle.graphics.beginFill(0xff0000);
				circle.graphics.drawCircle(24,24,24);
				wrapper.addChild(img);
				wrapper.addChild(circle);
				img.mask = circle;
				body.actor = wrapper;
				body.addObject(qb2Stock.newCircleShape(new amPoint2d(wrapper.width / 2, wrapper.height / 2), 24, 1));
			}else{
				img.width = 48;
				img.height = 48;
				img.smoothing = true;
				body.actor = img;
				body.addObject(qb2Stock.newRectShape(new amPoint2d(img.width / 2, img.height / 2), 48, 48, 1));
			}
			
			
			body.mass = 1;
			body.drawsDebug = false;
			
			return body;
		}
	}
}