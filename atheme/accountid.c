#include "atheme.h"

DECLARE_MODULE_V1
(
        "groupserv/accountid", false, _modinit, _moddeinit,
        "$Revision$",
        "Stephen Bennett <stephen -at- freenode.net>"
);

list_t *gs_cmdtree;

static void gs_cmd_accountid(sourceinfo_t *si, int parc, char *parv[]);

command_t gs_accountid = { "ACCOUNTID", N_("Retrieves or modifies the GMS account ID"), "special:GMS", 2, gs_cmd_accountid };

void _modinit(module_t *m)
{
    MODULE_USE_SYMBOL(gs_cmdtree, "groupserv/main", "gs_cmdtree");

    command_add(&gs_accountid, gs_cmdtree);
}

void _moddeinit()
{
    command_delete(&gs_accountid, gs_cmdtree);
}

void gs_cmd_accountid(sourceinfo_t *si, int parc, char *parv[])
{
    myuser_t *mu = myuser_find(parv[0]);
    if (!mu)
    {
        command_fail(si, fault_badparams, "No such account %s", parv[0]);
        return;
    }

    metadata_t *md;

    if (parc > 1)
    {
        // Setting...
        md = metadata_add(mu, "private:gms:accountid", parv[1]);
    }
    else
    {
        md = metadata_find(mu, "private:gms:accountid");
    }

    if (!md)
    {
        command_fail(si, fault_nosuch_key, "%s has no account ID.", parv[0]);
        return;
    }

    command_success_string(si, md->value, "Account ID for %s is %s", parv[0], md->value);
}
