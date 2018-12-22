#!/bin/sh

NODE=$1
USER=$2
CONSOLE_USER=${USER}--${NODE}
ROOTDIR=/opt/ssh-proxy-shell
KEYSDIR=${ROOTDIR}/keys
SHELLSDIR=${ROOTDIR}/shells

if [ ! -d ${SHELLSDIR} ]; then
    mkdir -p ${SHELLSDIR}
fi

if [ ! -f ${KEYSDIR}/${USER} ]; then
    echo Keys file not found: ${KEYSDIR}/${USER}
    exit
fi

echo Creating user: ${CONSOLE_USER}

echo "#!/bin/sh" > ${SHELLSDIR}/${CONSOLE_USER}.sh
echo "ssh ${USER}@${NODE}" >> ${SHELLSDIR}/${CONSOLE_USER}.sh
chmod +x ${SHELLSDIR}/${CONSOLE_USER}.sh

useradd -m -s ${SHELLSDIR}/${CONSOLE_USER}.sh ${CONSOLE_USER}

mkdir -p /home/${CONSOLE_USER}/.ssh
cp ${KEYSDIR}/${USER} /home/${CONSOLE_USER}/.ssh/authorized_keys
chown -R ${CONSOLE_USER} /home/${CONSOLE_USER}/.ssh

echo Done!
