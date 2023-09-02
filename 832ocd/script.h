#ifndef SCRIPT_H
#define SCRIPT_H

#include "832ocd_connection.h"
#include "frontend.h"

int execute_script(struct ocd_frontend *ui,struct ocd_connection *con,const char *filename);


#endif

