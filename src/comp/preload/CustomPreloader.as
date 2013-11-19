package comp.preload
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import mx.events.*;
	import mx.preloaders.Preloader;
	import mx.preloaders.DownloadProgressBar;
	
	public class CustomPreloader extends DownloadProgressBar {
		
		private var wcs:PreloaderDisplay;
		
		public function CustomPreloader() 
		{
			super(); 
			wcs = new PreloaderDisplay();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		private function onAddedToStage(event:Event):void {
			
			// Add the loader screen to the stage and center it
			this.addChild(wcs)  
			wcs.x = (stage.stageWidth-wcs.width)/2;
			wcs.y = (stage.stageHeight-wcs.height)/2;
			
		}
		override public function set preloader( preloader:Sprite ):void 
		{     
			preloader.addEventListener( ProgressEvent.PROGRESS , SWFDownloadProgress );    
			preloader.addEventListener( Event.COMPLETE , SWFDownloadComplete );
			preloader.addEventListener( FlexEvent.INIT_PROGRESS , FlexInitProgress );
			preloader.addEventListener( FlexEvent.INIT_COMPLETE , FlexInitComplete );
		}
		private function SWFDownloadProgress( event:ProgressEvent ):void {
			var progress: Number = event.bytesLoaded / event.bytesTotal;
			if (wcs){
				//set the main progress bar inside PreloaderDisplay
				wcs.setMainProgress(progress);
				//set percetage text to display, if loading RSL the rslBaseText will indicate the number
				setPreloaderLoadingText(((Math.round((progress)*10000))/100).toString() + "%");
			}
		}
		private function setPreloaderLoadingText(value:String):void {
			//set the text display in the flash preloader
			wcs.loading_txt.text = value;
		}
		private function SWFDownloadComplete( event:Event ):void {}
		
		private function FlexInitProgress( event:Event ):void {}
		
		private function FlexInitComplete( event:Event ):void 
		{      
			wcs.ready = true;      
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
	}
	
}

