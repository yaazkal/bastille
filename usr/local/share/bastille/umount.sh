#!/bin/sh
#
# Copyright (c) 2018-2020, Christer Edwards <christer.edwards@gmail.com>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of the copyright holder nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

. /usr/local/share/bastille/colors.pre.sh
. /usr/local/etc/bastille/bastille.conf

usage() {
    echo -e "${COLOR_RED}Usage: bastille umount TARGET container_path${COLOR_RESET}"
    exit 1
}

# Handle special-case commands first.
case "$1" in
help|-h|--help)
    usage
    ;;
esac

if [ $# -ne 2 ]; then
    usage
fi

TARGET=$1
shift

MOUNT_PATH=$1
shift

if [ "${TARGET}" = 'ALL' ]; then
    JAILS=$(jls name)
else
    JAILS=$(jls name | awk "/^${TARGET}$/")
fi

for _jail in ${JAILS}; do
    echo -e "${COLOR_GREEN}[${_jail}]:${COLOR_RESET}"

    _jailpath="${bastille_jailsdir}/${_jail}/root/${MOUNT_PATH}"

    if [ ! -d "${_jailpath}" ]; then
        echo -e "${COLOR_RED}The specified mount point does not exist inside the jail.${COLOR_RESET}"
        exit 1
    fi

    # Unmount the volume. -- cwells
    if ! umount "${_jailpath}"; then
        echo -e "${COLOR_RED}Failed to unmount volume: ${MOUNT_PATH}${COLOR_RESET}"
        exit 1
    fi

    # Remove the entry from fstab so it is not automounted in the future. -- cwells
    if ! sed -E -i '' "\, +${_jailpath} +,d" "${bastille_jailsdir}/${_jail}/fstab"; then
        echo -e "${COLOR_RED}Failed to delete fstab entry: ${_fstab_entry}${COLOR_RESET}"
        exit 1
    fi

    echo "Unmounted: ${MOUNT_PATH}"
    echo
done
