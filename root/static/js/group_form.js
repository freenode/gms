var groups_have_address = [ 'corporation', 'education', 'nfp', 'government' ];

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
        if ( show ) {
            $(elem).show(400);
        } else {
            $(elem).hide(400);
        }
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
    $('#address_input').hide(400);

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
