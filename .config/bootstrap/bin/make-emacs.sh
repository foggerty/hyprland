#!/bin/sh
# https://www.jamescherti.com/compiling-emacs/

set -o errexit

mkdir -p ~/dev

pushd ~/dev

if [[ ! -d "emacs" ]]; then
    git clone https://github.com/emacs-mirror/emacs --depth=1 --branch emacs-31
    pushd emacs
else
    pushd emacs

    git reset --hard HEAD
    git clean -f -d -x
    rm -rf .git/hooks/*

    git pull --rebase
fi

./autogen.sh

./configure \
    --disable-gc-mark-trace \
    --disable-xattr \
    --enable-gtk-deprecation-warnings \
    --with-file-notification=inotify \
    --with-imagemagick \
    --with-libsystemd \
    --with-pgtk \
    --with-small-ja-dic\
    --with-tree-sitter \
    --without-hesiod \
    --without-mail-unlink \
    --without-pop \
    --without-selinux \
    --without-sound \
    --without-xaw3d \
    --without-xdbe \
    --without-xim \
    --without-xinput2

export CFLAGS="-O2 -pipe -march=native -mtune=native -fno-omit-frame-pointer -fno-plt -flto=auto"
export LDFLAGS="-Wl,-O2 -Wl,--sort-common -Wl,--as-needed -Wl,-z,pack-relative-relocs -flto=auto"
export MAKEFLAGS="-j$(nproc)"

make && sudo make install-strip

popd
popd
