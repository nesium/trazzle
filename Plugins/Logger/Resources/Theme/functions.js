var logList;

var kLPMessageTypeSystem = 0;
var kLPMessageTypeFlashLog = 1;
var kLPMessageTypeCommand = 2;
var kLPMessageTypeSocket = 3;
var kLPMessageTypePolicyRequest = 4;
var kLPMessageTypeStackTrace = 5;
var kLPMessageTypeConnectionSignature = 6;
var kLPMessageTypeException = 7;
var kLPMessageTypeBitmap = 8;

onload = function()
{
	logList = document.getElementById('logMessageList');
}

function appendMessages(messages)
{
	var html = '';
	var addTextmateLinks = window.TrazzleBridge.textMateLinksEnabled();
	for (var i = 0; i < messages.length; i++)
	{
		var message = messages[i];
		switch (message.messageType)
		{
			case kLPMessageTypeSocket:
			case kLPMessageTypeException:
				html += logMessageToHTML(message, addTextmateLinks);
				break;
			default:
				html += messageToHTML(message);
		}
	}
	appendHTML(html);
}

function logMessageToHTML(message, addTextmateLinks)
{
	var html = '';
	html += '<li class="trace' + (message.visible ? '' : ' hidden') + 
		'" id="traceItem' + message.index + '">';
	html += '<div class="arrow">';
	if (message.stacktrace)
	{
		html += '<a href="javascript:toggleStacktrace(' + message.index + ');" class="arrow">';
		html += '&nbsp;';
		html += '</a>';
	}
	else
	{
		html += '&nbsp;';
	}
	html += '</div>';
	html += '<div class="lineno">' + (message.index + 1) + '</div>';
	html += '<div class="timestamp">' + message.formattedTimestamp() + '</div>';
	html += '<div class="content ' + message.levelName + '">';
	if (addTextmateLinks && message.line > -1 && message.fileExists)
	{
		html += '<a class="tm_link" href="txmt://open/?url=file://' + escape(message.file) + 
			'&line=' + message.line + '">';
	}
	if (message.shortClassName && message.method) 
		html += message.shortClassName + '.' + message.method + ' ';
	if (message.line > -1)
		html += '(' + message.line + ') '; 
	html += message.message;
	if (addTextmateLinks && message.line > -1)
	{
		html += '</a>';
	}
	html += '</div></li>';
	return html;
}

function messageToHTML(message)
{
	var html = '';
	var cssClass = message.messageType == kLPMessageTypeSystem 
		? "system_message" 
		: "flashlog_message";
	html += '<li class="' + cssClass + (message.visible ? '' : ' hidden') + '">'
	html += '<div class="lineno">' + (message.index + 1) + '</div>';
	html += '<div class="content">' + message.message + '</div>';
	html += '</li>';
	return html;
}

function appendHTML(html)
{
	var shouldScroll = scrollThumbIsAtBottom();
	var range = document.createRange();
	range.selectNode(logList);
	var documentFragment = range.createContextualFragment(html);
	logList.appendChild(documentFragment);
	if (shouldScroll) scrollToBottom();
}

function scrollThumbIsAtBottom()
{
//	TrazzleBridge.log(
//		'scrollTop: ' + document.body.scrollTop + 
//		', clientHeight: ' + document.body.clientHeight + 
//		', offsetHeight: ' + document.body.offsetHeight + 
//		', scrollWidth: ' + document.body.scrollWidth + 
//		', innerWidth: ' + window.innerWidth + 
//		', innerHeight: ' + window.innerHeight + 
//		', scrollHeight: ' + document.body.scrollHeight + 
//		', scrollTop: ' + document.body.scrollTop + 
//		', scrollLeft: ' + document.body.scrollLeft + 
//		', scrollTopDif: ' + (document.body.scrollTop - window.innerHeight) + 
//		', dings: ' + (document.body.scrollHeight - document.body.scrollTop));
//	
//	return document.body.scrollTop + window.innerHeight == document.body.offsetHeight || 
//	document.body.offsetHeight < window.innerHeight;
	return document.body.scrollHeight - window.innerHeight - document.body.scrollTop <= 0;
}

function scrollToBottom()
{
	document.body.scrollTop = document.body.offsetHeight;
}

function showMessagesWithIndexes(indexes)
{
	var shouldScroll = scrollThumbIsAtBottom();
	var i = indexes.length;
	while (i--)
	{
		logList.childNodes[indexes[i]].style.display = 'block';
	}
	if (shouldScroll) scrollToBottom();
}

function hideMessagesWithIndexes(indexes)
{
	var shouldScroll = scrollThumbIsAtBottom();
	var i = indexes.length;
	while (i--)
	{
		logList.childNodes[indexes[i]].style.display = 'none';
	}
	if (shouldScroll) scrollToBottom();
}

function removeMessagesWithIndexes(indexes)
{
	var shouldScroll = scrollThumbIsAtBottom();
	var i = indexes.length;
	while (i--)
	{
		logList.removeChild(logList.childNodes[indexes[i]]);
	}
	if (shouldScroll) scrollToBottom();
}

function clearAllMessages()
{
	var i = logList.childNodes.length;
	while (i--)
	{
		logList.removeChild(logList.childNodes[i]);
	}
}


function toggleStacktrace(id)
{
	var elem = document.getElementById('traceItem' + id);
	var subListItems = elem.getElementsByTagName('ul');
	var i = subListItems.length;
	
	while (i--)
	{
		var ul = subListItems[i];
		if (ul.className == 'stacktrace')
		{
			removeClassFromElement(elem, 'expanded');
			elem.removeChild(ul);
			return;
		}
	}

	var addTextmateLinks = window.TrazzleBridge.textMateLinksEnabled();
	var message = window.TrazzleBridge.messageWithIndex(id);
	var html = '<ul class="stacktrace">';
	for (i = 0; i < message.stacktrace.length; i++)
	{
		var stackItem = message.stacktrace[i];
		html += '<li>';
		if (addTextmateLinks)
		{
			html += '<a class="tm_link" href="txmt://open/?url=file://' + escape(stackItem.file) + 
				'&line=' + stackItem.line + '">';
		}
		html += stackItem.shortClassName + '.' + stackItem.method + 
			' (' + stackItem.line + ')';
		if (addTextmateLinks)
		{
			html += '</a>';
		}
		html += '</li>';
	}
	html += '</ul>';
	
    var range = document.createRange();
    range.selectNode(elem);
    var documentFragment = range.createContextualFragment(html);
    elem.appendChild(documentFragment);
	addClassToElement(elem, 'expanded');
}

function removeClassFromElement(elem, clazz)
{
	var parts = elem.className.split(' ');
	var i = parts.length;
	while (i--)
	{
		if (parts[i] == clazz)
		{
			parts.splice(i, 1);
			break;
		}
	}
	elem.className = parts.join(' ');
}

function addClassToElement(elem, clazz)
{
	elem.className += ' ' + clazz;
}