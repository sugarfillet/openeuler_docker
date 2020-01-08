#!/bin/bash

repo_path='/etc/yum.repos.d/localmount.repo'
install_dir='/oeoe'
mount_dir='/tmp/for_mount'
tar_name='openeuler-1.0-2020-01.tar'

recover_env(){
umount $mount_dir
rm -rf $mount_dir
rm -rf $install_dir
rm -rf $repo_path
mv /opt/*.repo /etc/yum.repos.d/
}

trap "recover_env" 2

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


# wget iso 
url='http://openeuler-os-image.obs.cn-north-4.myhuaweicloud.com/openEuler-1.0-1205-aarch64-dvd.iso'
wget -N $url 

# mount iso 
mkdir -p $mount_dir 
mount ${url##*/} $mount_dir

# create repo 
mv /etc/yum.repos.d/*.repo /opt
cat > $repo_path << EOF
[local]
name=local
baseurl=file://$mount_dir
enabled=1
gpgcheck=0
EOF

# dnf installroot 
mkdir  -p $install_dir 
#yum install --repo=local --installroot=$install_dir --setopt=install_weak_deps=False -y yum vi 
yum install --installroot=$install_dir --setopt=install_weak_deps=False -y yum vi 

# tar create rootfs.tar 
pushd $install_dir
tar --exclude=${tar_name} -cf ${tar_name} .
popd


# dockerfile 
mkdir for_build || rm -rf for_build/*
cp -f $install_dir/${tar_name} for_build

cat > for_build/dockerfile << EOF
FROM scratch
ADD ${tar_name} /
CMD ["/bin/bash"]
EOF

# docker build 
pushd for_build
docker build -t sugarfillet/openeuler:aarch64 . 
popd
docker image ls  |grep sugarfillet

# dockerfile slim
# docker build  

# TEST docker run 
docker run -it --rm sugarfillet/openeuler:aarch64 bash -c 'cat /etc/os-release' 

# recover env
recover_env
