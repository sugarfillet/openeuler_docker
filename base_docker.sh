#!/bin/bash
docker_repo='sugarfillet/oe'
docker_tag='aarch64'
build_tag=`uname -m`
fun='base'
url='http://101.133.144.110:65510/mnt/openeuler-1.0-2020-01_1.tar.xz'
tar_n=`basename $url`

# add qemu+bfm
if [[ $build_tag != 'aarch64' ]];then
docker run --rm --privileged multiarch/qemu-user-static:register --reset
fi

wget -N $url

mkdir for_build || rm -rf for_build/*
pushd for_build
cp ../${tar_n} .
cat > ./dockerfile << EOF
FROM scratch
ADD ${tar_n} /
CMD ["/bin/bash"]
EOF

docker build -t $docker_repo:${docker_tag}_${build_tag}_${fun} . 
popd

# TEST docker run 
docker run -it --rm $docker_repo:${docker_tag}_${build_tag}_${fun} bash -c 'cat /etc/os-release' 
