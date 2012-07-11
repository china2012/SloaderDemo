package com.sloader.loadhandlers
{
	import com.sloader.SLoaderFile;
	import com.sloader.SLoaderFileInfo;
	
	import flash.system.LoaderContext;

	public class LoadHandler
	{
		public var _file:SLoaderFile;

		public var _onFileComplete:Function = null;
		public var _onFileProgress:Function = null;
		public var _onFileStart:Function = null;
		public var _onFileIoError:Function = null;

		public function LoadHandler(fileVO:SLoaderFile)
		{
			_file = fileVO;
			_file.loaderInfo = new SLoaderFileInfo();
		}

		public function setFileStartEventHandler(handler:Function):void
		{
			_onFileStart = handler;
		}

		public function setFileProgressEventHandler(handler:Function):void
		{
			_onFileProgress = handler;
		}

		public function setFileCompleteEventHandler(handler:Function):void
		{
			_onFileComplete = handler;
		}

		public function setFileIoErrorEventHandler(handler:Function):void
		{
			_onFileIoError = handler;
		}

		public function load():void
		{

		}
		
		public function unLoad():void
		{
			_file.size = Number.NaN;
			_file.loaderInfo.loadedBytes = 0;
			_file.loaderInfo.totalBytes = 0;
		}
	}
}