# SwiftAndroid-Toolchain

This Vagrant config is inspired by [SwiftAndroid-Vagrant](https://github.com/safx/SwiftAndroid-Vagrant.git) by Safx

## Usage

```bash
git clone https://github.com/safx/SwiftAndroid-Vagrant.git
cd SwiftAndroid-Toolchain
vagrant up  # wait for up to a few hours for swift to build
# Hopefully the process ends with a 'hello world' being successfully built
ls SwiftAndroid.tar.gz # Swift toolchain tar.gz
vagrant halt
```
