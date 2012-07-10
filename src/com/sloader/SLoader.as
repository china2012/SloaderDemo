package com.sloader
{
	import com.sloader.loadhandlers.DAT_LoadHandler;
	import com.sloader.loadhandlers.Image_LoadHandler;
	import com.sloader.loadhandlers.LoadHandler;
	import com.sloader.loadhandlers.SWF_LoadHandler;
	import com.sloader.loadhandlers.XML_LoadHandler;
	
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;

	public class SLoader
	{
		private var _appDomain:ApplicationDomain;
		
		private var _loadHandlers:Array;
		private var _eventHandlers:Dictionary;
		
		private var _listLoaded:Array;
		private var _listReadyLoad:Array;
		
		private var _loadInfo:SLoaderInfo;
		
		////////////////////////////////////////////////////////////////////////
		private var _isLoading:Boolean = false;
		
		private var _lastProgressLoadedBytes:Number;
		
		private var _loadedBytes:Number;
		
		private var _currTotalFileCount:int;
		private var _currLoadedFileCount:int;
		
		private var _currTotalBytes:Number;
		private var _currLoadedBytes:Number;
		
		private var _tempLoadPercentage:Number;
		////////////////////////////////////////////////////////////////////////
		
		public function SLoader(name:String, applicationDomain:ApplicationDomain=null)
		{
			SLoaderManage.addSLoader(name, this);
			
			_appDomain = applicationDomain || new ApplicationDomain(ApplicationDomain.currentDomain);
			
			_eventHandlers = new Dictionary();
			_loadHandlers = [];
			_listLoaded = [];
			_listReadyLoad = [];
			_loadedBytes = 0;
			_loadInfo = new SLoaderInfo();
			
			registerLoadHandler();
			registerEventHandler();
		}
		
		private function registerLoadHandler():void
		{
			_loadHandlers[SLoaderFileType.SWF.toLowerCase()] = SWF_LoadHandler;
			_loadHandlers[SLoaderFileType.XML.toLowerCase()] = XML_LoadHandler;
			_loadHandlers[SLoaderFileType.DAT.toLowerCase()] = DAT_LoadHandler;
			_loadHandlers[SLoaderFileType.JPG.toLowerCase()] = Image_LoadHandler;
			_loadHandlers[SLoaderFileType.PNG.toLowerCase()] = Image_LoadHandler;
			_loadHandlers[SLoaderFileType.BMP.toLowerCase()] = Image_LoadHandler;
		}
		
		private function registerEventHandler():void
		{
			_eventHandlers[SLoaderEventType.FILE_COMPLETE] = [];
			_eventHandlers[SLoaderEventType.FILE_ERROR] =  [];
			_eventHandlers[SLoaderEventType.FILE_PROGRESS] = [];
			_eventHandlers[SLoaderEventType.FILE_START] = [];
			_eventHandlers[SLoaderEventType.SLOADER_COMPLETE] = [];
			_eventHandlers[SLoaderEventType.SLOADER_PROGRESS] = [];
			_eventHandlers[SLoaderEventType.SLOADER_START] = [];
		}
		
		///////////////////////////////////////////////////////////////////////////
		// loadListManage
		///////////////////////////////////////////////////////////////////////////
		public function addFile(fileVO:SLoaderFile):void
		{
			checkLoadIt();
			checkFileVO(fileVO);
			checkRepeatFileVO(fileVO);
			
			_listReadyLoad.push(fileVO);
		}
		
		public function addFiles(files:Array):void
		{
			checkLoadIt();
			
			for (var i:int=0; i<files.length; i++)
			{
				var fileVO:SLoaderFile = files[i];
				checkFileVO(fileVO);
				checkRepeatFileVO(fileVO);
				
				_listReadyLoad.push(fileVO);
			}
		}
		
		public function removeFile(fileVO:SLoaderFile):void
		{
			checkLoadIt();
			
			var index:int = _listReadyLoad.indexOf(fileVO);
			if (index != -1)
				_listReadyLoad.splice(index, 1);
		}
		
		public function execute():void
		{
			checkLoadIt();
			
			if (_listReadyLoad.length < 1)
				return;
			
			_isLoading = true;
			
			_execute(_currLoadedFileCount);
		}
		
		private function _execute(fileIndex:int):void
		{
			var fileVO:SLoaderFile = _listReadyLoad[fileIndex];
			var fileType:String = getFileType(fileVO).toLowerCase();
			var fileLoadHandlerClass:Class = _loadHandlers[fileType];
			if (!fileLoadHandlerClass)
			{
				throw new Error("you not registered handler on ["+fileType+"]");
			}
			else
			{
				var loadHandler:LoadHandler = new fileLoadHandlerClass(fileVO, _appDomain);
				loadHandler.setFileCompleteEventHandler(onFileComplete);
				loadHandler.setFileProgressEventHandler(onFileProgress);
				loadHandler.setFileStartEventHandler(onFileStart);
				loadHandler.setFileIoErrorEventHandler(onFileIoError);
				loadHandler.load();
			}
		}
		
		///////////////////////////////////////////////////////////////////////////
		// eventManage
		///////////////////////////////////////////////////////////////////////////
		public function addEventListener(type:String, handler:Function):void
		{
			if (!_eventHandlers[type])
				throw new Error("event name["+type+"] is Invalid");
			
			_eventHandlers[type].push(handler);
		}
		
		public function removeEventListener(type:String, handler:Function):void
		{
			if (!_eventHandlers[type])
				return;
			
			var index:int = (_eventHandlers[type] as Array).indexOf(handler);
			if (index != -1)
				_eventHandlers[type].splice(index, 1);
		}
		
		private function onFileStart(fileVO:SLoaderFile):void
		{
			_lastProgressLoadedBytes = 0;
			
			executeHandlers(_eventHandlers[SLoaderEventType.FILE_START], fileVO);
			
			if (_currLoadedFileCount == 0)
				onSloaderStart(fileVO);
		}
		
		private function onFileProgress(fileVO:SLoaderFile):void
		{
			executeHandlers(_eventHandlers[SLoaderEventType.FILE_PROGRESS], fileVO);
			onSloaderProgress(fileVO);
		}
		
		private function onFileComplete(fileVO:SLoaderFile):void
		{
			_currLoadedFileCount++;
			
			var hasfile:Boolean = _currLoadedFileCount != _currTotalFileCount;
			_isLoading = hasfile;
			
			executeHandlers(_eventHandlers[SLoaderEventType.FILE_COMPLETE], fileVO);
			
			if (hasfile)
				_execute(_currLoadedFileCount);
			else
				onSloaderComplete(fileVO);
		}
		
		private function onFileIoError(error:SLoaderError):void
		{
			_currLoadedFileCount++;
			
			var hasfile:Boolean = _currLoadedFileCount != _currTotalFileCount;
			_isLoading = hasfile;
			
			executeHandlers(_eventHandlers[SLoaderEventType.FILE_ERROR], error);
			
			if (hasfile)
				_execute(_currLoadedFileCount);
			else
				onSloaderComplete(error.file);
		}
		
		private function onSloaderStart(currFileVO:SLoaderFile):void
		{
			for each(var fileVO:SLoaderFile in _listReadyLoad)
			{
				if (isNaN(fileVO.totalBytes))
				{
					_currTotalBytes = Number.NaN;
					break;
				}
				else
					_currTotalBytes += fileVO.totalBytes;
			}
			
			_currLoadedBytes = 0;
			_currLoadedFileCount = 0;
			_currTotalFileCount = _listReadyLoad.length;
			
			executeHandlers(_eventHandlers[SLoaderEventType.SLOADER_START]);
		}
		
		private function onSloaderProgress(currFileVO:SLoaderFile):void
		{
			_lastProgressLoadedBytes = currFileVO.loaderInfo.loadedBytes - _lastProgressLoadedBytes;
			_currLoadedBytes += _lastProgressLoadedBytes;
			_loadedBytes += _lastProgressLoadedBytes;
			if (isNaN(_currTotalBytes))
			{
				_tempLoadPercentage = _currLoadedFileCount/_currTotalFileCount
					+ currFileVO.loaderInfo.loadedBytes/currFileVO.loaderInfo.totalBytes/_currTotalFileCount;
			}
			else
			{
				_tempLoadPercentage = _currLoadedBytes/_currTotalBytes;
			}
			_lastProgressLoadedBytes = currFileVO.loaderInfo.loadedBytes;
			
			executeHandlers(_eventHandlers[SLoaderEventType.SLOADER_PROGRESS]);
		}
		
		private function onSloaderComplete(currFileVO:SLoaderFile):void
		{
			executeHandlers(_eventHandlers[SLoaderEventType.SLOADER_COMPLETE]);
		}
		
		private function executeHandlers(handlers:Array, file:*=null):void
		{
			for (var i:int=0; i<handlers.length; i++)
			{
				var handler:Function = handlers[i];
				handler(file);
			}
		}
		
		///////////////////////////////////////////////////////////////////////////
		// check
		///////////////////////////////////////////////////////////////////////////
		private function checkLoadIt():void
		{
			if (_isLoading)
				throw new Error("Refused the operation, is loaded in");
		}
		
		private function checkFileVO(fileVO:SLoaderFile):void
		{
			if (!fileVO.name || !fileVO.url || !fileVO.title)
				throw new Error("The fileVO parameter is incorrect");
		}
		
		private function checkRepeatFileVO(fileVO:SLoaderFile):void
		{
			for (var i:int=0; i<_listLoaded.length; i++)
			{
				if ((_listLoaded[i] as SLoaderFile).title == fileVO.title)
					throw new Error("Duplication of add file(title:"+fileVO.title+")");
			}
		}
		
		///////////////////////////////////////////////////////////////////////////
		// get
		///////////////////////////////////////////////////////////////////////////		
		public function getFileType(file:SLoaderFile):String
		{
			if (file.type)
				return file.type;
			else
			{
				var extensions:Array = file.url.match(/[^\.][^\.]*/g);
				if (extensions)
				{
					if (extensions.length > 0)
					{
						var fileType:String = extensions[extensions.length-1];
						for (var _fileType:* in _loadHandlers)
						{
							if (_fileType == fileType)
								return _fileType;
						}
					}
				}
			}
			return "swf";
		}
		
		public function getFileVO(fileTitle:String):SLoaderFile
		{
			if (!_listLoaded)
				return null;
			
			for each(var fileVO:SLoaderFile in _listLoaded)
			{
				if (fileVO.title == fileTitle)
					return fileVO;
			}
			return null;
		}
		
		public function get loadInfo():SLoaderInfo
		{
			return _loadInfo;
		}
		
		public function get loadedBytes():Number
		{
			return _loadedBytes;
		}
		
		public function get currLoadedBytes():Number
		{
			return _currLoadedBytes;
		}
		
		public function get currTotalBytes():Number
		{
			return _currTotalBytes;
		}
		
		public function get currLoadedFileCount():int
		{
			return _currLoadedFileCount;
		}
		
		public function get currTotalFileCount():int
		{
			return _currTotalFileCount;
		}
		
		public function get currLoadPercentage():Number
		{
			return _tempLoadPercentage;
		}
		
		public function get isLoading():Boolean
		{
			return _isLoading;
		}
	}
}