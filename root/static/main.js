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
    div.className = "tooltip";
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
