#include "atheme.h"

DECLARE_MODULE_V1
(
        "groupserv/main", false, _modinit, _moddeinit,
        "$Revision$",
        "Stephen Bennett <stephen -at- freenode.net>"
);

service_t *gs;
mowgli_list_t gs_conftable;

void _modinit(module_t *m)
{
    gs = service_add("GroupServ", NULL, &gs_conftable);
}

void _moddeinit()
{
    service_delete(gs);
}
