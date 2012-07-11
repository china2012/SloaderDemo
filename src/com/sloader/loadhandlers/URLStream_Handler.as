package com.sloader.loadhandlers
{
	import com.sloader.SLoaderError;
	import com.sloader.SLoaderFile;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.system.LoaderContext;

	public class URLStream_Handler extends LoadHandler
	{
		private var _loaderContext:LoaderContext;
		
		public function URLStream_Handler(fileVO:SLoaderFile, loaderContext:LoaderContext)
		{
			super(fileVO);

			_loaderContext = loaderContext;
			_file.loaderInfo.loadHandler = this;
			
			_file.loaderInfo.loader = new URLStream();
			_file.loaderInfo.loader.addEventListener(Event.OPEN, onFileStart);
			_file.loaderInfo.loader.addEventListener(ProgressEvent.PROGRESS, onFileProgress);
			_file.loaderInfo.loader.addEventListener(Event.COMPLETE, onFileComplete);
			_file.loaderInfo.loader.addEventListener(IOErrorEvent.IO_ERROR, onFileIoError);
		}

		protected function onFileIoError(event:IOErrorEvent):void
		{
			var error:SLoaderError = new SLoaderError(_file, event.text);

			if (_onFileIoError != null)
				_onFileIoError(error);
		}

		protected function onFileComplete(event:Event):void
		{
			_file.size = event.currentTarget.bytesAvailable;

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
			_file.loaderInfo.loader.load(urlRequest);
		}
		
		override public function unLoad():void
		{
			super.unLoad();
			_file.loaderInfo.loader = null;
		}
	}
}