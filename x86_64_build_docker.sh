#!/bin/bash
docker_repo='sugarfillet/openeuler'
docker_tag='aarch64'
url='http://101.133.144.110:65510/mnt/openeuler-1.0-2020-01_1.tar.xz'
tar_nam=`basename $url`

wget -N $url 

mkdir for_build || rm -rf for_build/*
pushd for_build
cp ../$tar_nam .
cat > ./dockerfile << EOF
FROM scratch
ADD ${tar_nam} /
CMD ["/bin/bash"]
EOF
docker build -t $docker_repo:$docker_tag . 
popd

# add qemu+bfm
docker run --rm --privileged multiarch/qemu-user-static:register --reset
# TEST docker run 
docker run -it --rm $docker_repo:$docker_tag bash -c 'cat /etc/os-release' 

