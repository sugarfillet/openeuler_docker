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
RUN echo '[openeuler1]' > /etc/yum.repos.d/a.repo && \
echo -e "name=mainline\nbaseurl=http://119.3.219.20:8080/Mainline/standard_aarch64/\nenabled=1\ngpgcheck=0" >> /etc/yum.repos.d/a.repo && \
echo -e "[openeuler2]\nname=extras\nbaseurl=http://119.3.219.20:8080/Extras/standard_aarch64/\nenabled=1\ngpgcheck=0" >> /etc/yum.repos.d/a.repo \
&& dnf clean all && dnf makecache \
&& dnf install -y httpd && rm -rf /usr/share/man/*
EXPOSE 80
CMD ["/usr/sbin/httpd","-DFOREGROUND"]
EOF

docker build -t $docker_repo:${docker_tag}_${build_tag}_${fun} . 
popd &>/dev/null

# TEST docker run 
docker run -p 8888:80 -itd $docker_repo:${docker_tag}_${build_tag}_${fun}
curl localhost:8888 &>/dev/null && echo "app docker yes"

