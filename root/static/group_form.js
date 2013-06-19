var groups_have_address = [ 'corporation', 'education', 'nfp', 'government' ];

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
}

function group_has_address ( group_type ) {
    var length = groups_have_address.length;

    for ( var i = 0; i < length; i++) {
        if ( groups_have_address[i] === group_type ) {
            return true;
        }
    }

    return false;
}

function displayAddr(show) {
    var addrElems = document.getElementsByName('addr_hide');
    var len = addrElems.length;

    for ( var i = 0; i < len; i++ ) {
        var elem = addrElems[i];
        elem.style.display = ( show?"":"none");
    }
    if ( document.getElementById('update_address') ) {
        document.getElementById('update_address').setAttribute ('checked', 'checked');
    }

    if ( show ) {
        document.getElementById('has_address_n').removeAttribute('checked');
        document.getElementById('has_address_y').setAttribute('checked', 'checked');
    } else {
        document.getElementById('has_address_y').removeAttribute('checked');
        document.getElementById('has_address_n').setAttribute('checked', 'checked');
    }
}

function groupPage() {
    displayAddr(false);
    document.getElementById('address_input').style.display = 'none'

    var group_type = document.getElementById('group_type');
    group_type.onchange = function() {
        groupTypeChange();
    }
}

function groupTypeChange() {
    var group_type = document.getElementById('group_type');
    var type = group_type.value;
    var show = false;

    if ( group_has_address ( type ) ) {
        displayAddr(true);
    } else {
        displayAddr(false);
    }
}

addEventHandler ( window, 'load', function() {
    setTimeout (
            function() {
                groupPage();
                groupTypeChange();
            },
    1);
});
