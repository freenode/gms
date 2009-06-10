#include "atheme.h"

DECLARE_MODULE_V1
(
        "groupserv/getregtime", false, _modinit, _moddeinit,
        "$Revision$",
        "Stephen Bennett <stephen -at- freenode.net>"
);

list_t *gs_cmdtree;

static void gs_cmd_getregtime(sourceinfo_t *si, int parc, char *parv[]);

command_t gs_getregtime = { "GETREGTIME", N_("Displays contextual help information."), "special:GMS", 1, gs_cmd_getregtime };

void _modinit(module_t *m)
{
    MODULE_USE_SYMBOL(gs_cmdtree, "groupserv/main", "gs_cmdtree");

    command_add(&gs_getregtime, gs_cmdtree);
}

void _moddeinit()
{
    command_delete(&gs_getregtime, gs_cmdtree);
}

void gs_cmd_getregtime(sourceinfo_t *si, int parc, char *parv[])
{
    if (parc < 1)
    {
        command_fail(si, fault_needmoreparams, "Need one parameter to GETREGTIME");
        return;
    }

    myuser_t *mu = myuser_find(parv[0]);
    if (!mu)
    {
        command_fail(si, fault_badparams, "No such account %s", parv[0]);
        return;
    }

    char buf[32];
    snprintf(buf, sizeof buf, "%lu", mu->registered);

    command_success_string(si, buf, "Registration time for %s is %s", parv[0], buf);
}
