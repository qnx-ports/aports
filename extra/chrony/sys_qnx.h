/*
  chronyd/chronyc - Programs for keeping computer clocks accurate.

 **********************************************************************
 * Copyright (C) Richard P. Curnow  1997-2001
 * Copyright (C) J. Hannken-Illjes  2001
 * Copyright (C) Bryan Christianson 2015
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of version 2 of the GNU General Public License as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 *
 **********************************************************************

  =======================================================================

  Header file for QNX driver

  */

#ifndef GOT_SYS_QNX_H
#define GOT_SYS_QNX_H

#include "adjtime_qnx.h"

#include "sys.h"

void SYS_QNX_DropRoot(uid_t uid, gid_t gid, SYS_ProcessContext context);
void SYS_QNX_Initialise(void);
void SYS_QNX_Finalise(void);

#endif


