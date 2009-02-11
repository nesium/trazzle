var logList;

var kLPMessageTypeSystem = 0;
var kLPMessageTypeFlashLog = 1;
var kLPMessageTypeCommand = 2;
var kLPMessageTypeSocket = 3;
var kLPMessageTypePolicyRequest = 4;
var kLPMessageTypeStackTrace = 5;
var kLPMessageTypeConnectionSignature = 6;

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
	if (addTextmateLinks)
	{
		html += '<a class="tm_link" href="txmt://open/?url=file://' + escape(message.file) + 
			'&line=' + message.line + '">';
	}
	html += message.shortClassName + '.' + message.method + ' (' + message.line + ') ' + 
		message.message;
	if (addTextmateLinks)
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
	html += '<li class="' + cssClass + '">'
	html += '<div class="lineno">' + (message.index + 1) + '</div>';
	html += '<div class="content">' + message.message + '</div>';
	html += '</li>';
	return html;
}

function appendHTML(html)
{
	var shouldScroll = document.body.scrollTop + window.innerHeight == document.body.offsetHeight || 
		document.body.offsetHeight < window.innerHeight;
	var range = document.createRange();
	range.selectNode(logList);
	var documentFragment = range.createContextualFragment(html);
	logList.appendChild(documentFragment);
	if (shouldScroll) document.body.scrollTop = document.body.offsetHeight;
}

function showMessagesWithIndexes(indexes)
{
	var i = indexes.length;
	while (i--)
	{
		logList.childNodes[indexes[i]].style.display = 'block';
	}
}

function hideMessagesWithIndexes(indexes)
{
	var i = indexes.length;
	while (i--)
	{
		logList.childNodes[indexes[i]].style.display = 'none';
	}
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

	var message = window.TrazzleBridge.messageAtIndex(id);
	var html = '<ul class="stacktrace">';
	for (i = 0; i < message.stacktrace.length; i++)
	{
		var stackItem = message.stacktrace[i];
		html += '<li>' + stackItem.shortClassName + '.' + stackItem.method + 
			' (' + stackItem.line + ')</li>';
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