var channels = [];

addEventHandler (window, 'load', function() {
    var channel = $('#' + __ID_CHANNEL);

    if ( channel ) {
        $(channel).typeahead ({
            source: getChannels,
            minLength: 1
        });
    }
});

function getChannels ( query, handler ) {
    if (channels.length != 0) {
        handler(channels);
        return;
    }

    sendAjaxRequest (
        format_group_id(__URL_GROUP_LISTCHANS, window.group_id),
        'POST',
        {
        },
        function(xmlHttp) {
            try {
                var json = JSON.parse ( xmlHttp.responseText );
                //cache
                channels = json.json_channels;
                handler ( channels );
            } catch (e) {
                if ( typeof console !== 'undefined' ) {
                    console.log (e);
                }
            }
        }
    );
}

