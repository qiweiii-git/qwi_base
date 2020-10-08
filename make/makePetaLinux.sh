#*****************************************************************************
# makePetaLinux.sh
#
# Change History:
#  VER.   Author         DATE              Change Description
#  1.0    Qiwei Wu       Oct.07, 2020      Initial Release
#*****************************************************************************
#!/bin/bash

BuildDir='.buildPetaLinux'
CreateNew='1'

PrjName=$1
SrcFileDir=$2
CreateNew=$3

if [ ! -d $BuildDir ]; then
   CreateNew='1'
fi

#make dir
if [ $CreateNew -eq 1 ]; then
   if [ -d $BuildDir ]; then
      echo "Warning: Building Directory $BuildDir Exist"
      rm -r $BuildDir
      echo "Info: Old Building Directory $BuildDir Removing"
   fi
   mkdir $BuildDir
   echo "Info: Building Directory $FileSys/$BuildDir Establish"

   #copy files
   cp $SrcFileDir/* $BuildDir -r
fi

# petalinux configure
cd $BuildDir
if [ $CreateNew -eq 1 ]; then
   petalinux-create --type project --template zynq --name $PrjName
fi

cd $PrjName
if [ $CreateNew -eq 1 ]; then
   petalinux-config --get-hw-description ../
else
   petalinux-config
fi

# petalinux custom app
if [ $CreateNew -eq 1 ]; then
   petalinux-create -t apps --template c --name $PrjName --enable
fi
cp ../../software/* components/apps/$PrjName/

#petalinux-config -c kernel
#petalinux-config -c rootfs

# petalinux build
petalinux-build

# petalinux package
petalinux-package --boot --fsbl ./images/linux/zynq_fsbl.elf --fpga ../$PrjName.bit --uboot --force

#finish building
sleep 2
echo "Info: $PrjName Petalinux project finish building"

#copy the BOOT.bin file
cd ./images/linux
if [ -f BOOT.BIN ]; then
   cp image.ub ../../../../$SrcFileDir
   cp BOOT.BIN ../../../../$SrcFileDir
   echo "Info: BOOT.BIN file moved to $SrcFileDir"
   cd ../../../../
   #clean
   #rm -rf $BuildDir
   echo "Info: BOOT.BIN file finish making"
   echo -e "\n   Success \n"
else
   echo "Error: $PrjName Petalinux Project built failed"
   echo "Error: $PrjName Petalinux Project make failed"
   echo -e "\n   Failure \n"
fi

