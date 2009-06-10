#include "atheme.h"

DECLARE_MODULE_V1
(
        "groupserv/main", false, _modinit, _moddeinit,
        "$Revision$",
        "Stephen Bennett <stephen -at- freenode.net>"
);

static void gs_handler(sourceinfo_t *si, int parc, char *parv[]);

service_t *gs;
list_t gs_cmdtree;
list_t gs_helptree;
list_t gs_conftable;

void _modinit(module_t *m)
{
    gs = service_add("GroupServ", gs_handler, &gs_cmdtree, &gs_conftable);
}

void _moddeinit()
{
    service_delete(gs);
}

static void gs_handler(sourceinfo_t *si, int parc, char *parv[])
{
    char *cmd;
    char *text;
    char orig[BUFSIZE];

    /* this should never happen */
    if (parv[0][0] == '&')
    {
        slog(LG_ERROR, "services(): got parv with local channel: %s", parv[0]);
        return;
    }

    /* make a copy of the original for debugging */
    strlcpy(orig, parv[parc - 1], BUFSIZE);

    // Is this a message to a channel?
    if (parv[0][0] == '#')
        return;
    else
    {
        cmd = strtok(parv[parc - 1], " ");
        text = strtok(NULL, "");
    }

    if (!cmd)
        return;
    if (*cmd == '\001')
    {
        handle_ctcp_common(si, cmd, text);
        return;
    }

    /* take the command through the hash table */
    command_exec_split(si->service, si, cmd, text, &gs_cmdtree);
}
