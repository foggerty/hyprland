#!/bin/sh
# https://www.jamescherti.com/compiling-emacs/

set -o errexit

mkdir -p ~/dev

pushd ~/dev

if [[ ! -d "emacs" ]]; then
    git clone https://github.com/emacs-mirror/emacs --depth=1 --branch emacs-30
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
    --disable-acl \
    --disable-gc-mark-trace \
    --enable-link-time-optimization \
    --disable-xattr \
    --with-cairo \
    --with-file-notification=inotify \
    --with-gsettings \
    --with-harfbuzz \
    --with-imagemagick \
    --with-libsystemd \
    --with-modules \
    --with-pgtk \
    --with-small-ja-dic \
    --with-threads \
    --with-tree-sitter \
    --with-xml2 \
    --with-libgmp \
    --without-gconf \
    --without-gpm \
    --without-hesiod \
    --without-imagemagick \
    --without-included-regex \
    --without-kerberos \
    --without-kerberos5 \
    --without-libotf \
    --without-mail-unlink \
    --without-pop \
    --without-gif \
    --without-jpeg \
    --without-png \
    --without-rsvg \
    --without-tiff \
    --without-xpm \
    --without-webp \
    --without-selinux \
    --without-sound \
    --without-x \
    --without-xaw3d \
    --without-xdbe \
    --without-xdbe \
    --without-xft \
    --without-xim \
    --without-xinput2

#export CFLAGS="-O2 -pipe -march=native -mtune=native -fno-omit-frame-pointer -fno-plt -flto=auto"
export CFLAGS="-O2 -pipe -march=native -mtune=native -fno-omit-frame-pointer -flto=auto"

#export LDFLAGS="-Wl,-O2 -Wl,-z,now -Wl,-z,relro -Wl,--sort-common -Wl,--as-needed -Wl,-z,pack-relative-relocs -flto=auto"
export LDFLAGS="-Wl,-O2 -Wl,--sort-common -Wl,--as-needed -Wl,-z,pack-relative-relocs -flto=auto"

export MAKEFLAGS="-j$(nproc)"

make && sudo make install-strip

popd
popd
