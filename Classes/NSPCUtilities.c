/*
 *  NSPCUtilities.c
 *  AdiumSoul
 *
 *  Created by Naixn on 11/04/08.
 *  Copyright 2008 Epitech. All rights reserved.
 *
 */

#include "NSPCUtilities.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

char*   eval_carriage_returns(char *str)
{
    int i;
    int j;

    for (i = 0, j = 0; str[i]; i++, j++)
    {
        if (str[i] == '\\' && str[i + 1] && str[i + 1] == 'n')
        {
            str[j] = '\n';
            i++;
        }
        else
        {
            str[j] = str[i];
        }
    }
    str[j] = 0;
    return (str);
}

char*       secure_carriage_returns(char *str)
{
    int     i;
    int     len;
    char*   nstr = NULL;

    for (i = 0, len = 0; str[i]; i++, len++)
        if (str[i] == '\n')
            len++;
    nstr = calloc(len + 1, sizeof(char));
    for (; *str; str++)
    {
        if (*str == '\n')
        {
            sprintf(nstr, "%s\\n", nstr);
        }
        else
        {
            sprintf(nstr, "%s%c", nstr, *str);
        }
    }
    return (nstr);
}

char*       url_encode(unsigned char *str)
{
    char*   tmp;

    for (tmp = ""; str && *str; str++)
    {
        if ((*str >= 'a' && *str <= 'z') ||
            (*str >= 'A' && *str <= 'Z') ||
            (*str >= '0' && *str <= '9') ||
            *str == '_' || *str == '-' || *str == '.')
        {
            asprintf(&tmp, "%s%c", tmp, *str);
        }
        else
        {
            asprintf(&tmp, "%s%%%02X", tmp, *str);
        }
    }
    return (tmp);
}

char*       url_decode(char *str)
{
    int     i;
    int     j;
    char    nb[5];
    
    memset(nb, 0, 5);
    for (i = j = 0; str[i]; i++, j++)
    {
        if (str[i] == '%' && str[i + 1] &&
            ((str[i + 1] >= '0' && str[i + 1] <= '9') ||
             (str[i + 1] >= 'A' && str[i + 1] <= 'F') ||
             (str[i + 1] >= 'a' && str[i + 1] <= 'f')))
        {
            sprintf(nb, "0x%.2s", str + i + 1);
            str[j] = strtol(nb, 0, 16);
            i += 2;
        }
	    else
        {
            str[j] = str[i];
        }
    }
    str[j] = 0;
    return (str);
}


