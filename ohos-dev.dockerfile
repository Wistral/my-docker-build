FROM ubuntu:20.04

ARG USERNAME=ohosdev
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG DEBIAN_FRONTEND="noninteractive"
ARG TZ="America/New_York"

ARG GCC_RISCV=gcc_riscv32-linux-7.3.0.tar.gz
ARG GCC_RISCV_URL=https://repo.huaweicloud.com/harmonyos/compiler/gcc_riscv32/7.3.0/linux/gcc_riscv32-linux-7.3.0.tar.gz
ARG GN=gn-linux-x86-1717.tar.gz
ARG GN_URL=https://repo.huaweicloud.com/harmonyos/compiler/gn/1717/linux/gn-linux-x86-1717.tar.gz
ARG HCGEN=hc-gen-0.65-linux.tar
ARG HCGEN_URL=https://repo.huaweicloud.com/harmonyos/compiler/hc-gen/0.65/linux/hc-gen-0.65-linux.tar
ARG NINJA=ninja.1.9.0.tar
ARG NINJA_URL=https://repo.huaweicloud.com/harmonyos/compiler/ninja/1.9.0/linux/ninja.1.9.0.tar

ARG APT_PKGS="wget git vim python3.8 python3-pip bc build-essential gcc g++ make zlib* libffi-dev sudo \
    binutils git-core gnupg flex bison gperf build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev \
    x11proto-core-dev libx11-dev lib32z-dev ccache libgl1-mesa-dev libxml2-utils xsltproc unzip m4"
ARG PIP_PKGS="kconfiglib pycryptodome ecdsa scons pyyaml requests ohos-build"

RUN apt update && apt install -y ca-certificates && sed -i 's#security.ubuntu.com#mirrors.tuna.tsinghua.edu.cn#g' /etc/apt/sources.list &&\
    apt update && ln -sf /bin/bash /bin/sh && apt install -y $APT_PKGS &&\
    apt autoremove && apt autoclean &&\
    ln -sf $(which python3.8) /usr/bin/python &&\
    ln -sf $(which python3.8) /usr/bin/python3

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# [Optional] Set the default user. Omit if you want to keep the default as root.
USER $USERNAME
WORKDIR /home/$USERNAME

ADD $GCC_RISCV .
ADD $GN .local/bin/
ADD $HCGEN .
ADD $NINJA .

RUN sudo chown -R $USERNAME:$USERNAME .local &&\
    sudo mv $(pwd)/ninja/ninja   ~/.local/bin/ && sudo  rm -rf $(pwd)/ninja &&\
    sudo mv $(pwd)/hc-gen/hc-gen ~/.local/bin/ && sudo  rm -rf $(pwd)/hc-gen &&\
    echo "export PATH=~/.local/bin:~/gcc_riscv32/bin:\$PATH" >> ~/.bashrc  && source ~/.bashrc &&\
    python -m pip install --upgrade pip -i https://pypi.tuna.tsinghua.edu.cn/simple &&\
    python -m pip install $PIP_PKGS \
    -i https://pypi.tuna.tsinghua.edu.cn/simple --trusted-host pypi.tuna.tsinghua.edu.cn &&\
    rm -rf $(python -m pip cache dir) && mkdir ~/ohos

WORKDIR /home/$USERNAME/ohos
