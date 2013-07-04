function handleJSON_list ( text, type ) {
    var resp_elem = document.getElementById('response_' + type);
    resp_elem.innerHTML = '';
    var json;

    try {
        json = JSON.parse (text);
    } catch (e) {
        if (typeof console !== "undefined") {
            console.log (e);
        }

        return;
    }

    var to_approve = json.json_to_approve;
    var length = to_approve.length;

    if ( type === __TYPE_CHANGE ) {
        html = format_change ( json );
        resp_elem.innerHTML = html;
        return;
    }

    if ( length === 0 ) {
        resp_elem.innerHTML = format_no_requests (type);
        return;
    }

    var html;

    if ( type === __TYPE_GROUP ) {
        html = format_mass_action(type, __ACTION_VERIFY);
    } else if ( type === __TYPE_CHANNEL || type === __TYPE_CLOAK ) {
        html = format_mass_action(type, __ACTION_APPLY);
    } else {
        html = format_mass_action(type);
    }

    resp_elem.innerHTML += html;

    for ( var i = 0; i < length; i++ ) {
        var approve = to_approve[i];
        html = '';

        if ( type === __TYPE_CC ) {
            html = format_cc ( approve );
        } else if ( type === __TYPE_CHANNEL ) {
            html = format_channel ( approve );
        } else if ( type === __TYPE_CLOAK ) {
            html = format_cloak ( approve );
        } else if ( type === __TYPE_CNC || type === __TYPE_CLNC ) {
            html = format_nsc ( approve, type );
        } else if ( type === __TYPE_CNS || type === __TYPE_CLNS ) {
            html = format_namespace ( approve, type );
        } else if ( type === __TYPE_GC ) {
            html = format_gc ( approve );
        } else if ( type === __TYPE_GCC ) {
            html = format_gcc ( approve );
        } else if ( type === __TYPE_GROUP ) {
            html = format_group ( approve );
        } else if ( type === __TYPE_NEW_GC ) {
            html = format_new_gc ( approve );
        }

        resp_elem.innerHTML += html;
    }
}

function prepareLinks() {
    var elems = document.getElementsByName(__NAME_EXPAND_APPROVE);

    for ( var i = 0; i < elems.length; i++ ) {
        var elem = elems[i];
        addClickExpand (elem, elem.getAttribute('value'));
    }
}

function addClickExpand (elem, type) {
    var url;

    switch (type) {
        case __TYPE_CC:
            url = __URL_ADMIN_APPROVE_CC;
        break;
        case __TYPE_CHANGE:
            url = __URL_ADMIN_APPROVE_CHNG;
        break;
        case __TYPE_CHANNEL:
            url = __URL_ADMIN_APPROVE_CHAN;
        break;
        case __TYPE_CLNC:
            url = __URL_ADMIN_APPROVE_CLNC;
        break;
        case __TYPE_CLNS:
            url = __URL_ADMIN_APPROVE_CLNS;
        break;
        case __TYPE_CLOAK:
            url = __URL_ADMIN_APPROVE_CLOAK;
        break;
        case __TYPE_CNC:
            url = __URL_ADMIN_APPROVE_CNC;
        break;
         case __TYPE_CNS:
            url = __URL_ADMIN_APPROVE_CNS;
        break;
        case __TYPE_GC:
            url = __URL_ADMIN_APPROVE_GC;
        break;
        case __TYPE_GCC:
            url = __URL_ADMIN_APPROVE_GCC;
        break;
        case __TYPE_GROUP:
            url = __URL_ADMIN_APPROVE_GROUP;
        break;
        case __TYPE_NEW_GC:
            url = __URL_ADMIN_APPROVE_GCA;
        break;
    }

    if ( document.getElementById ('response_' + type) ) {
        var resp_elem = document.getElementById('response_' + type);

        elem.onclick = function() {
            if ( elem.className === __CLASS_ARROW_DOWN ) {
                elem.className = __CLASS_ARROW_UP;
            } else if ( elem.className === __CLASS_ARROW_UP ) {
                elem.className = __CLASS_ARROW_DOWN;
            }

            if (!resp_elem.innerHTML) {
                sendAjaxRequest (url, 'GET', {}, function(xmlHttp) {
                    var response = xmlHttp.responseText;
                    handleJSON_list ( response, type );

                    prepareLinks();
                    afterLoad();
                });
            } else {
                resp_elem.innerHTML = '';
            }
        }
    }
}

function afterLoad() {
    pageLoad(__TYPE_GROUP);
    pageLoad(__TYPE_NEW_GC);
    pageLoad(__TYPE_CHANGE, __TYPE_CC);
    pageLoad(__TYPE_CHANGE, __TYPE_CLNC);
    pageLoad(__TYPE_CHANGE, __TYPE_CNC);
    pageLoad(__TYPE_CHANGE, __TYPE_GC);
    pageLoad(__TYPE_CHANGE, __TYPE_GCC);
    pageLoad(__TYPE_NAMESPACE, __TYPE_CLNS);
    pageLoad(__TYPE_NAMESPACE, __TYPE_CNS);
    pageLoad(__TYPE_CLOAK);
    pageLoad(__TYPE_CHANNEL);
}

addEventHandler ( window, 'load', function() {
    setTimeout (
        function() {
            prepareLinks ();
        },
    1);
});
