//function addEventHandler (elem, eventType, handler) {
var count = 1;
var numElems = 0;

function removeBox (elem) {
    if ( numElems == 0) {
        alert("You can't remove the last one!");
        return;
    }

   var parent = elem.parentNode.parentNode;

    if ( parent.id !== __ID_CLOAK ) {
        remove(parent);
    } else {
        /* keep the node, so that we can use it as a template,
         * but remove the values from its inputs */

        var account_input = getId ( parent, __ID_ACCOUNTNAME );
        account_input.setAttribute('value', '');
        account_input.value = '';

        var cloak_input = getId (parent, __ID_USERCLOAK);
        cloak_input.setAttribute('value','');
        cloak_input.value = '';

        parent.className = __CLASS_HIDDEN;

    }

    --numElems;
}

addEventHandler ( window, 'load', function() {
    setTimeout ( function() {
        addButtonClick ()
    }, 1 );
});

function addAnother() {
    var container = document.getElementById(__ID_CLOAK_CONTAINER);
    var cloak = document.getElementById(__ID_CLOAK);

    var elem = cloak.cloneNode ( true );
    elem.removeAttribute ('id');
    elem.className = __CLASS_CLOAK;

    var account_input = getId (elem, __ID_ACCOUNTNAME );
    account_input.setAttribute ('name', __NAME_ACCOUNTNAME + count);
    account_input.setAttribute('value', '');
    account_input.value = '';
    account_input.removeAttribute('id');

    var cloakns_input = getId  (elem, __ID_CLOAKNS);
    cloakns_input.setAttribute('name', __NAME_CLOAKNS + count);
    cloakns_input.selectedIndex = document.getElementById(__ID_CLOAKNS).selectedIndex;
    cloakns_input.removeAttribute('id');

    var cloak_input = getId (elem, __ID_USERCLOAK);
    cloak_input.setAttribute('name', __NAME_CLOAK + count);
    cloak_input.setAttribute('value','');
    cloak_input.value = '';
    cloak_input.removeAttribute('id');

    container.appendChild(elem);
    account_input.focus();

    document.getElementById(__ID_NUM_CLOAKS).setAttribute('value', ++count);
    ++numElems;
}

function addButtonClick() {
    var input = document.getElementById(__ID_BTN_ADD);
    addEventHandler ( input, 'click', function() {
        addAnother();
    } );
}
