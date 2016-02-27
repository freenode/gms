/* actions */
var __ACTION_APPLY            = 'apply';
var __ACTION_APPROVE          = 'approve';
var __ACTION_REJECT           = 'reject';
var __ACTION_VERIFY           = 'verify';

/* approval types */
var __TYPE_CC                 = 'cc';
var __TYPE_CHANGE             = 'changes';
var __TYPE_CHANNEL            = 'channels';
var __TYPE_CLNC               = 'clnc';
var __TYPE_CLNS               = 'clns';
var __TYPE_CLOAK              = 'cloaks';
var __TYPE_CNC                = 'cnc';
var __TYPE_CNS                = 'cns';
var __TYPE_DROP               = 'drop';
var __TYPE_GC                 = 'gc';
var __TYPE_GCC                = 'gcc';
var __TYPE_GROUP              = 'group';
var __TYPE_NAMESPACE          = 'namespace';
var __TYPE_NEW_GC             = 'gca';
var __TYPE_NS1                = __TYPE_NAMESPACE + '_' + __TYPE_CNS;
var __TYPE_NS2                = __TYPE_NAMESPACE + '_' + __TYPE_CLNS;
var __TYPE_TRANSFER           = 'transfer';

/* status */
var __STATUS_ERROR            = 'error';
var __STATUS_PENDING_STAFF    = 'pending_staff';

/* ids, classnames and names of html elements */
var __ID_ACCOUNTNAME          = 'accname';
var __ID_APPLY                = 'apply_';
var __ID_APPLY_ALL            = 'apply_all_';
var __ID_APPROVE              = 'approve_';
var __ID_APPROVE_ALL          = 'approve_ALL_the_';
var __ID_BTN_ADD              = 'btn_add';
var __ID_CHANNEL              = 'channel';
var __ID_CLOAK_CONTAINER      = 'cloak_container';
var __ID_CLOAK                = 'cloak';
var __ID_CLOAKNS              = 'cloakns';
var __ID_ERROR_CONTAINER      = 'error_container';
var __ID_FREETEXT             = 'freetext_'; /* id of the freetext area */
var __ID_FULLNAME             = 'fullname';
var __ID_GROUPNAME            = 'gname';
var __ID_HIDDEN               = 'hidden-'; /* id of the hidden elem */
var __ID_NUM_CLOAKS           = 'num_cloaks';
var __ID_NS                   = 'ns';
var __ID_REJECT               = 'reject_';
var __ID_REJECT_ALL           = 'reject_all_';
var __ID_SELECT_ALL           = 'select_all_';
var __ID_USERCLOAK            = 'usercloak';
var __ID_VERIFY               = 'verify_';
var __ID_VERIFY_ALL           = 'verify_all_';

var __CLASS_16                = 'col-xs-2';
var __CLASS_25                = 'col-xs-3';    /* class name of an elem taking up 25% width */
var __CLASS_50                = 'col-xs-4';    /* as above except s/25/50/ */
var __CLASS_66                = 'col-xs-8';
var __CLASS_90                = 'col-xs-6'     /* as above except s/50/90/ */
var __CLASS_ACCOUNTNAME       = 'accname';
var __CLASS_ARROW_DOWN        = 'hand icon-chevron-down';
var __CLASS_ARROW_UP          = 'hand icon-chevron-up';
var __CLASS_CLOAK             = 'margin0';
var __CLASS_CONTAINER         = 'fullwidth clearfix'; /* class name of the container */
var __CLASS_ERROR             = 'alert alert-error';
var __CLASS_FULLWIDTH         = 'row';
var __CLASS_FULLNAME          = 'fullname';
var __CLASS_GROUPNAME         = 'gname';
var __CLASS_HEIGHT_100PX      = 'h100';
var __CLASS_HIDDEN            = 'hidden';
var __CLASS_HIDDENDIV         = __CLASS_HIDDEN + ' ' + __CLASS_FULLWIDTH;
var __CLASS_MARGIN0           = 'margin0';
var __CLASS_MASS              = 'mass_action';
var __CLASS_NS                = 'ns';
var __CLASS_TEXTAREA          = __CLASS_90 + ' ' + __CLASS_HEIGHT_100PX;

var __NAME_ACCOUNTNAME        = 'accountname_';
var __NAME_APPLY              = 'apply_';
var __NAME_APPROVE            = 'approve_';
var __NAME_CLOAK              = 'cloak_';
var __NAME_CLOAKNS            = 'cloak_namespace_';
var __NAME_EXPAND             = 'expand';   /* name of the arrows */
var __NAME_EXPAND_APPROVE     = 'expand_approve';
var __NAME_FREETEXT           = 'freetext_';
var __NAME_MASS               = 'mass_action';
var __NAME_REJECT             = 'reject_';
var __NAME_SELECT_ALL         = 'select_all';
var __NAME_VERIFY             = 'verify_';

/* misc constants */

var __BR                      = '<br/>';

var __ADDRESS_ADDED           = 'Address added: ';
var __ADDRESS_REMOVED         = 'Address removed.';
var __ADDRESS_UPDATED         = 'Address updated: ';
var __ALREADY_APPLIED         = ' ( Applied ) ';
var __ALREADY_APPROVED        = ' ( Approved ) ';
var __ALREADY_REJECTED        = ' ( Rejected ) ';
var __ALREADY_VERIFIED        = ' ( Verified ) ';
var __APPLY                   = 'Mark Applied';
var __APPROVE                 = 'Approve';
var __CHANGES                 = 'changes';
var __CHANNEL_REQUESTS        = 'channel requests';
var __CLNC                    = 'cloak namespace changes';
var __CLNS                    = 'cloak namespaces';
var __CLOAK_CHANGE            = 'Cloak: %cloak, approved on %time';
var __CLOAK_CHANGES           = 'cloak changes';
var __CNC                     = 'channel namespace changes';
var __CNS                     = 'channel namespaces';
var __CONTACT_CHANGES         = 'contact changes';
var __EMAIL                   = 'Email: ';
var __ERROR_TXT               = 'The following error occured:';
var __GCA                     = 'group contact additions';
var __GROUP_CONTACT_CHANGES   = 'group contact changes';
var __GROUP_CHANGES           = 'group changes';
var __GROUP_TYPE              = ' group';
var __GROUP                   = 'Group: ';
var __GROUPS                  = 'groups';
var __INITIAL_CONTACT         = 'Initial contact: ';
var __INITIAL_CHANNEL_NAMESPACES = 'Initial namespaces: ';
var __HIDDEN_PLACEHOLDER      = 'Optional freetext about the change.';
var __MARK                    = '<b>Note:</b> the account has been <b>marked</b> by <b>%setter</b> on %time:' + __BR + '<b>%mark</b>';
var __NAME                    = 'Name: ';
var __NAMESPACE               = 'Namespace: ';
var __NO                      = 'No';
var __NOT_FAILED              = ' ( Not failed )';
var __NO_CLOAK_CHANGES        = 'No cloak changes.';
var __PHONE                   = 'Phone: ';
var __PREFIX_RESPONSE         = 'response_';
var __PREVIOUS_FAILURE_REASON = 'Previous failure reason:';
var __PREVIOUSLY_FAILED       = 'Previously failed request';
var __PRIMARY                 = 'Primary:';
var __RECENT_CLOAK_CHANGES    = "'s recent cloak changes:";
var __REJECT                  = 'Reject';
var __REQUESTED_CONTACT       = 'Requested contact: ';
var __REQUESTED_NAMESPACE     = 'Requested namespace: ';
var __REQUESTOR               = 'Requestor: ';
var __RETRY                   = 'Retry';
var __VERIFY                  = 'Verify';
var __SELECT_ALL              = 'Select all';
var __STATUS                  = 'Status: ';
var __TYPE                    = 'Type: ';
var __URL                     = 'URL: ';
var __YES                     = 'Yes';

/* URLS */

var __ROOT                    = document.root_url;

var __URL_ADMIN_APPROVE_CHAN  = __ROOT + '/json/admin/approve_channel_requests';
var __URL_ADMIN_APPROVE_CHNG  = __ROOT + '/json/admin/approve_change';
var __URL_ADMIN_APPROVE_CLOAK = __ROOT + '/json/admin/approve_cloak';
var __URL_ADMIN_APPROVE_CLNS  = __ROOT + '/json/admin/approve_namespaces?approve_item=' + __TYPE_CLNS;
var __URL_ADMIN_APPROVE_CNS   = __ROOT + '/json/admin/approve_namespaces?approve_item=' + __TYPE_CNS;
var __URL_ADMIN_APPROVE_GCA   = __ROOT + '/json/admin/approve_new_gc';
var __URL_ADMIN_APPROVE_GROUP = __ROOT + '/json/admin/approve_groups';

var __URL_ADMIN_APPROVE_CC    = __URL_ADMIN_APPROVE_CHNG + '?change_item=' + __TYPE_CC;
var __URL_ADMIN_APPROVE_CLNC  = __URL_ADMIN_APPROVE_CHNG + '?change_item=' + __TYPE_CLNC;
var __URL_ADMIN_APPROVE_CNC   = __URL_ADMIN_APPROVE_CHNG + '?change_item=' + __TYPE_CNC;
var __URL_ADMIN_APPROVE_GC    = __URL_ADMIN_APPROVE_CHNG + '?change_item=' + __TYPE_GC;
var __URL_ADMIN_APPROVE_GCC   = __URL_ADMIN_APPROVE_CHNG + '?change_item=' + __TYPE_GCC;

var __URL_ADMIN_SUBMIT_CHAN   = __ROOT + '/json/admin/approve_channel_requests/submit';
var __URL_ADMIN_SUBMIT_CHNG   = __ROOT + '/json/admin/approve_change/submit';
var __URL_ADMIN_SUBMIT_CLOAK  = __ROOT + '/json/admin/approve_cloak/submit';
var __URL_ADMIN_SUBMIT_GCA    = __ROOT + '/json/admin/approve_new_gc/submit';
var __URL_ADMIN_SUBMIT_GROUP  = __ROOT + '/json/admin/approve_groups/submit';
var __URL_ADMIN_SUBMIT_NS     = __ROOT + '/json/admin/approve_namespaces/submit';

var __URL_GROUP               = __ROOT + '/admin/group/%group_id/view';
var __URL_GROUP_LISTCHANS     = __ROOT + '/json/group/%group_id/listchans';

var __URL_STAFF_ACCOUNTNAME   = __ROOT + '/json/admin/search_account_name';
var __URL_STAFF_FULLNAME      = __ROOT + '/json/admin/search_full_name';
var __URL_STAFF_GROUPNAME     = __ROOT + '/json/admin/search_group_name';
var __URL_STAFF_NS            = __ROOT + '/json/admin/search_ns_name';
var __URL_USER                = __ROOT + '/admin/account/%account_id/view';
var __URL_USER_ACCEPT_CLOAK   = __ROOT + '/cloak/%id/approve';

/* HTML templates */

/* container */
var __TEMPLATE_CONTAINER      = "<div class='" + __CLASS_CONTAINER + "'>";
var __TEMPLATE_CONTAINER_END  = "</div>";

/* Approve all checked etc */

var __TEMPLATE_MASS_ACTION    =
"<div class='" + __CLASS_FULLWIDTH + " " + __CLASS_MARGIN0 + "'>" +
    "<div class='" + __CLASS_66 + "'>" +
        "<blockquote class='" + __CLASS_MARGIN0 + "'>" +
            "<p>" +
                "<label>" +
                    "<input type='checkbox' class='" + __CLASS_MASS + "' id='" + __ID_SELECT_ALL + "%req_type' value='%req_type' />" +
                    __SELECT_ALL +
                "</label>" +
            "</p>" +
        "</blockquote>" +
    "</div>" +
    "<div class='" + __CLASS_16 + "'>" +
        "<a id='" + __ID_APPROVE_ALL + "%req_type' href='javascript:;'>" +
            __APPROVE +
        "</a>" +
    "</div>" +
    "<div class='" + __CLASS_16 + "'>" +
        "<a id='" + __ID_REJECT_ALL + "%req_type' href='javascript:;'>" +
            __REJECT +
        "</a>" +
    "</div>" +
"</div>";

var __TEMPLATE_MASS_ACTION_VERIFY =
"<div class='" + __CLASS_FULLWIDTH + " " + __CLASS_MARGIN0 + "'>" +
    "<div class='" + __CLASS_50 + "'>" +
    "<blockquote class='" + __CLASS_MARGIN0 + "'>" +
        "<p>" +
            "<label>" +
                "<input type='checkbox' class='" + __CLASS_MASS + "' id='" + __ID_SELECT_ALL + "%req_type' value='%req_type' /> " +
                __SELECT_ALL +
            "</label>" +
        "</p>" +
    "</blockquote>" +
    "</div>" +
    "<div class='" + __CLASS_16 + "'>" +
        "<a id='" + __ID_APPROVE_ALL + "%req_type' href='javascript:;'>" +
            __APPROVE +
        "</a>" +
    "</div>" +
    "<div class='" + __CLASS_16 + "'>" +
        "<a id='" + __ID_VERIFY_ALL + "%req_type' href='javascript:;'>" +
            __VERIFY +
        "</a>" +
    "</div>" +
    "<div class='" + __CLASS_16 + "'>" +
        "<a id='" + __ID_REJECT_ALL + "%req_type' href='javascript:;'>" +
            __REJECT +
        "</a>" +
    "</div>" +
"</div>";

var __TEMPLATE_MASS_ACTION_APPLY =
"<div class='" + __CLASS_FULLWIDTH + " " + __CLASS_MARGIN0 + "'>" +
    "<div class='" + __CLASS_50 + "'>" +
        "<blockquote class='" + __CLASS_MARGIN0 + "'>" +
            "<p>" +
                "<label>" +
                    "<input type='checkbox' class='" + __CLASS_MASS + "' id='" + __ID_SELECT_ALL + "%req_type' + value='%req_type' />" +
                    __SELECT_ALL +
                "</label>" +
            "</p>" +
        "</blockquote>" +
    "</div>" +
    "<div class='" + __CLASS_16 + "'>" +
        "<a id='" + __ID_APPROVE_ALL + "%req_type' href='javascript:;'>" +
            __APPROVE +
        "</a>" +
    "</div>" +
    "<div class='" + __CLASS_16 + "'>" +
        "<a id='" + __ID_APPLY_ALL + "%req_type' href='javascript:;'>" +
            __APPLY +
        "</a>" +
    "</div>" +
    "<div class='" + __CLASS_16 + "'>" +
        "<a id='" + __ID_REJECT_ALL + "%req_type' href='javascript:;'>" +
            __REJECT +
        "</a>" +
    "</div>" +
"</div>";

/* checkbox */

var __TEMPLATE_CHECKBOX       =
"<input type='checkbox' class='" + __CLASS_MASS + "' name='" + __NAME_MASS + "_%req_type' value='%id' />";

/* apply/reject/verify/approve links */

var __TEMPLATE_APPLY          =
"<div class='" + __CLASS_16 + "'>" +
    "<a id='" + __ID_APPLY + "%id' name='" + __NAME_APPLY + "%req_type' href='javascript:;' value='%id'>" +
        __APPLY +
    "</a> <i name='" + __NAME_EXPAND + "' value='%id' class='" + __CLASS_ARROW_DOWN + "'></i>" +
"</div>";
var __TEMPLATE_APPROVE        =
"<div class='" + __CLASS_16 + "'>" +
    "<a id='" + __ID_APPROVE + "%id' name='" + __NAME_APPROVE + "%req_type' href='javascript:;' value='%id'>" +
        __APPROVE +
    "</a> <i name='" + __NAME_EXPAND + "' value='%id' class='" + __CLASS_ARROW_DOWN + "'></i>" +
"</div>";
var __TEMPLATE_REJECT         =
"<div class='" + __CLASS_16 + "'>" +
    "<a id='" + __ID_REJECT + "%id' name='" + __NAME_REJECT + "%req_type' href='javascript:;' value='%id'>" +
        __REJECT +
    "</a> <i name='" + __NAME_EXPAND + "' value='%id' class='" + __CLASS_ARROW_DOWN + "'></i>" +
"</div>";
var __TEMPLATE_RETRY          =
"<div class='" + __CLASS_16 + "'>" +
    "<a id='" + __ID_APPROVE + "%id' name='" + __NAME_APPROVE + "%req_type' href='javascript:;' value='%id'>" +
        __RETRY +
    "</a> <i name='" + __NAME_EXPAND + "' value='%id' class='" + __CLASS_ARROW_DOWN + "'></i>" +
"</div>";
var __TEMPLATE_VERIFY         =
"<div class='" + __CLASS_16 + "'>" +
    "<a id='" + __ID_VERIFY + "%id' name='" + __NAME_VERIFY + "%req_type' href='javascript:;' value='%id'>" +
        __VERIFY +
    "</a> <i name='" + __NAME_EXPAND + "' value='%id' class='" + __CLASS_ARROW_DOWN + "'></i>" +
"</div>";

/* already applied/verified */

var __TEMPLATE_APPLIED        =
"<div class='" + __CLASS_16 + "'>" +
    "<a id='" + __ID_APPLY + "%id'>" + __NOT_FAILED + "</a>" +
    "<i name='" + __NAME_EXPAND + "' value='%id' class='" + __CLASS_ARROW_DOWN + "'></i>" +
"</div>";
var __TEMPLATE_VERIFIED       =
"<div class='" + __CLASS_16 + "'>" +
    __ALREADY_VERIFIED +
    "<i name='" + __NAME_EXPAND + "' value='%id' class='" + __CLASS_ARROW_DOWN + "'></i>" +
"</div>";

/* why previous request failed */

var __TEMPLATE_FAIL_REASON   =
"<p class='" + __CLASS_ERROR + "'>" +
    __PREVIOUS_FAILURE_REASON + __BR +
    "%fail_reason" +
"</p>";

/* mark */

var __TEMPLATE_MARK         =
"<p>" +
    "%marked" +
"</p>";

/* account dropped */

var __TEMPLATE_ACCOUNT_DROPPED =
"<b>%dropped_account's account has been dropped!</b>";

/* no changes pending */
var __TEMPLATE_NO_REQUESTS          =
"<b>No %req_type are currently pending approval. Congratulations!</b>";

/* recent cloak changes */

var __TEMPLATE_RECENT_CLOAK_CHANGES =
"%target_name's" + __RECENT_CLOAK_CHANGES +
"<ul>%recent_cloak_changes</ul>";
var __TEMPLATE_CLOAK_CHANGE         =
"<li>" + __CLOAK_CHANGE + "</li>";
var __TEMPLATE_NO_CLOAK_CHANGES     =
"<li>No cloak changes yet</li>";

/* accept new GC - GC info */

var __TEMPLATE_AGC_INFO      =
"<div class='" + __CLASS_66 + "'>" +
    "<blockquote>" +
        "<p>" +
            __TEMPLATE_CHECKBOX +
            "<a target='_blank' href='" + __URL_GROUP + "'>" +
                "%group_name" +
            "</a> - <a target='_blank' href='" + __URL_USER + "'>%gc_name</a>" +
        "</p>" +
        "%target_account_dropped" +
    "</blockquote>" +
"</div>";

/* channel drop info */

var __TEMPLATE_DROP_INFO      =
"<div class='" + __CLASS_50 + "'>" +
    "<blockquote>" +
    "<p>" +
        __TEMPLATE_CHECKBOX +
        "%channel_name" +
    "</p>" +
    "<small>" +
        "%request_type" +
    "</small>" +
    __REQUESTOR + "<a target='_blank' href='" + __URL_USER.replace(/\%account_id/g, '%requestor_id') + "'>%requestor_name</a>" + __BR +
    __GROUP + "%group_name" + __BR +
    __URL + '<a href="%group_url" target="_blank">%group_url</a>' + __BR +
    __NAMESPACE + "%namespace" + __BR +
    "%requestor_account_dropped" +
    "</blockquote>" +
"</div>";

/* channel drop info - previously failed*/

var __TEMPLATE_DROP_FAILED    =
"<div class='" + __CLASS_50 + "'>" +
    "<blockquote>" +
    "<p>" +
        __TEMPLATE_CHECKBOX +
        "%channel_name" +
    "</p>" +
    "<small>" +
        "%request_type" +
    "</small>" +
    __REQUESTOR + "<a target='_blank' href='" + __URL_USER.replace(/\%account_id/g, '%requestor_id') + "'>%requestor_name</a>" + __BR +
    __GROUP + "%group_name" + __BR +
    __URL + '<a href="%group_url" target="_blank">%group_url</a>' + __BR +
    __NAMESPACE + "%namespace" + __BR +
    "%requestor_account_dropped" +
    __BR + __PREVIOUSLY_FAILED + __BR
    "</blockquote>" +
"</div>";

/* channel transfer info */

var __TEMPLATE_TRANSFER_INFO      =
"<div class='" + __CLASS_50 + "'>" +
    "<blockquote>" +
    "<p>" +
        __TEMPLATE_CHECKBOX +
        "%channel_name" +
    "</p>" +
    "<small>" +
        "%request_type" +
        " to <a href='" + __URL_USER + "' target='_blank'>%target_name</a>" +
    "</small>" +
    __REQUESTOR + "<a target='_blank' href='" + __URL_USER.replace(/\%account_id/g, '%requestor_id') + "'>%requestor_name</a>" + __BR +
    __GROUP + "%group_name" + __BR +
    __URL + '<a href="%group_url" target="_blank">%group_url</a>' + __BR +
    __NAMESPACE + "%namespace" + __BR +
    "%requestor_account_dropped" + __BR +
    "%target_account_dropped" +
    "</blockquote>" +
"</div>";

/* channel transfer info - previously failed*/

var __TEMPLATE_TRANSFER_FAILED      =
"<div class='" + __CLASS_50 + "'>" +
    "<blockquote>" +
    "<p>" +
         __TEMPLATE_CHECKBOX +
        "%channel_name" +
    "</p>" +
    "<small>" +
        "%request_type" +
        " to <a href='" + __URL_USER + "' target='_blank'>%target_name</a>" +
    "</small>" +
    __REQUESTOR + "<a target='_blank' href='" + __URL_USER.replace(/\%account_id/g, '%requestor_id') + "'>%requestor_name</a>" + __BR +
    __GROUP + "%group_name" + __BR +
    __URL + '<a href="%group_url" target="_blank">%group_url</a>' + __BR +
    __NAMESPACE + "%namespace" + __BR +
    "%requestor_account_dropped" + __BR +
    "%target_account_dropped" +
    __BR + __PREVIOUSLY_FAILED +
    "</blockquote>" +
"</div>";

/* cloak info */

var __TEMPLATE_CLOAK_INFO     =
"<div class='" + __CLASS_50 + "'>" +
    "<blockquote>" +
        "<p>" +
            __TEMPLATE_CHECKBOX +
            "<a target='_blank' href='" + __URL_USER + "'>%target_name</a>" +
        "</p>" +
        "<small>" +
            "%cloak" +
        "</small>" +
        __NAMESPACE + "%namespace/*" + __BR +
        __GROUP + "%group_name" + __BR +
        __URL + "<a href='%group_url' target='_blank'>%group_url</a>" + __BR +
        "%target_account_dropped" +
    "</blockquote>" +
"</div>";

/* information of a cloak that previously failed applying */

var __TEMPLATE_CLOAK_FAILED =
"<div class='" + __CLASS_50 + "'>" +
    "<blockquote>" +
        "<p>" +
            __TEMPLATE_CHECKBOX +
            "<a target='_blank' href='" + __URL_USER + "'>%target_name</a>" +
        "</p>" +
        "<small>" +
            "%cloak" +
        "</small>" +
        __NAMESPACE + "%namespace/*" + __BR +
        __GROUP + "%group_name" + __BR +
        __URL + "<a href='%group_url' target='_blank'>%group_url</a>" + __BR +
        "%target_account_dropped" + __BR +
        __PREVIOUSLY_FAILED +
    "</blockquote>" +
"</div>";

/* channel namespace info */

var __TEMPLATE_CNS_INFO       =
"<div class='" + __CLASS_66 + "'>" +
    "<blockquote>" +
        "<p>" +
            __TEMPLATE_CHECKBOX +
            "<a target='_blank' href='" + __URL_GROUP + "'>" +
                "%group_name" +
            "</a> - #%requested_namespace / #%requested_namespace-*" +
        "</p>" +
        "<small>" +
            "<a target='_blank' href='%group_url'>%group_url</a>" +
        "</small>" +
        __REQUESTOR + "<a target='_blank' href='" + __URL_USER + "'>%requestor_name</a>" + __BR +
        __REQUESTED_NAMESPACE + "%requested_namespace" + __BR +
        "%requestor_account_dropped" + __BR +
    "</blockquote>" +
"</div>";

/* cloak namespace info */

var __TEMPLATE_CLNS_INFO       =
"<div class='" + __CLASS_66 + "'>" +
    "<blockquote>" +
        "<p>" +
            __TEMPLATE_CHECKBOX +
            "<a target='_blank' href='" + __URL_GROUP + "'>" +
                "%group_name" +
            "</a> - %requested_namespace/*" +
        "</p>" +
        "<small>" +
            "<a target='_blank' href='%group_url'>%group_url</a>" +
        "</small>" +
        __REQUESTOR + "<a target='_blank' href='" + __URL_USER + "'>%requestor_name</a>" + __BR +
        __REQUESTED_NAMESPACE + "%requested_namespace" + __BR +
        "%requestor_account_dropped" + __BR +
    "</blockquote>" +
"</div>";

/* group info */

var __TEMPLATE_GROUP_INFO     =
"<div class='" + __CLASS_50 + "'>" +
    "<blockquote>" +
        "<p>" +
            __TEMPLATE_CHECKBOX +
            "<a target='_blank' href='" + __URL_GROUP + "'>" +
                "%group_name" +
            "</a>" +
        "</p>" +
        "<small>" +
            "<a target='_blank' href='%group_url'>%group_url</a>" +
        "</small>" +
        "%group_type" + __GROUP_TYPE + __BR +
        __INITIAL_CONTACT + "<a target='_blank' href='" + __URL_USER + "'>%group_initial_contact</a>" + __BR +
        __INITIAL_CHANNEL_NAMESPACES + "%initial_channel_namespaces" + __BR +
        "%requestor_account_dropped" +
    "</blockquote>" +
"</div>";

/* address */

var __TEMPLATE_ADDRESS        = '%addr1, '   +
                                '%addr2, '   +
                                '%city, '    +
                                '%state, '   +
                                '%code, '    +
                                '%country, ' +
                                '%phone,'    +
                                '%phone2,';

/* changes */
var __GROUP_CHANGED           = __GROUP + '<a href="' + __ROOT + '/admin/group/%old_group_id/view" target="_blank">%old_group</a> ---> <a href="' + __ROOT + '/admin/group/%new_group_id/view" target="_blank">%new_group</a>' + __BR;
var __NAME_CHANGED            = __NAME + '%old_name ---> %new_name' + __BR;
var __EMAIL_CHANGED           = __EMAIL + '%old_email ---> %new_email' + __BR;
var __PHONE_CHANGED           = __PHONE + '%old_phone ---> %new_phone' + __BR;
var __PRIMARY_CHANGED         = __PRIMARY + '%old_primary ---> %new_primary' + __BR;
var __STATUS_CHANGED          = __STATUS + '%old_status ---> %new_status' + __BR;
var __TYPE_CHANGED            = __TYPE + '%old_type ---> %new_type' + __BR;
var __URL_CHANGED             = __URL  + '<a href="%old_url">%old_url</a> ---> <a href="%new_url">%new_url</a>' + __BR;

var __TEMPLATE_CHANGES        =
"<button name='" + __NAME_EXPAND_APPROVE + "' value='" + __TYPE_GCC + "' type='button' class='ml30 btn margin10 btn-default alignleft col-sm-12'> " +
    "<i class='glyphicon glyphicon-play-circle'></i> " +
    "<span class='badge'>%pending_gcc</span> " +__GROUP_CONTACT_CHANGES +
"</button>" +
"<div id='" + __PREFIX_RESPONSE + __TYPE_GCC + "'></div>" +

"<button name='" + __NAME_EXPAND_APPROVE + "' value='" + __TYPE_GC + "' type='button' class='ml30 btn margin10 btn-default alignleft col-sm-12'> " +
    "<i class='glyphicon glyphicon-play-circle'></i> " +
    "<span class='badge'>%pending_gc</span> " + __GROUP_CHANGES +
"</button>" +
"<div id='" + __PREFIX_RESPONSE + __TYPE_GC + "'></div>" +

"<button name='" + __NAME_EXPAND_APPROVE + "' value='" + __TYPE_CNC + "' type='button' class='ml30 btn margin10 btn-default alignleft col-sm-12'> " +
    "<i class='glyphicon glyphicon-play-circle'></i> " +
    "<span class='badge'>%pending_cnc</span> " + __CNC +
"</button>" +
"<div id='" + __PREFIX_RESPONSE + __TYPE_CNC + "'></div>" +

"<button name='" + __NAME_EXPAND_APPROVE + "' value='" + __TYPE_CLNC + "' type='button' class='ml30 btn margin10 btn-default alignleft col-sm-12'> " +
    "<i class='glyphicon glyphicon-play-circle'></i> " +
    "<span class='badge'>%pending_clnc</span> " + __CLNC +
"</button>" +
"<div id='" + __PREFIX_RESPONSE + __TYPE_CLNC + "'></div>" ;

/* contact change info */

var __TEMPLATE_CC_INFO       =
"<div class='" + __CLASS_66 + "'>" +
    "<blockquote>" +
        "<p>" +
            __TEMPLATE_CHECKBOX +
            "<a target='_blank' href='" + __URL_USER + "'>" +
                "%account_name" +
            "</a>" +
        "</p>" +
        "%name_changed" +
        "%email_changed" +
        "%phone_changed" +
        "%requestor_account_dropped" +
    "</blockquote>" +
"</div>";

/* group change info */

var __TEMPLATE_GC_INFO       =
"<div class='" + __CLASS_66 + "'>" +
    "<blockquote>" +
        "<p>" +
            __TEMPLATE_CHECKBOX +
            "<a target='_blank' href='" + __URL_GROUP + "'>" +
                "%group_name" +
            "</a>" +
        "</p>" +
        "<small>" +
            "<a target='_blank' href='%group_url'>%group_url</a>" +
        "</small>" +
        "%type_changed" +
        "%url_changed" +
        "%address_changed" +
    "</blockquote>" +
"</div>";

/* group contact change info */

var __TEMPLATE_GCC_INFO       =
"<div class='" + __CLASS_66 + "'>" +
    "<blockquote>" +
        "<p>" +
            __TEMPLATE_CHECKBOX +
            "<a target='_blank' href='" + __URL_GROUP + "'>" +
                "%group_name" +
            "</a> - <a target='_blank' href='" + __URL_USER + "'>%account_name</a>" +
        "</p>" +
        "<small>" +
            "<a target='_blank' href='%group_url'>%group_url</a>" +
        "</small>" +
        __REQUESTED_CONTACT + "%account_name" + __BR +
        "%status_changed" +
        "%primary_changed" +
        "%target_account_dropped" +
    "</blockquote>" +
"</div>";

/* namespace change info */

var __TEMPLATE_NSC_INFO     =
"<div class='" + __CLASS_66 + "'>" +
    "<blockquote>" +
        "<p>" +
        __TEMPLATE_CHECKBOX +
        "%namespace_name" +
        "</p>" +
        "<small>" +
            __GROUP +
            "<a target='_blank' href='" + __URL_GROUP + "'>" +
                "%group_name" +
            "</a>" +
        "</small>" +
        "%group_changed" +
        "%status_changed" +
    "</blockquote>" +
"</div>";

/* hidden information */

var __TEMPLATE_HIDDEN          =
"<div class='" + __CLASS_HIDDENDIV + "' id='" + __ID_HIDDEN + "%id'>";
var __TEMPLATE_HIDDEN_END      =
"</div>";

/* freetext area */

var __TEMPLATE_TEXTAREA       =
    "<textarea placeholder='" + __HIDDEN_PLACEHOLDER + "' class='" + __CLASS_TEXTAREA + "' " +
    "id='" + __ID_FREETEXT + "%id' name='" + __NAME_FREETEXT + "%id'></textarea>";

/* hidden div */

var __TEMPLATE_HIDDENDIV      =
__TEMPLATE_HIDDEN             +
__TEMPLATE_TEXTAREA           +
__TEMPLATE_HIDDEN_END;

var __TEMPLATE_HIDDEN_CHANNEL_FAILED =
__TEMPLATE_HIDDEN                    +
__TEMPLATE_FAIL_REASON               +
__TEMPLATE_MARK                      +
__TEMPLATE_TEXTAREA                  +
__TEMPLATE_HIDDEN_END;

var __TEMPLATE_HIDDEN_CHANNEL        =
__TEMPLATE_HIDDEN                    +
__TEMPLATE_MARK                      +
__TEMPLATE_TEXTAREA                  +
__TEMPLATE_HIDDEN_END;


var __TEMPLATE_HIDDEN_CLOAK_FAILED   =
__TEMPLATE_HIDDEN                    +
__TEMPLATE_FAIL_REASON               +
__TEMPLATE_MARK                      +
__TEMPLATE_RECENT_CLOAK_CHANGES      +
__TEMPLATE_TEXTAREA                  +
__TEMPLATE_HIDDEN_END;

var __TEMPLATE_HIDDEN_CLOAK          =
__TEMPLATE_HIDDEN                    +
__TEMPLATE_MARK                      +
__TEMPLATE_RECENT_CLOAK_CHANGES      +
__TEMPLATE_TEXTAREA                  +
__TEMPLATE_HIDDEN_END;

/* templates for each thing that needs approving */

var __TEMPLATE_AGC            =
__TEMPLATE_CONTAINER          +
__TEMPLATE_AGC_INFO           +
__TEMPLATE_APPROVE            +
__TEMPLATE_REJECT             +
__TEMPLATE_CONTAINER_END      +
__TEMPLATE_HIDDENDIV;

var __TEMPLATE_CNS            =
__TEMPLATE_CONTAINER          +
__TEMPLATE_CNS_INFO           +
__TEMPLATE_APPROVE            +
__TEMPLATE_REJECT             +
__TEMPLATE_CONTAINER_END      +
__TEMPLATE_HIDDENDIV;

var __TEMPLATE_CLNS           =
__TEMPLATE_CONTAINER          +
__TEMPLATE_CLNS_INFO          +
__TEMPLATE_APPROVE            +
__TEMPLATE_REJECT             +
__TEMPLATE_CONTAINER_END      +
__TEMPLATE_HIDDENDIV;

var __TEMPLATE_FAILED_DROP    =
__TEMPLATE_CONTAINER          +
__TEMPLATE_DROP_FAILED        +
__TEMPLATE_RETRY              +
__TEMPLATE_APPLY              +
__TEMPLATE_REJECT             +
__TEMPLATE_CONTAINER_END      +
__TEMPLATE_HIDDEN_CHANNEL_FAILED;

var __TEMPLATE_DROP           =
__TEMPLATE_CONTAINER          +
__TEMPLATE_DROP_INFO          +
__TEMPLATE_APPROVE            +
__TEMPLATE_APPLIED            +
__TEMPLATE_REJECT             +
__TEMPLATE_CONTAINER_END      +
__TEMPLATE_HIDDEN_CHANNEL;

var __TEMPLATE_FAILED_TRANSFER =
__TEMPLATE_CONTAINER           +
__TEMPLATE_TRANSFER_FAILED     +
__TEMPLATE_RETRY               +
__TEMPLATE_APPLY               +
__TEMPLATE_REJECT              +
__TEMPLATE_CONTAINER_END       +
__TEMPLATE_HIDDEN_CHANNEL_FAILED;

var __TEMPLATE_TRANSFER       =
__TEMPLATE_CONTAINER          +
__TEMPLATE_TRANSFER_INFO      +
__TEMPLATE_APPROVE            +
__TEMPLATE_APPLIED            +
__TEMPLATE_REJECT             +
__TEMPLATE_CONTAINER_END      +
__TEMPLATE_HIDDEN_CHANNEL;

var __TEMPLATE_FAILED_CLOAK   =
__TEMPLATE_CONTAINER          +
__TEMPLATE_CLOAK_FAILED       +
__TEMPLATE_RETRY              +
__TEMPLATE_APPLY              +
__TEMPLATE_REJECT             +
__TEMPLATE_CONTAINER_END      +
__TEMPLATE_HIDDEN_CLOAK_FAILED;

var __TEMPLATE_PENDING_CLOAK  =
__TEMPLATE_CONTAINER          +
__TEMPLATE_CLOAK_INFO         +
__TEMPLATE_APPROVE            +
__TEMPLATE_APPLIED            +
__TEMPLATE_REJECT             +
__TEMPLATE_CONTAINER_END      +
__TEMPLATE_HIDDEN_CLOAK;

var __TEMPLATE_PENDING_GROUP  =
__TEMPLATE_CONTAINER          +
__TEMPLATE_GROUP_INFO         +
__TEMPLATE_APPROVE            +
__TEMPLATE_VERIFY             +
__TEMPLATE_REJECT             +
__TEMPLATE_CONTAINER_END      +
__TEMPLATE_HIDDENDIV;

var __TEMPLATE_VERIFIED_GROUP =
__TEMPLATE_CONTAINER          +
__TEMPLATE_GROUP_INFO         +
__TEMPLATE_APPROVE            +
__TEMPLATE_VERIFIED           +
__TEMPLATE_REJECT             +
__TEMPLATE_CONTAINER_END      +
__TEMPLATE_HIDDENDIV;

/* changes */

var __TEMPLATE_CC             =
__TEMPLATE_CONTAINER          +
__TEMPLATE_CC_INFO            +
__TEMPLATE_APPROVE            +
__TEMPLATE_REJECT             +
__TEMPLATE_CONTAINER_END      +
__TEMPLATE_HIDDENDIV;

var __TEMPLATE_GC             =
__TEMPLATE_CONTAINER          +
__TEMPLATE_GC_INFO            +
__TEMPLATE_APPROVE            +
__TEMPLATE_REJECT             +
__TEMPLATE_CONTAINER_END      +
__TEMPLATE_HIDDENDIV;

var __TEMPLATE_GCC            =
__TEMPLATE_CONTAINER          +
__TEMPLATE_GCC_INFO           +
__TEMPLATE_APPROVE            +
__TEMPLATE_REJECT             +
__TEMPLATE_CONTAINER_END      +
__TEMPLATE_HIDDENDIV;

var __TEMPLATE_NSC            =
__TEMPLATE_CONTAINER          +
__TEMPLATE_NSC_INFO           +
__TEMPLATE_APPROVE            +
__TEMPLATE_REJECT             +
__TEMPLATE_CONTAINER_END      +
__TEMPLATE_HIDDENDIV;
