构建基于 PHH 的 LineageOS GSI
要开始构建 LineageOS GSI，您需要熟悉Git 和 Repo，并参考LineageOS Wiki（主要是“安装构建包”）和如何构建 GSI来设置您的环境。

安装依赖项和 Repo ### (sudo apt-get update)
需要几个包才能构建
```
sudo apt install bc bison build-essential ccache curl flex g++-multilib gcc-multilib git gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev liblz4-tool libncurses5 libncurses5-dev libsdl1.2-dev libssl-dev libwxgtk3.0-gtk3-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev python3.10.4
```
补充
```
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt-get update
sudo apt-get install python3.6
```
安装 Repo 工具
```
mkdir ~/bin
PATH=~/bin:$PATH
git clone https://gerrit-googlesource.lug.ustc.edu.cn/git-repo
cd git-repo/
cp repo ~/bin/
chmod a+x ~/bin/repo
cd
```

首先，打开一个新的终端窗口，为您的 LineageOS 构建（例如 leaos）创建一个新的工作目录并导航到它：

    mkdir leaos; cd leaos
    
在此处克隆修改后的 treble_experimentations 存储库：

   git 克隆 https://github.com/wugo2021/treble_experimentations

初始化您的 LineageOS 工作区：

    repo init -u https://github.com/LineageOS/android.git -b lineage-18.1

克隆这个和补丁回购：

    git clone https://github.com/wugo2021/lineage_build_unified lineage_build_unified -b lineage-18.1
    git clone https://github.com/wugo2021/lineage_patches_unified lineage_patches_unified -b lineage-18.1


最后，启动构建脚本

    bash lineage_build_unified/buildbot_unified.sh treble 64B

最后，启动构建脚本（动态根目录）：

    bash lineage_build_unified/buildbot_unified.sh treble 64BZ
    
最后，启动构建脚本——例如，为所有支持的架构构建：

    bash lineage_build_unified/buildbot_unified.sh treble A64B A64BG 64B 64BG
    
或包含 AndyCG 补丁

    bash lineage_build_unified/buildbot_unified.sh treble personal iceows 64BZ

或者也包括 Iceows 补丁

    bash lineage_build_unified/buildbot_unified.sh treble personal iceows 64BZ

请务必不时更新克隆的存储库！


注意：A-only 和 VNDKLite 目标是从 AB 图像而不是源代码生成的 - 请参阅 [sas-creator](https://github.com/wugo2021/sas-creator)。 HI6250设备参考[huawei-creator](https://github.com/wugo2021/huawei-creator)。


此脚本还用于制作特定于设备和/或个人的构建。 为此，请理解脚本，并尝试使用“device”和“personal”关键字。     



    bash lineage_build_unified/buildbot_unified.sh treble 64BN
    
.
    
    build/soong/soong_ui.bash --make-mode
