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
