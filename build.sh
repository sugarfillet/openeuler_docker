#!/bin/bash

#check yum env 
rpm -qa |grep yum &>/dev/null
if [[ $? != 0 ]];then
	echo "Error: no yum env"	
	exit 2
fi

local_arch=`uname -m`
if [[ $local_arch == 'x86_64' ]];then
	echo "Hint: x86_64 build is not supported now"
	exit
fi

repo_path='/etc/yum.repos.d/localmount.repo'
install_dir='/oeoe'
mount_dir='/tmp/for_mount'
target_dir=`basename 1.0-1205-aarch64`

# wget iso 
url=`cat ${target_dir}/url`
wget -N $url 

# mount iso 
mkdir -p $mount_dir || umount $mount_dir
mount ${url##*/} $mount_dir

# create repo 
cat > $repo_path << EOF
[local]
name=local
baseurl=file://$mount_dir
enabled=1
gpgcheck=0
EOF

# dnf installroot 
mkdir -p $install_dir || rm -rf $install_dir/*
yum install --repo=local --installroot=$install_dir --setopt=install_weak_deps=False -y yum vi 

# tar create rootfs.gz 
pushd $install_dir
tar czf openeuler-1.0-2020-01.tar.gz .
popd
umount $mount_dir
rm -rf  $repo_path

# dockerfile 
mkdir -p for_build || rm -rf for_build/*
cp -f $install_dir/openeuler-1.0-2020-01.tar.gz for_build

cat > for_build/dockerfile << EOF
FROM scratch
ADD openeuler-1.0-2020-01.tar.gz /
CMD ["/bin/bash"]
EOF

# docker build 
pushd for_build
docker build -t sugarfillet/openeuler:aarch64 . 
popd
docker image ls 

# dockerfile slim
# docker build  

# TEST docker run 
docker run -it --rm sugarfillet/openeuler:aarch64 bash -c 'cat /etc/os-release' 
