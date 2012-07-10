package com.sloader.loadhandlers
{
	import com.sloader.SLoaderError;
	import com.sloader.SLoaderFile;

	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;

	public class Image_LoadHandler extends LoadHandler
	{
		public function Image_LoadHandler(fileVO:SLoaderFile, domain:ApplicationDomain)
		{
			super(fileVO, domain);
			_file.loaderInfo.loader = new Loader();
			_file.loaderInfo.loader.contentLoaderInfo.addEventListener(Event.OPEN, onFileStart);
			_file.loaderInfo.loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onFileProgress);
			_file.loaderInfo.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onFileComplete);
			_file.loaderInfo.loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onFileIoError);
		}

		protected function onFileIoError(event:IOErrorEvent):void
		{
			var error:SLoaderError = new SLoaderError(_file, event.text);

			if (_eventHandlerOnFileIoError != null)
				_eventHandlerOnFileIoError(error);
		}

		protected function onFileComplete(event:Event):void
		{
			_file.totalBytes = event.currentTarget.bytesTotal;
			_file.loaderInfo.loadedBytes = event.currentTarget.bytesLoaded;
			_file.loaderInfo.totalBytes = event.currentTarget.bytesTotal;

			if (_eventHandlerOnFileComplete != null)
				_eventHandlerOnFileComplete(_file);
		}

		protected function onFileProgress(event:ProgressEvent):void
		{
			_file.totalBytes = event.bytesTotal;
			_file.loaderInfo.totalBytes = event.bytesTotal;
			_file.loaderInfo.loadedBytes = event.bytesLoaded;

			if (_eventHandlerOnFileProgress != null)
				_eventHandlerOnFileProgress(_file);
		}

		protected function onFileStart(event:Event):void
		{
			if (_eventHandlerOnFileStart != null)
				_eventHandlerOnFileStart(_file);
		}

		override public function load():void
		{
			var urlRequest:URLRequest = new URLRequest(_file.url);
			_file.loaderInfo.loader.load(urlRequest);
		}
	}
}