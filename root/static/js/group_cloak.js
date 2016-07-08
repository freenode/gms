//function addEventHandler (elem, eventType, handler) {
var count = 1;
var numElems = 0;

function removeBox (elem) {
    if ( numElems == 0) {
        alert("You can't remove the last one!");
        return;
    }

    var parent = elem.parentNode.parentNode.parentNode.parentNode.parentNode;

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

/* Adds a new set of fields on the user cloak request form
 * if requested is true, the fields are added regardless of the value of others
 */
function addAnother(requested) {
    /* Default parameter value */
    if(requested === undefined) {
        requested = false;
    }

    var container = document.getElementById(__ID_CLOAK_CONTAINER);
    var cloak = document.getElementById(__ID_CLOAK + 0);

    /* Lookup all 'usercloakn' fields and check if empty */
    var one_is_empty = false;
    for(var i = 0; i < count && !one_is_empty; ++i) {
        var usercloak = document.getElementById(__ID_USERCLOAK + i);
        var value = usercloak.value;
        one_is_empty = one_is_empty || (value == "");
    }

    /* Do not add anything if all fields are not yet filled
     * if requested then user asked manually, add regardless */
    if(requested || (!requested && !one_is_empty)) {
        var elem = cloak.cloneNode ( true );
        elem.setAttribute('id', __ID_CLOAK + count);

        /* account */
        var account_input = getId (elem, __ID_ACCOUNTNAME + 0);
        account_input.setAttribute ('name', __NAME_ACCOUNTNAME + count);
        account_input.setAttribute('value', '');
        account_input.value = '';
        account_input.setAttribute('id', __ID_ACCOUNTNAME + count);

        /* cloak namespace */
        var cloakns_input = getId  (elem, __ID_CLOAKNS + 0);
        cloakns_input.setAttribute('name', __NAME_CLOAKNS + count);
        cloakns_input.selectedIndex = document.getElementById(__ID_CLOAKNS + (count - 1)).selectedIndex;
        cloakns_input.setAttribute('id', __ID_CLOAKNS + count);

        /* role/user */
        var cloak_input = getId (elem, __ID_USERCLOAK + 0);
        cloak_input.setAttribute('name', __NAME_CLOAK + count);
        cloak_input.setAttribute('value','');
        cloak_input.value = '';
        cloak_input.setAttribute('id', __ID_USERCLOAK + count);

        container.appendChild(elem);
        account_input.focus();

        document.getElementById(__ID_NUM_CLOAKS).setAttribute('value', ++count);
        ++numElems;
    }
}

function addButtonClick() {
    var input = document.getElementById(__ID_BTN_ADD);
    addEventHandler ( input, 'click', function() {
        addAnother(true);
    } );
}
