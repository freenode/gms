 function transferPage() {
    var action_transfer = document.getElementById('action_transfer');
    var action_drop = document.getElementById('action_drop');

    action_transfer.onclick = function() {
        toggleAction();
    }
    action_drop.onclick = function() {
        toggleAction();
    }

    toggleAction();
}

function toggleAction() {
    var action_transfer = document.getElementById('action_transfer');
    var action_drop = document.getElementById('action_drop');

    if (action_transfer.checked) {
        showTransfer(true);
    } else {
        showTransfer(false);
    }
}

function showTransfer(show) {
    if (show) {
        $("#transfer").show(400);
    } else {
        $("#transfer").hide(400);
    }
}

addEventHandler ( window, 'load', function() {
    setTimeout (
            function() {
                transferPage();
            },
    1);
});
