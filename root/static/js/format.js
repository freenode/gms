//http://stackoverflow.com/a/4835406/5875631
function escapeHtml(text) {
  text = "" + text;

  var map = {
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#039;'
  };

  return text.replace(/[&<>"']/g, function(m) { return map[m]; });
}

function format_account_drop ( account ) {
    var html = __TEMPLATE_ACCOUNT_DROPPED;

    html = html.replace (/%dropped_account/g, escapeHtml(account));
    return html;
}

function format_address ( address ) {
    var html = __TEMPLATE_ADDRESS;

    html = html.replace (/\%addr1/g, escapeHtml(address.address_one));
    html = html.replace (/\%addr2/g, escapeHtml(address.address_two));
    html = html.replace (/\%city/g, escapeHtml(address.city));
    html = html.replace (/\%state/g, escapeHtml(address.state));
    html = html.replace (/\%code/g, escapeHtml(address.code));
    html = html.replace (/\%country/g, escapeHtml(address.country));
    html = html.replace (/\%phone2/g,  escapeHtml(address.phone2));
    html = html.replace (/\%phone/g, escapeHtml(address.phone));

    return html;
}

function format_address_change ( new_address, old_address ) {
    var html;

    if ( old_address ) {
        html = __ADDRESS_UPDATED;
    } else {
        html = __ADDRESS_ADDED;
    }

    if (!new_address) {
        html += __ADDRESS_REMOVED;
        return html;
    } else {
        html += format_address ( new_address );
    }

    return html;
}

function format_cc ( change ) {
    var html = __TEMPLATE_CC;

    html = html.replace (/\%req_type/g, __TYPE_CHANGE + "_" + __TYPE_CC);
    html = html.replace (/\%id/g, escapeHtml(change.id));
    html = html.replace (/\%account_id/g, escapeHtml(change.contact_account_id));
    html = html.replace (/\%account_name/g, escapeHtml(change.contact_account_name));

    if ( change.name !== change.contact_name ) {
        html = html.replace (/\%name_changed/g, format_name_change ( change.name, change.contact_name ) );
    } else {
        html = html.replace (/\%name_changed/g,'');
    }

    if ( change.email !== change.contact_email ) {
        html = html.replace (/\%email_changed/g, format_email_change (change.email, change.contact_email));
    } else {
        html = html.replace (/\%email_changed/g, '');
    }

    if ( change.phone !== change.contact_phone ) {
        html = html.replace ( /\%phone_changed/g, format_phone_change ( change.phone, change.contact_phone ) );
    } else {
        html = html.replace ( /\%phone_changed/g, '' );
    }

    if ( change.contact_account_dropped ) {
        html = html.replace ( /\%requestor_account_dropped/g, format_account_drop ( change.contact_account_name ) );
    } else {
        html = html.replace ( /\%requestor_account_dropped/g, '' );
    }

    return html;
}

function format_change ( json ) {
    var html = __TEMPLATE_CHANGES;

    html = html.replace (/\%pending_gcc/, escapeHtml(json.json_pending_groupcontact));
    html = html.replace (/\%pending_gc/, escapeHtml(json.json_pending_group));
    html = html.replace (/\%pending_cc/, escapeHtml(json.json_pending_contact));
    html = html.replace (/\%pending_cnc/, escapeHtml(json.json_pending_cns));
    html = html.replace (/\%pending_clnc/, escapeHtml(json.json_pending_clns));

    return html;
}

function format_gc ( change ) {
    var html = __TEMPLATE_GC;

    html = html.replace (/\%req_type/g, __TYPE_CHANGE + "_" + __TYPE_GC);
    html = html.replace (/\%id/g, escapeHtml(change.id));
    html = html.replace (/\%group_id/g, escapeHtml(change.group_id));
    html = html.replace (/\%group_name/g, escapeHtml(change.group_name));
    html = html.replace (/\%group_url/g, escapeHtml(change.group_url));

    if ( change.type !== change.group_type ) {
        html = html.replace (/\%type_changed/g, format_type_change ( change.type, change.group_type ) );
    } else {
        html = html.replace (/\%type_changed/g,'');
    }

    if ( change.url !== change.group_url ) {
        html = html.replace (/\%url_changed/g, format_url_change (change.url, change.group_url));
    } else {
        html = html.replace (/\%url_changed/g, '');
    }

    if ( change.address !== change.group_address ) {
        html = html.replace ( /\%address_changed/g, format_address_change ( change.address, change.group_address ) );
    } else {
        html = html.replace ( /\%address_changed/g, '' );
    }

    return html;
}

function format_user_cloak_url ( id ) {
    var url = __URL_USER_ACCEPT_CLOAK;

    url = url.replace (/\%id/g, escapeHtml(id));
    return url;
}

function format_gcc ( change ) {
    var html = __TEMPLATE_GCC;

    html = html.replace (/\%req_type/g, __TYPE_CHANGE + "_" + __TYPE_GCC);
    html = html.replace (/\%id/g, escapeHtml(change.id));
    html = html.replace (/\%account_id/g, escapeHtml(change.contact_account_id));
    html = html.replace (/\%account_name/g, escapeHtml(change.contact_account_name));
    html = html.replace (/\%group_id/g, escapeHtml(change.group_id));
    html = html.replace (/\%group_name/g, escapeHtml(change.group_name));
    html = html.replace (/\%group_url/g, escapeHtml(change.group_url));

    if ( change.status !== change.gc_status ) {
        html = html.replace ( /\%status_changed/, format_status_change ( change.status, change.gc_status ) );
    } else {
        html = html.replace ( /\%status_changed/, '');
    }

    if ( change.primary !== change.gc_primary ) {
        html = html.replace ( /\%primary_changed/, format_primary_change ( change.primary, change.gc_primary ) );
    } else {
        html = html.replace ( /\%primary_changed/, '');
    }

    if ( change.contact_account_dropped ) {
        html = html.replace ( /\%target_account_dropped/g, format_account_drop ( change.contact_account_name ) );
    } else {
        html = html.replace ( /\%target_account_dropped/g, '' );
    }

    return html;
}

function format_group_change ( new_group, old_group ) {
    var html = __GROUP_CHANGED;

    html = html.replace (/\%old_group_id/g, escapeHtml(old_group.id));
    html = html.replace (/\%old_group/g, escapeHtml(old_group.name));

    html = html.replace (/\%new_group_id/g, escapeHtml(new_group.id));
    html = html.replace (/\%new_group/g, escapeHtml(new_group.name));

    return html;
}

function format_group ( group ) {
    var html;

    if ( group.status === __STATUS_PENDING_STAFF ) {
        html = __TEMPLATE_PENDING_GROUP;
    } else {
        html = __TEMPLATE_VERIFIED_GROUP;
    }

    html = html.replace (/\%req_type/g, __TYPE_GROUP);
    html = html.replace (/\%id/g, escapeHtml(group.id));
    html = html.replace (/\%group_id/g, escapeHtml(group.id));
    html = html.replace (/\%group_name/g, escapeHtml(group.name));
    html = html.replace (/\%group_initial_contact/g, escapeHtml(group.initial_contact_account_name));
    html = html.replace (/\%account_id/g, escapeHtml(group.initial_contact_account_id));
    html = html.replace (/\%initial_channel_namespaces/g, escapeHtml(group.channel_namespaces.map(function(ns) { return "#" + ns; }).join(", ")));
    html = html.replace (/\%group_url/g, escapeHtml(group.url));
    html = html.replace (/\%group_type/g, escapeHtml(group.type));

    if ( group.initial_contact_account_dropped ) {
        html = html.replace ( /\%requestor_account_dropped/g, format_account_drop ( group.initial_contact_account_name ) );
    } else {
        html = html.replace ( /\%requestor_account_dropped/g, '' );
    }

    return html;
}

function format_group_id (text, group_id) {
    text = text.replace(/\%group_id/g, escapeHtml(group_id));
    return text;
}

function format_email_change ( new_email, old_email ) {
    var html = __EMAIL_CHANGED;

    html = html.replace (/\%old_email/g, escapeHtml(old_email));
    html = html.replace (/\%new_email/g, escapeHtml(new_email));

    return html;
}

function format_mark ( mark_obj ) {
    var html = __MARK;

    var mark = mark_obj[0];
    var mark_setter = mark_obj[1];
    var mark_time = parseInt (mark_obj[2], 10) * 1000;

    html = html.replace (/\%setter/, escapeHtml(mark_setter));
    html = html.replace (/\%time/, new Date(mark_time));
    html = html.replace (/\%mark/, escapeHtml(mark));

    return html;
}

function format_mass_action ( obj_type, type  ) {
    var html;

    if ( type === __ACTION_APPLY ) {
        html = __TEMPLATE_MASS_ACTION_APPLY;
    } else if ( type === __ACTION_VERIFY ) {
        html = __TEMPLATE_MASS_ACTION_VERIFY;
    } else {
        html = __TEMPLATE_MASS_ACTION;
    }

    if ( obj_type === __TYPE_CC ) {
        html = html.replace (/\%req_type/g, __TYPE_CHANGE + "_" + __TYPE_CC);
    } else if ( obj_type === __TYPE_CLNC ) {
        html = html.replace (/\%req_type/g, __TYPE_CHANGE + "_" + __TYPE_CLNC);
    } else if ( obj_type === __TYPE_CLNS ) {
        html = html.replace (/\%req_type/g, __TYPE_NS2);
    } else if ( obj_type === __TYPE_CNC ) {
        html = html.replace (/\%req_type/g, __TYPE_CHANGE + "_" + __TYPE_CNC);
    } else if ( obj_type === __TYPE_CNS ) {
        html = html.replace (/\%req_type/g, __TYPE_NS1);
    }  else if ( obj_type === __TYPE_GC ) {
        html = html.replace (/\%req_type/g, __TYPE_CHANGE + "_" + __TYPE_GC);
    }  else if ( obj_type === __TYPE_GCC ) {
        html = html.replace (/\%req_type/g, __TYPE_CHANGE + "_" + __TYPE_GCC);
    } else {
        html = html.replace (/\%req_type/g, obj_type);
    }

    return html;
}

function format_name_change ( new_name, old_name ) {
    var html = __NAME_CHANGED;

    html = html.replace (/\%old_name/g, escapeHtml(old_name));
    html = html.replace (/\%new_name/g, escapeHtml(new_name));

    return html;
}

function format_nsc ( change, type ) {
    var html = __TEMPLATE_NSC;
    var name = escapeHtml(change.namespace_name);

    if ( type === __TYPE_CNC ) {
        html = html.replace (/\%req_type/g, __TYPE_CHANGE + "_" + __TYPE_CNC);
        html = html.replace (/\%namespace_name/g, "#" + name + " / #" + name + "-*");
    } else {
        html = html.replace (/\%req_type/g, __TYPE_CHANGE + "_" + __TYPE_CLNC);
        html = html.replace (/\%namespace_name/g, name + "/*");
    }

    html = html.replace (/\%id/g, escapeHtml(change.id));
    html = html.replace (/\%group_name/g, escapeHtml(change.group.name));
    html = html.replace (/\%group_id/g, escapeHtml(change.group.id));

    if ( change.status !== change.namespace_status ) {
        html = html.replace (/\%status_changed/g, format_status_change ( change.status, change.namespace_status));
    } else {
        html = html.replace (/\%status_changed/g, '');
    }

    if ( change.group.id != change.namespace_group.id ) {
        html = html.replace (/\%group_changed/g, format_group_change ( change.group, change.namespace_group ));
    } else {
        html = html.replace (/\%group_changed/g, '');
    }

    return html;
}

function format_namespace ( namespace, type ) {
    var html;

    if ( type === __TYPE_CNS ) {
        html = __TEMPLATE_CNS;
        html = html.replace (/\%req_type/g, __TYPE_NS1);
    } else if (type === __TYPE_CLNS ) {
        html = __TEMPLATE_CLNS;
        html = html.replace (/\%req_type/g, __TYPE_NS2);
    }

    html = html.replace (/\%group_id/g, escapeHtml(namespace.group_id));
    html = html.replace (/\%id/g, escapeHtml(namespace.id));
    html = html.replace (/\%group_name/g, escapeHtml(namespace.group_name));
    html = html.replace (/\%requested_namespace/g, escapeHtml(namespace.namespace_name));
    html = html.replace (/\%group_url/g, escapeHtml(namespace.group_url));
    html = html.replace (/\%requestor_name/g, escapeHtml(namespace.requestor_account_name));
    html = html.replace (/\%account_id/g, escapeHtml(namespace.requestor_account_id));

    if ( namespace.requestor_account_dropped ) {
        html = html.replace ( /\%requestor_account_dropped/g, format_account_drop ( namespace.requestor_account_name ) );
    } else {
        html = html.replace ( /\%requestor_account_dropped/g, '' );
    }

    return html;
}

function format_new_gc ( gc ) {
    var html = __TEMPLATE_AGC;

    html = html.replace (/\%req_type/g, __TYPE_NEW_GC);
    html = html.replace (/\%id/g, escapeHtml(gc.id));
    html = html.replace (/\%group_id/g, escapeHtml(gc.group_id));
    html = html.replace (/\%group_name/g, escapeHtml(gc.group_name));
    html = html.replace (/\%account_id/g, escapeHtml(gc.contact_account_id));
    html = html.replace (/\%gc_name/g, escapeHtml(gc.contact_account_name));

    if ( gc.contact_account_dropped ) {
        html = html.replace ( /\%target_account_dropped/g, format_account_drop ( gc.contact_account_name ) );
    } else {
        html = html.replace ( /\%target_account_dropped/g, '' );
    }

    return html;
}

function format_no_requests ( type ) {
    html = __TEMPLATE_NO_REQUESTS;

    if ( type === __TYPE_CC ) {
        html = html.replace (/\%req_type/g, __CONTACT_CHANGES);
    } else if (type === __TYPE_CHANGE) {
        html = html.replace (/\%req_type/g, __CHANGES);
    } else if ( type === __TYPE_CLNC ) {
        html = html.replace (/\%req_type/g, __CLNC);
    } else if ( type === __TYPE_CLNS ) {
        html = html.replace (/\%req_type/g, __CLNS);
    } else if ( type === __TYPE_CNC ) {
        html = html.replace (/\%req_type/g, __CNC);
    } else if ( type === __TYPE_CNS ) {
        html = html.replace (/\%req_type/g, __CNS);
    } else if ( type === __TYPE_GC ) {
        html = html.replace (/\%req_type/g, __GROUP_CHANGES);
    } else if ( type === __TYPE_GCC ) {
        html = html.replace (/\%req_type/g, __GROUP_CONTACT_CHANGES);
    } else if ( type === __TYPE_GROUP ) {
        html = html.replace (/\%req_type/g, __GROUPS);
    } else if ( type === __TYPE_NEW_GC ) {
        html = html.replace (/\%req_type/g, __GCA);
    }

    return html;
}

function format_phone_change (new_phone, old_phone) {
    var html = __PHONE_CHANGED;

    html = html.replace (/\%old_phone/g, escapeHtml(old_phone));
    html = html.replace (/\%new_phone/g, escapeHtml(new_phone));

    return html;
}

function format_primary_change ( new_primary, old_primary ) {
    if ( new_primary ) {
        new_primary = __YES;
    } else {
        new_primary = __NO;
    }

    if ( old_primary ) {
        old_primary = __YES;
    } else {
        old_primary = __NO;
    }

    var html = __PRIMARY_CHANGED;

    html = html.replace (/\%old_primary/, escapeHtml(old_primary));
    html = html.replace (/\%new_primary/, escapeHtml(new_primary));

    return html;
}

function format_status_change ( new_stats, old_stats ) {
    var html = __STATUS_CHANGED;

    html = html.replace (/\%old_status/, escapeHtml(old_stats));
    html = html.replace (/\%new_status/, escapeHtml(new_stats));

    return html;
}

function format_type_change ( new_type, old_type ) {
    var html = __TYPE_CHANGED;

    html = html.replace (/\%old_type/g, escapeHtml(old_type));
    html = html.replace (/\%new_type/g, escapeHtml(new_type));

    return html;
}

function format_url_change ( new_url, old_url ) {
    var html = __URL_CHANGED;

    html = html.replace (/\%old_url/g, escapeHtml(old_url));
    html = html.replace (/\%new_url/g, escapeHtml(new_url));

    return html;
}
