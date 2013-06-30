function handleJSON_approved ( text, type ) {
    var json;

    try {
        json = JSON.parse(text);
    } catch (e) {
        if (typeof console !== 'undefined') {
            console.log (e);
        }

        return;
    }

    if (json.json_error) {
        var error_container = document.getElementById ( __ID_ERROR_CONTAINER );
        if (error_container) {
            error_container.className = __CLASS_ERROR;
            error_container.innerHTML = __ERROR_TXT + __BR + json.json_error;
        }
    }

    var approved = ( json.json_approved ? json.json_approved : [] );
    var rejected = ( json.json_rejected ? json.json_rejected : [] );
    var verified = ( json.json_verified ? json.json_verified : [] );
    var applied  = ( json.json_applied  ? json.json_applied  : [] );
    var failed   = ( json.json_failed   ? json.json_failed   : [] );

    var approve_length = approved.length, reject_length = rejected.length, verify_length = verified.length,
    applied_length = applied.length, failed_length = failed.length;

    for ( var i = 0; i < approve_length; i++ ) {
        var id = approved[i];
        var elem;

        if ( ( elem = document.getElementById ( __ID_APPROVE + id ) ) ) {
            elem.removeAttribute('href');
            elem.removeAttribute('name');
            elem.onclick = function() { }
            elem.innerHTML = __ALREADY_APPROVED;
        }

        if ( ( elem = document.getElementById ( __ID_APPLY + id ) ) ) {
            elem.removeAttribute('href');
            elem.removeAttribute('name');
            elem.onclick = function() { }
            elem.innerHTML = __ALREADY_APPROVED;
        }

        if ( ( elem = document.getElementById ( __ID_VERIFY + id ) ) ) {
            elem.removeAttribute('href');
            elem.removeAttribute('name');
            elem.onclick = function() { }
            elem.innerHTML = __ALREADY_APPROVED;
        }

        if ( ( elem = document.getElementById ( __ID_REJECT + id ) ) ) {
            elem.removeAttribute('href');
            elem.removeAttribute('name');
            elem.onclick = function() { }
            elem.innerHTML = __ALREADY_APPROVED;
        }
    }

    for ( var i = 0; i < verify_length; i++ ) {
        var id = verified[i];
        var elem;

        if ( ( elem = document.getElementById ( __ID_VERIFY + id ) ) ) {
            elem.removeAttribute('href');
            elem.removeAttribute('name');
            elem.onclick = function() { }
            elem.innerHTML = __ALREADY_VERIFIED;
        }
    }

    for ( var i = 0; i < reject_length; i++ ) {
        var id = rejected[i];
        var elem;

        if ( ( elem = document.getElementById ( __ID_APPROVE + id) ) ) {
            elem.removeAttribute('href');
            elem.onclick = function() { }
            elem.removeAttribute('name');
            elem.innerHTML = __ALREADY_REJECTED;
        }

        if ( ( elem = document.getElementById ( __ID_APPLY + id ) ) ) {
            elem.removeAttribute('href');
            elem.onclick = function() { }
            elem.removeAttribute('name');
            elem.innerHTML = __ALREADY_REJECTED;
        }

        if ( ( elem = document.getElementById ( __ID_VERIFY + id ) ) ) {
            elem.removeAttribute('href');
            elem.onclick = function() { }
            elem.removeAttribute('name');
            elem.innerHTML = __ALREADY_REJECTED;
        }

        if ( ( elem = document.getElementById ( __ID_REJECT + id ) ) ) {
            elem.removeAttribute('href');
            elem.onclick = function() { }
            elem.removeAttribute('name');
            elem.innerHTML = __ALREADY_REJECTED;
        }
    }

    for ( var i = 0; i < applied_length; i++ ) {
        var id = applied[i];
        var elem;

        if ( ( elem = document.getElementById ( __ID_APPROVE + id) ) ) {
            elem.removeAttribute('href');
            elem.onclick = function() { }
            elem.removeAttribute('name');
            elem.innerHTML = __ALREADY_APPLIED;
        }

        if ( ( elem = document.getElementById ( __ID_APPLY + id ) ) ) {
            elem.removeAttribute('href');
            elem.onclick = function() { }
            elem.removeAttribute('name');
            elem.innerHTML = __ALREADY_APPLIED;
        }

        if ( ( elem = document.getElementById ( __ID_VERIFY + id ) ) ) {
            elem.removeAttribute('href');
            elem.onclick = function() { }
            elem.removeAttribute('name');
            elem.innerHTML = __ALREADY_APPLIED;
        }

        if ( ( elem = document.getElementById ( __ID_REJECT + id ) ) ) {
            elem.removeAttribute('href');
            elem.onclick = function() { }
            elem.removeAttribute('name');
            elem.innerHTML = __ALREADY_APPLIED;
        }
    }

    for ( var i = 0; i < failed_length; i++ ) {
        var id = failed[i];
        var elem;

        if ( ( elem = document.getElementById ( __ID_APPROVE + id) ) ) {
            elem.innerHTML = __RETRY;
        }

        if ( ( elem = document.getElementById ( __ID_APPLY + id ) ) ) {
            elem.href = 'javascript:;';
            elem.setAttribute ('name',__NAME_APPLY + type);
            elem.setAttribute ('value', id);
            elem.innerHTML = __APPLY;
        }
    }
}


function arrows(id, up) {
    var arrows = document.getElementsByName (__NAME_EXPAND);
    var len = arrows.length;

    for ( var i = 0; i < len; i++ ) {
        var arrow = arrows[i];

        if ( arrow.getAttribute ('value') !== id ) 
            continue;

        arrow.className = ( up ? __CLASS_ARROW_UP : __CLASS_ARROW_DOWN );
    }
}

function addClickToggle (elem, id) {
    elem.onclick = function() {
        var hidden = document.getElementById(__ID_HIDDEN + id);

        if (!hidden) {
            return;
        }

        if ( hidden.className === __CLASS_HIDDENDIV ) {
            hidden.className = '';
            arrows (id, true);
        } else {
            hidden.className = __CLASS_HIDDENDIV;
            arrows (id, false);
        }
    }
}

function prepareExpands() {
    var elems = document.getElementsByName(__NAME_EXPAND);
    var len = elems.length;

    for ( var i = 0; i < len; i++ ) {
        var elem = elems[i];
        addClickToggle(elem, elem.getAttribute('value'));
    }
}

function addClickAction (elem, id, type, action, extraData) {
    elem.onclick = function() {
        approve (id, type, action, extraData);
    }
}

function prepareActions(type, action, extraData) {
    var name = action + '_' + type + ( extraData ? '_' + extraData : '' );
    //approve_group
    //approve_cloak
    //approve_change_cc

    var elems = document.getElementsByName(name);
    var len = elems.length;

    for ( var i = 0; i < len; i++ ) {
        var elem = elems[i];
        addClickAction(elem, elem.getAttribute('value'), type, action, extraData);
    }
}

function approve ( id, type, action, extraData ) {
    var post = {};
    var freetext = (
        document.getElementById (__ID_FREETEXT + id) && document.getElementById(__ID_FREETEXT + id).value
         ? document.getElementById(__ID_FREETEXT + id).value
         : ''
    );

    post['action_' + id] = action;
    post['freetext_' + id] = freetext;
    var url;

    switch ( type ) {
        case __TYPE_GROUP:
            url = __URL_ADMIN_SUBMIT_GROUP;
            post['approve_groups'] = id;
        break;
        case __TYPE_CHANGE:
            url = __URL_ADMIN_SUBMIT_CHNG;
            post['approve_changes'] = id;
            if ( extraData ) {
                post['change_item'] = extraData;
            }
        break;
        case __TYPE_CLOAK:
            url = __URL_ADMIN_SUBMIT_CLOAK;
            post['approve_changes'] = id;
        break;
        case __TYPE_CHANNEL:
            url = __URL_ADMIN_SUBMIT_CHAN;
            post['approve_requests'] = id;
        break;
        case __TYPE_NAMESPACE:
            url = __URL_ADMIN_SUBMIT_NS;
            post['approve_namespaces'] = id;
            if ( extraData ) {
                post['approve_item'] = extraData;
            }
        break;
        case __TYPE_NEW_GC:
            url = __URL_ADMIN_SUBMIT_GCA;
            post['approve_contacts'] = id;
        break;
    }

    sendAjaxRequest (url, 'POST', post, function(xmlHttp) {
        handleJSON_approved (xmlHttp.responseText, type);
        pageLoad ( type, extraData );
    });
}

function pageLoad ( type, extraData ) {
    prepareExpands();

    prepareActions(type, __ACTION_APPLY, extraData);
    prepareActions(type, __ACTION_APPROVE, extraData);
    prepareActions(type, __ACTION_REJECT, extraData);
    prepareActions(type, __ACTION_VERIFY, extraData);
}
