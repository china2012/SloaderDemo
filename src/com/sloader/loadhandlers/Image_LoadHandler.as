package com.sloader.loadhandlers
{
	import com.sloader.SLoaderError;
	import com.sloader.SLoaderFile;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	public class Image_LoadHandler extends LoadHandler
	{
		public var bitmap:Bitmap;
		
		private var _loader:Loader;
		
		public function Image_LoadHandler(fileVO:SLoaderFile, loaderContext:LoaderContext)
		{
			super(fileVO, loaderContext);
			
			_file.loaderInfo.loadHandler = this;
			
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.OPEN, onFileStart);
			_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onFileProgress);
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onFileComplete);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onFileIoError);
		}
		
		protected function onFileIoError(event:IOErrorEvent):void
		{
			var error:SLoaderError = new SLoaderError(_file, event.text);
			
			if (_onFileIoError != null)
				_onFileIoError(error);
		}
		
		protected function onFileComplete(event:Event):void
		{
			_file.size = event.currentTarget.bytesTotal;
			_file.loaderInfo.loadedBytes = event.currentTarget.bytesLoaded;
			_file.loaderInfo.totalBytes = event.currentTarget.bytesTotal;
			
			bitmap = _loader.content as Bitmap;
			
			if (_onFileComplete != null)
				_onFileComplete(_file);
		}
		
		protected function onFileProgress(event:ProgressEvent):void
		{
			_file.size = event.bytesTotal;
			_file.loaderInfo.totalBytes = event.bytesTotal;
			_file.loaderInfo.loadedBytes = event.bytesLoaded;
			
			if (_onFileProgress != null)
				_onFileProgress(_file);
		}
		
		protected function onFileStart(event:Event):void
		{
			if (_onFileStart != null)
				_onFileStart(_file);
		}
		
		override public function load():void
		{
			var urlRequest:URLRequest = new URLRequest(_file.url);
			_loader.load(urlRequest, _loaderContext);
		}
		
		override public function unLoad():void
		{
			super.unLoad();
			_loader.unload();
			bitmap = null;
		}
	}
}