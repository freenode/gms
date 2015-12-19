#include "atheme.h"

DECLARE_MODULE_V1
(
    "freenode/prevent_registration", false, _modinit, _moddeinit,
    PACKAGE_STRING,
    "Atheme Development Group <http://www.atheme.org>"
);

static void can_register(hook_channel_register_check_t *hdata);

void _modinit(module_t *m)
{
    hook_add_event("channel_can_register");
    hook_add_channel_can_register(can_register);
}

void _moddeinit(module_unload_intent_t intent)
{
    hook_del_channel_can_register(can_register);
}

/*
 * Prevent registration of single #-channels unless priv CHAN_ADMIN
*/

static void can_register(hook_channel_register_check_t *hdata) {
    const char *name = hdata->name;

    sourceinfo_t *si = hdata->si;

    if (
        !has_priv(si, PRIV_CHAN_ADMIN) &&
        ( strlen(name) < 2 || *(name + 1) != '#' )
    ) {
        command_fail(si, fault_noprivs, _("\2%s\2 cannot be registered outside of GMS.\nFor more information, see http://freenode.net/policy.shtml#channelnaming"), name);
        hdata->approved = 1;
    } else {
        hdata->approved = 0;
    }
}
