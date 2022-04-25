
## Building PHH-based LineageOS GSIs ##

To get started with building LineageOS GSI, you'll need to get familiar with [Git and Repo](https://source.android.com/source/using-repo.html), and set up your environment by referring to [LineageOS Wiki](https://wiki.lineageos.org/devices/redfin/build) (mainly "Install the build packages") and [How to build a GSI](https://github.com/phhusson/treble_experimentations/wiki/How-to-build-a-GSI%3F).
 ### Installing dependencies and Repo ### (sudo apt-get update)

Several packages are needed in order to build crDroid
```
sudo apt-get update
```
```
sudo apt install bc bison build-essential ccache curl flex g++-multilib gcc-multilib git gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev liblz4-tool libncurses5 libncurses5-dev libsdl1.2-dev libssl-dev libwxgtk3.0-gtk3-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev python3.10.4
```
Replenish
```
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt-get update
sudo apt-get install python3.6
```
Install Repo tool
```
mkdir ~/bin
PATH=~/bin:$PATH
git clone https://gerrit-googlesource.lug.ustc.edu.cn/git-repo
cd git-repo/
cp repo ~/bin/
chmod a+x ~/bin/repo
cd
```
First, open a new Terminal window, which defaults to your home directory.  Clone the modified treble_experimentations repo there:

    git clone https://github.com/AndyCGYan/treble_experimentations

Create a new working directory for your LineageOS build and navigate to it:

    mkdir lineage-18.x-build-gsi; cd lineage-18.x-build-gsi


Initialize your LineageOS workspace:

    repo init -u https://github.com/LineageOS/android.git -b lineage-19.0

Clone both this and the patches repos:

    git clone https://github.com/wugo2021/lineage_build_unified lineage_build_unified -b lineage-19.0
    git clone https://github.com/wugo2021/lineage_patches_unified lineage_patches_unified -b lineage-19.0

Finally, start the build script - for example, to build for all supported archs:

    bash lineage_build_unified/buildbot_unified.sh treble A64B A64BG 64B 64BG
.

    bash lineage_build_unified/buildbot_unified.sh treble 64B

Be sure to update the cloned repos from time to time!

---

Note: A-only and VNDKLite targets are generated from AB images instead of source-built - refer to [sas-creator](https://github.com/AndyCGYan/sas-creator).

---

This script is also used to make device-specific and/or personal builds. To do so, understand the script, and try the `device` and `personal` keywords.
