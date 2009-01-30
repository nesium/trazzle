var logList;

onload = function()
{
	logList = document.getElementById('logMessageList');
}

function appendLogMessages(messages)
{
	var html = '';
	for (var i = 0; i < messages.length; i++)
	{
		var message = messages[i];
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
		html += '<div class="timestamp">' + message.timestamp + '</div>';
		html += '<div class="content ' + message.levelName + '">';
		html += message.className + '.' + message.method + ' (' + message.line + ') ' + 
			message.message;
		html += '</div></li>';
		window.TrazzleBridge.log(html);
	}
	appendHTML(html);
}

function appendSystemMessages(messages)
{
	var html = '';
	var i = 0;
	
	for (; i < messages.length; i++)
	{
		var message = messages[i];
		html += '<li class="system_message">'
		html += '<div class="content">' + message.message + '</div>';
		html += '</li>';
	}
	appendHTML(html);
}

function appendHTML(html)
{
	var range = document.createRange();
	range.selectNode(logList);
	var documentFragment = range.createContextualFragment(html);
	logList.appendChild(documentFragment);
	document.body.scrollTop = document.body.offsetHeight;	
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

	var message = window.TrazzleBridge.logMessageAtIndex(id);
	var html = '<ul class="stacktrace">';
	for (i = 0; i < message.stacktrace.length; i++)
	{
		var stackItem = message.stacktrace[i];
		html += '<li>' + stackItem.className + '.' + stackItem.method + 
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