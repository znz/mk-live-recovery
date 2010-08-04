#!/bin/bash
{
	echo "${CD_ROOT}"
	echo "${WORKDIR}"
	echo "/dev/*"
	echo "/etc/ssh/ssh_host_*" # ssh host keys
	echo "/etc/udev/rules.d/70-persistent-*.rules" # cd, net
	echo "/lost+found"
	echo "/proc/*"
	echo "/sys/*"
	echo "/tmp/*"
	# echo "/var/lib/apt/lists/*"{Packages,Release,Sources}"*" # remove after apt-get
	echo "/var/lib/dbus/machine-id" # regenerate by dbus-uuidgen --ensure in /etc/init/dbus.conf
	echo "/var/lib/gdm/*" # home directory of gdm
	echo "/var/lib/logcheck/offset.var.log.*"
	echo "/var/lib/logrotate/status"
	echo "/var/lib/postgresql/.*_history" # bash, psql
	echo "/var/log/*.1" # rotated logs
	echo "/var/log/*.gz" # rotated logs
	echo "/var/log/gdm/*"
	echo "/var/log/installer" # OS installer
	echo "/var/log/samba/*"
	echo "/var/log/unattended-upgrades/*"
	echo /var/{lock,run,tmp}/\*
	echo /{root,home/\*,var/lib/gdm}/.{ICEauthority,cache,dbus,esd_auth,gconfd,pulse,pulse-cookie} # auth cookie, etc.
	echo /{root,home/\*}/.local/share/gvfs-metadata # avoid problems of gvfs
	echo /{root,home/\*}/.{aptitude,debtags,gksu.lock,synaptic,rnd,sudo_as_admin_successful} # trivial files
	echo /{root,home/\*}/.{ccache} # cache files
	echo /{root,home/\*}/.{compiz/session,metacity/sessions,nautilus,themes,thumbnails} # cache files
	echo /{root,home/\*}/.{gstreamer-\*,gvfs,mozilla/firefox/\*/Cache} # cache files
	echo /{root,home/\*}/.{{bash,psql}_history,font\*,icons,lesshst,recently-used\*,viminfo,xsession-errors\*} # history files
	echo /{root,home/\*}/tmp # temporary directory
	echo /{root,home/\*}/{Maildir,mbox} # mail
} | xargs -n1 -- printf -- '- %s\n'
