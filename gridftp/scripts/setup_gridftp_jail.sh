#!/bin/bash

# Overridable environment varibales:
# - ESG_GRIDFTP_ROOT_DIR
# - GRIDFTP_ACCOUNT
# - ESGINI
# - ESGF_REPO

DEFAULT_ESG_ROOT_DIR=${ESGF_HOME:-'/esg'}
DEFAULT_ESG_GRIDFTP_JAIL_DIR=${ESGF_GRIDFTP_JAIL_DIR:-'/esg/gridftp_root'}
DEFAULT_GRIDFTP_ACCOUNT=${GRIDFTP_ACCOUNT:-'globus'}
DEFAULT_ESGINI=${ESGINI:-'/esg/config/esgcet/esg.ini'}
DEFAULT_ESGF_REPO=${ESGF_REPO:-'http://distrib-coffee.ipsl.jussieu.fr/pub/esgf'}

# setup_gridftp_jail

echo "Creating chroot jail @ ${DEFAULT_ESG_GRIDFTP_JAIL_DIR}"
globus-gridftp-server-setup-chroot -r ${DEFAULT_ESG_GRIDFTP_JAIL_DIR}

mkdir -p "${DEFAULT_ESG_GRIDFTP_JAIL_DIR}/etc/grid-security/sharing/${DEFAULT_GRIDFTP_ACCOUNT}"
chown ${DEFAULT_GRIDFTP_ACCOUNT}:${DEFAULT_GRIDFTP_ACCOUNT_group} "${DEFAULT_ESG_GRIDFTP_JAIL_DIR}/etc/grid-security/sharing/${DEFAULT_GRIDFTP_ACCOUNT}"
chmod 700 "${DEFAULT_ESG_GRIDFTP_JAIL_DIR}/etc/grid-security/sharing/${DEFAULT_GRIDFTP_ACCOUNT}"

[ ! -e "${DEFAULT_ESGINI}" ] && echo "Cannot find esg.ini=[${DEFAULT_ESGINI}] file that describes data dir location" && exit 1
echo "Reading esg.ini=[${DEFAULT_ESGINI}] for thredds_dataset_roots to mount..."

while read mount_name mount_dir; do
  [ -z ${mount_name} ] && debug_print "blank entry: [${mount_name}]" && continue;
  [ -z ${mount_dir} ] && debug_print "blank dir entry: [${mount_dir}]" && continue;
  echo "mounting [${mount_dir}] into chroot jail [${DEFAULT_ESG_GRIDFTP_JAIL_DIR}/] as [${mount_name##*/}]"
  if [ -z "${mount_name}" ] || [ -z "${mount_dir}" ] ; then
    echo 'WARNING: Was not able to find the mount directory [${mount_dir}] or mount name [${mount_name}] to use for proper chroot gridftp installation!!!'
    exit 999
  fi
  real_mount_dir=$(readlink -f ${mount_dir})
  gridftp_mount_dir=${DEFAULT_ESG_GRIDFTP_JAIL_DIR}/${mount_name##*/}
  chroot_mount=($(mount -l | grep ^${real_mount_dir}' ' | awk '{print $3}' | sort -u))
  if (( ${#chroot_mount[@]} == 0 )); then
    [ ! -e ${gridftp_mount_dir}} ] && mkdir -p ${gridftp_mount_dir}
    ((DEBUG)) && echo "mount --bind ${real_mount_dir} ${gridftp_mount_dir}"
    mount --bind ${real_mount_dir} ${gridftp_mount_dir}
  else
    echo "There is already a mount for [${mount_dir}] -> [${chroot_mount}] on this host, NOT re-mounting"
  fi
done < <(echo "$(python <(curl -s ${DEFAULT_ESGF_REPO}/dist/utils/pull_key.py) -k thredds_dataset_roots -f ${DEFAULT_ESGINI} | awk ' BEGIN {FS="|"} { if ($0 !~ /^[[:space:]]*#/) {print $1" "$2}}')")

# post_gridftp_jail_setup()

#Write our trimmed version of /etc/password in the chroot location 
[ ! -e ${DEFAULT_ESG_GRIDFTP_JAIL_DIR} ] && exit 1
if $(echo "${DEFAULT_ESG_GRIDFTP_JAIL_DIR}" | grep "${DEFAULT_ESG_ROOT_DIR}" >& /dev/null); then echo "legal chroot location"; else (echo "illegal chroot location: ${DEFAULT_ESG_GRIDFTP_JAIL_DIR}" && exit 1); fi

# Add a test data file if already not added
if [ ! -f ${DEFAULT_ESG_GRIDFTP_JAIL_DIR}/esg_dataroot/test/sftlf.nc ]; then
  mkdir -p ${DEFAULT_ESG_GRIDFTP_JAIL_DIR}/esg_dataroot/test
  echo test > ${DEFAULT_ESG_GRIDFTP_JAIL_DIR}/esg_dataroot/test/sftlf.nc
fi

echo -n "writing sanitized passwd file to [${DEFAULT_ESG_GRIDFTP_JAIL_DIR}/etc/passwd]"
if [ -e ${DEFAULT_ESG_GRIDFTP_JAIL_DIR}/etc/passwd ]; then
  cat > ${DEFAULT_ESG_GRIDFTP_JAIL_DIR}/etc/passwd <<EOF
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/dev/null
ftp:x:14:50:FTP User:/var/ftp:/dev/null
globus:x:101:156:Globus System User:/home/globus:/bin/bash
EOF
  echo " [OK]"
else
  echo " [FAILED]"
fi

# Write our trimmed version of /etc/group in the chroot location
echo -n "writing sanitized group file to [${DEFAULT_ESG_GRIDFTP_JAIL_DIR}/etc/group]"
if [ -e ${DEFAULT_ESG_GRIDFTP_JAIL_DIR}/etc/group ]; then
  cat > ${DEFAULT_ESG_GRIDFTP_JAIL_DIR}/etc/group <<EOF
root:x:0:root
bin:x:1:root,bin,daemon
ftp:x:50:
globus:x:156:
EOF
  echo " [OK]"
else
  echo " [FAILED]"
fi

echo -n " syncing local certificates into chroot jail... "
[ -n "${DEFAULT_ESG_GRIDFTP_JAIL_DIR}" ] && [ "${DEFAULT_ESG_GRIDFTP_JAIL_DIR}" != "/" ] && [ -e "${DEFAULT_ESG_GRIDFTP_JAIL_DIR}/etc/grid-security/certificates" ] && \
rm -rf ${DEFAULT_ESG_GRIDFTP_JAIL_DIR}/etc/grid-security/certificates && \
mkdir -p ${DEFAULT_ESG_GRIDFTP_JAIL_DIR}/etc/grid-security && \
(cd /etc/grid-security; tar cpf - certificates) | tar xpf - -C ${DEFAULT_ESG_GRIDFTP_JAIL_DIR}/etc/grid-security
[ $? == 0 ] && echo "[OK]" || echo "[FAIL]"

# Don't modify the esg.ini concerning the thredds_file_services

service globus-gridftp-server start