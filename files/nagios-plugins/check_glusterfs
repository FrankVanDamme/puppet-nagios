#!/bin/bash

# check_glusterfs_mount - plugin for nagios to check that a glusterfs partition
#                         is correctly mounted
# Copyright (C) 2008 Ioannis Aslanidis (deathwing00 at deathwing00 dot org)
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Library General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

TIMELIMIT=5   # We allow 5 seconds for ls to run. If it does not, we consider it has hanged.
TOTALPARAMS=1 # Total number of expected parameters.
MINLINES=2    # If we find less that these number of lines, we understand that there was an error.

TryList()
{
  # We only expect one parameter: the path to check.
  path=${1}
  # List the contents of the path and verify that the output is correct
  numlines=$(/bin/ls -l ${path} | /bin/wc -l)
  if [ ${numlines} -lt ${MINLINES} ]; then
    echo CRITICAL: GlusterFS mount point is not working correctly.
    exit 2
  fi
}  

TimerOn()
{
  /bin/sleep ${TIMELIMIT} && /bin/kill -s 14 ${$} &
  # Waits some seconds, then sends sigalarm to script.
}  

Int14Vector()
{
  echo CRITICAL: GlusterFS mount point does not seem to work. Could not list the contents!
  exit 2
}
 
# Timer interrupt (14) subverted for our purposes.
trap Int14Vector 14

# Check that the total number of parameters is correct.
if [ ${#} -ne ${TOTALPARAMS} ]; then
  echo UNKNOWN: Script was executed with incorrect number of arguments. Check could not be performed.
  exit 3
fi

# Start the timer.
TimerOn
# Make the call.
TryList ${1}

# If we get past this point it means that everything went fine.

# Return success.
echo OK: GlusterFS mount seems to be working correctly

# Kill the alarm timer, we do not need it any more. (bash will write to stdout about the process that got killed, redirecting makes no sense here)
/bin/kill ${!}

# Exit with success
exit 0
