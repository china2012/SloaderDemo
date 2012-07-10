package com.sloader.loadhandlers
{
	import com.sloader.SLoaderFileInfo;
	import com.sloader.SLoaderFile;

	import flash.system.ApplicationDomain;

	public class LoadHandler
	{
		public var _file:SLoaderFile;

		public var _eventHandlerOnFileComplete:Function = null;
		public var _eventHandlerOnFileProgress:Function = null;
		public var _eventHandlerOnFileStart:Function = null;
		public var _eventHandlerOnFileIoError:Function = null;

		public function LoadHandler(fileVO:SLoaderFile, domain:ApplicationDomain)
		{
			_file = fileVO;
			_file.loaderInfo = new SLoaderFileInfo();
			_file.loaderInfo.applicationDomain = domain;
		}

		public function setFileStartEventHandler(handler:Function):void
		{
			_eventHandlerOnFileStart = handler;
		}

		public function setFileProgressEventHandler(handler:Function):void
		{
			_eventHandlerOnFileProgress = handler;
		}

		public function setFileCompleteEventHandler(handler:Function):void
		{
			_eventHandlerOnFileComplete = handler;
		}

		public function setFileIoErrorEventHandler(handler:Function):void
		{
			_eventHandlerOnFileIoError = handler;
		}

		public function load():void
		{

		}
	}
}