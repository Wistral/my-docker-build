FROM ubuntu:20.04

ARG USERNAME=lfsdev
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG DEBIAN_FRONTEND="noninteractive"
ARG TZ="America/New_York"

ADD sources /sources
RUN ln -sf /bin/bash /bin/sh && apt-get update && apt-get install -qqy ca-certificates && \
    sed -i 's#security.ubuntu.com#mirrors.ustc.edu.cn/ubuntu#g' /etc/apt/sources.list &&\
    sed -i 's#archive.ubuntu.com#mirrors.ustc.edu.cn/ubuntu#g' /etc/apt/sources.list &&\
    apt-get update && apt install -qqy --no-install-recommends \
    binutils bison gawk make patch python3.8 texinfo xz-utils gcc-7 g++-7 &&\
    apt-get autoremove && apt-get autoclean &&\
    ln -sf /usr/bin/gcc-7 /usr/bin/gcc &&\
    ln -sf /usr/bin/g++-7 /usr/bin/g++ &&\
    ln -sf /usr/bin/python3.8 /usr/bin/python3 &&\
    echo "Collect Environment Info..." && export LFSSTAT=/LFS-stat.txt &&\
    bash --version | head -n1 | cut -d" " -f2-4 >> $LFSSTAT &&\
    echo -n "Binutils: $(ld --version | head -n1 | cut -d" " -f3-)" >> $LFSSTAT &&\
    bison --version | head -n1 >> $LFSSTAT &&\
    echo "/usr/bin/yacc -> `readlink -f /usr/bin/yacc`" >> $LFSSTAT &&\
    bzip2 --version 2>&1 < /dev/null | head -n1 | cut -d" " -f1,6- >> $LFSSTAT &&\
    diff --version | head -n1 >> $LFSSTAT &&\
    find --version | head -n1 >> $LFSSTAT &&\
    gawk --version | head -n1 >> $LFSSTAT &&\
    echo "/usr/bin/awk -> `readlink -f /usr/bin/awk`"; >> $LFSSTAT &&\
    gcc --version | head -n1 >> $LFSSTAT &&\
    g++ --version | head -n1 >> $LFSSTAT &&\
    ldd --version | head -n1 | cut -d" " -f2- >> $LFSSTAT &&\
    grep --version | head -n1 >> $LFSSTAT &&\
    gzip --version | head -n1 >> $LFSSTAT &&\
    cat /proc/version >> $LFSSTAT &&\
    m4 --version | head -n1 >> $LFSSTAT &&\
    make --version | head -n1 >> $LFSSTAT &&\
    patch --version | head -n1 >> $LFSSTAT &&\
    echo Perl `perl -V:version` >> $LFSSTAT &&\
    m4 --version | head -n1 >> $LFSSTAT &&\
    python3 --version >> $LFSSTAT &&\
    sed --version | head -n1 >> $LFSSTAT &&\
    tar --version | head -n1 >> $LFSSTAT &&\
    makeinfo --version | head -n1 >> $LFSSTAT &&\
    xz --version | head -n1 >> $LFSSTAT &&\
    cat $LFSSTAT
