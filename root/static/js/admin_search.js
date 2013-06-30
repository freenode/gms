addEventHandler (window, 'load', function() {
    var gname = $('.' + __CLASS_GROUPNAME);

    if ( gname ) {
        $(gname).typeahead ({
            source: getGroupName,
            minLength: 3
        });
    }

    var accname = $('.' + __CLASS_ACCOUNTNAME);

    if ( accname ) {
        $(accname).typeahead ({
            source: getAccountName,
            minLength: 3
        });
    }

    var ns = $('.' + __CLASS_NS);

    if ( ns ) {
        $(ns).typeahead ({
            source: getNSName,
            minLength: 3
        });
    }

    var fullname = $('.' + __CLASS_FULLNAME);

    if ( fullname ) {
        $(fullname).typeahead ({
            source:getFullName,
            minLength: 3
        });
    }
});

function getAccountName ( query, handler ) {
    sendAjaxRequest (
        __URL_STAFF_ACCOUNTNAME,
        'POST',
        {
            'name': query
        },
        function(xmlHttp) {
            try {
                var json = JSON.parse ( xmlHttp.responseText );
                handler ( json.json_accounts );
            } catch (e) {
                if ( typeof console !== 'undefined' ) {
                    console.log (e);
                }
            }
        }
    );
}

function getFullName ( query, handler ) {
    sendAjaxRequest (
        __URL_STAFF_FULLNAME,
        'POST',
        {
            'name': query
        },
        function(xmlHttp) {
            try {
                var json = JSON.parse ( xmlHttp.responseText );
                handler ( json.json_names );
            } catch (e) {
                if ( typeof console !== 'undefined' ) {
                    console.log (e);
                }
            }
        }
    );
}

function getGroupName ( query, handler ) {
    sendAjaxRequest (
        __URL_STAFF_GROUPNAME,
        'POST',
        {
            'name': query
        },
        function(xmlHttp) {
            try {
                var json = JSON.parse ( xmlHttp.responseText );
                handler ( json.json_groups );
            } catch (e) {
                if ( typeof console !== 'undefined' ) {
                    console.log (e);
                }
            }
        }
    );
}

function getNSName ( query, handler ) {
    sendAjaxRequest (
        __URL_STAFF_NS,
        'POST',
        {
            'name': query
        },
        function(xmlHttp) {
            try {
                var json = JSON.parse ( xmlHttp.responseText );
                handler ( json.json_namespaces );
            } catch (e) {
                if ( typeof console !== 'undefined' ) {
                    console.log (e);
                }
            }
        }
    );
}
