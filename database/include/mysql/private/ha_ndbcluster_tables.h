#ifndef HA_NDBCLUSTER_TABLES_INCLUDED
#define HA_NDBCLUSTER_TABLES_INCLUDED

/* Copyright (c) 2000-2003, 2006, 2007 MySQL AB, 2009 Sun Microsystems, Inc.
   Use is subject to license terms

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; version 2 of the License.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1335  USA
*/

#define NDB_REP_DB      "mysql"
#define OLD_NDB_REP_DB  "cluster"
#define NDB_REP_TABLE   "ndb_binlog_index"
#define NDB_APPLY_TABLE "ndb_apply_status"
#define OLD_NDB_APPLY_TABLE "apply_status"
#define NDB_SCHEMA_TABLE "ndb_schema"
#define OLD_NDB_SCHEMA_TABLE "schema"

#endif /* HA_NDBCLUSTER_TABLES_INCLUDED */
