FROM debian:bookworm AS deb-src
COPY <<"EOF" /etc/apt/sources.list
deb http://deb.debian.org/debian bookworm main
deb-src http://deb.debian.org/debian bookworm main

deb http://deb.debian.org/debian-security/ bookworm-security main
deb-src http://deb.debian.org/debian-security/ bookworm-security main

deb http://deb.debian.org/debian bookworm-updates main
deb-src http://deb.debian.org/debian bookworm-updates main
EOF

FROM deb-src AS install-dependency
RUN <<"EOF"
apt-get update
apt-get install -y wget fakeroot git kernel-wedge quilt ccache flex bison libssl-dev dh-exec rsync libelf-dev bc crossbuild-essential-armhf python3-jinja2
EOF

FROM install-dependency AS download
RUN <<"EOF"
cd /root
wget https://raw.githubusercontent.com/alf45tar/debian-kernel/main/download_latest_bookworm_stable_sec_kernel.sh
wget https://raw.githubusercontent.com/alf45tar/debian-kernel/main/0001-ledtrig-sata-mv.patch
wget https://raw.githubusercontent.com/alf45tar/debian-kernel/main/disable_debug_info.sh
wget https://raw.githubusercontent.com/alf45tar/debian-kernel/main/crossbuild.sh
chmod 755 /root/download_latest_bookworm_stable_sec_kernel.sh
chmod 755 /root/disable_debug_info.sh
chmod 755 /root/crossbuild.sh
./download_latest_bookworm_stable_sec_kernel.sh
EOF

FROM download AS clone-git
RUN <<"EOF"
cd /root
git clone -n https://salsa.debian.org/kernel-team/linux.git debian-kernel
cd debian-kernel
git checkout bookworm
EOF
