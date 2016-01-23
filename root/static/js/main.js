function getId (elem, id) {
    var children = elem.getElementsByTagName('*');
    var len = children.length;

    for ( var i = 0; i < len; i++ ) {
        if ( children[i].getAttribute('id') === id ) {
            return children[i];
        }
    }

    return false;
}

function remove (elem) {
    elem.parentNode.removeChild(elem);
}

function IE() {
    var matches = navigator.userAgent.match (/MSIE ([0-9]+)/);

    if (!matches || matches.length < 2) {
        return false;
    }

    var version = matches[1];
    return parseInt (version, 10);
}

if ( IE() !== false && IE() < 10 ) {
    document.getElementsByName = function(name) {
        var ret = [];
        var elems = document.getElementsByTagName("*");

        for ( var i = 0; i < elems.length; i++ ) {
            if ( elems[i].name === name || elems[i].getAttribute('name') === name ) {
                ret.push (elems[i]);
            }
        }

        return ret;
    }

    document.getElementsByClassName = function(name) {
        var ret = [];
        var elems = document.getElementsByTagName("*");

        for ( var i = 0; i < elems.length; i++ ) {
            if ( elems[i].className === name || elems[i].getAttribute('class') === name ) {
                ret.push (elems[i]);
            }
        }

        return ret;
    }
}

function show(elem_id) {
    var elem = document.getElementById("hidden_" + elem_id);
    var link = document.getElementById("link_" + elem_id); //'expand' link
    elem.className = ""; //remove the 'hidden' className so the element is visible again.

    if (link) {
        link.innerHTML = "Shrink";
        link.setAttribute("onclick", "hide(" + elem_id + ")");
    }
}

function hide(elem_id) {
    var elem = document.getElementById("hidden_" + elem_id);
    var link = document.getElementById("link_" + elem_id);
    elem.className = "hidden";

    if (link) {
        link.innerHTML = "Expand";
        link.setAttribute("onclick", "show(" + elem_id + ")");
    }
}

function tooltip (elem, id) {
    untooltip();
    var div = document.createElement ("div");
    div.className = "gtooltip";
    div.id = "tooltip";

    var parent = elem.parentNode;

    /* get the position of the table row the tooltip image is in. */
    var x = parent.getBoundingClientRect().left;
    var y = parent.getBoundingClientRect().top;

    /* how much the user has scrolled, annoyingly different for some browsers */
    var scrollX = (window.scrollX?window.scrollX:document.documentElement.scrollLeft);
    var scrollY = (window.scrollY?window.scrollY:document.documentElement.scrollTop);

    /* position the element */
    div.style.position = "absolute";
    div.style.left = (x + scrollX) + 'px';
    div.style.top = (y + 25 + scrollY) + 'px';

    var windowWidth = document.documentElement.offsetWidth;

    div.style.maxWidth = (windowWidth - x - 50) + 'px';

    /* the texts are located in hidden elements to make code a bit clearer
       than it would be if we passed them to the function */
    var text = document.getElementById('tooltipText' + id).innerHTML;

    div.innerHTML = text;
    document.body.appendChild (div);
}

function untooltip () {
    var elem;

    if ( ( elem = document.getElementById ("tooltip") ) ) {
        elem.parentNode.removeChild(elem);
    }
}

function getXmlHttpObject () { //Get the appropriate object to do AJAX requests.
    var xmlHttp = false;

    try {
        xmlHttp = new XMLHttpRequest(); //IE 7+, and everything else that does AJAX
    } catch (e) {
        try {
            xmlHttp = new ActiveXObject ("Microsoft.XMLHTTP"); //IE < 7
        } catch (e) { //AJAX isn't supported at all
        }
    }

    return xmlHttp;
}

function sendAjaxRequest (url, method, params, func) {
    /*
        url - the URL to load
        method - GET or POST
        params - An object representing the body post parameters, e.g.:
        {
            'name': 'erry',
            'age':  12,
        }
        func - the function to be called when the AJAX request is done
        It should accept a parameter so that it gets the xmlHttp response
        and does something with it.

        sendAjaxRequest (
            "/group/1/edit",
            "POST",
            {
                'name':'group1',
                'address':Address here"
            },
            function (xmlHttp) {
                document.getElementById('response').innerHTML = xmlHttp.responseText;
            }
        );
    */

    var xmlHttp = getXmlHttpObject();

    if (!xmlHttp) { //AJAX isn't supported
        return;
    }

    if (!url.match(/\?/))
      url += "?r=" + (new Date()).getTime();
    else
      url += "&r=" + (new Date()).getTime();

    xmlHttp.open (method, url, true); //the url and method (GET/POST)

    xmlHttp.onreadystatechange =  //the state of the request has changed
        function () {
            if (xmlHttp.readyState == 4) { //finished loading
                func (xmlHttp); //call the provided function
            }
        }

    if (method == "POST") {
        if ( ( tokenElem = document.getElementById('token') ) ) { //there should be a hidden input#token with the token
            token = tokenElem.value;
        } else {
            return;
        }

        var paramString = '';

        for ( var key in params ) {
            paramString += ( paramString === '' ? '' : '&' ) + key + '=' + encodeURIComponent (params[key]);
        }

        paramString += ( paramString === '' ? '' : '&' ) + "_token=" + token;
        paramString += "&ajax=1";

        xmlHttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        xmlHttp.send (paramString);
    } else {
        xmlHttp.send (null);
    }
}

function approveCloak (id, action) {
    sendAjaxRequest (
        format_user_cloak_url(id),
        "POST",
        {
            'action': action
        },
        function( xmlHttp ) {
            document.getElementsByClassName ("content")[0].innerHTML = xmlHttp.responseText;
        });
}

function addEventHandler (elem, eventType, handler) {

    if ( elem.addEventListener ) {
        elem.addEventListener ( eventType, handler, false );
    } else if (elem.attachEvent) {
        elem.attachEvent ( 'on'+ eventType, handler );
    }
}

