#!/bin/bash
docker_repo='sugarfillet/oe'
docker_tag='aarch64'
build_tag=`uname -m`
fun='httpd'



# add qemu+bfm
if [[ $build_tag != 'aarch64' ]];then
	docker run --rm --privileged multiarch/qemu-user-static:register --reset
fi

mkdir for_build_httpd || rm -rf for_build_httpd/*
pushd for_build_httpd &>/dev/null

cat > ./dockerfile << EOF
FROM sugarfillet/oe:aarch64_aarch64_base
RUN cat > /etc/yum.repos.d/a.repo <<eof
[openeuler1]
name=mainline
baseurl=http://119.3.219.20:8080/Mainline/standard_aarch64/
enabled=1
gpgcheck=0

[openeuler2]
name=extras
baseurl=http://119.3.219.20:8080/Extras/standard_aarch64/
enabled=1
gpgcheck=0
eof && yum clean all && yum makecache \
&& yum install -y httpd && rm -rf /usr/share/man/*

EXPOSE 80
CMD ["/usr/sbin/httpd","-DFOREGROUND"]
EOF

docker build -t $docker_repo:${docker_tag}_${build_tag}_${fun} . 
popd &>/dev/null

# TEST docker run 
# docker run -it --rm $docker_repo:${docker_tag}_${build_tag}_${fun} bash -c 'cat /etc/os-release' 
