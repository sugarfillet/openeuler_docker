#!/bin/bash
docker_repo='sugarfillet/oe'
docker_tag='aarch64'
build_tag=`uname -m`
fun='base'
url='http://101.133.144.110:65510/mnt/openeuler-1.0-2020-01_1.tar.xz'



# add qemu+bfm
if [[ $build_tag != 'aarch64' ]];then
docker run --rm --privileged multiarch/qemu-user-static:register --reset
fi

mkdir for_build || rm -rf for_build/*
pushd for_build

cat > ./dockerfile << EOF
FROM scratch
ADD ${url} /
RUN rpm -e --nodeps abattis-cantarell-fonts adwaita-icon-theme at-spi2-atk at-spi2-core \
atk augeas autoconf autogen automake binutils cairo color-filesystem \
colord cpp crontabs dwz efi-srpm-macros emacs-filesystem findutils \
fontconfig fontpackages-filesystem freetype fribidi fros fuse \
gamin gc gcc gdk-pixbuf2 gobject-introspection graphite2 groff \
gsettings-desktop-schemas gtk3 guile harfbuzz hicolor-icon-theme \
jasper jbigkit kernel-devel lcms2 logrotate m4 mozjs52 newt \
pango pixman pkgconf qt5-srpm-macros rest satyr shared-mime-info \
slang subscription-manager-rhsm-certificates systemtap-sdt-devel \
tcl unzip wayland webkit2gtk3-jsc which xkeyboard-config \
xmlrpc-c zip &>/dev/null
CMD ["/bin/bash"]
EOF

docker build -t $docker_repo:${docker_tag}_${build_tag}_${fun} . 
popd

# TEST docker run 
docker run -it --rm $docker_repo:${docker_tag}_${build_tag}_${fun} bash -c 'cat /etc/os-release' 
