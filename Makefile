CURL_VERSION := 8.23.0
CURL_SHA256  := e3de77cfa6367083c776a26647fc9f633b538c06c3baa73d931a252ac8f72b49
CURL_URL     := https://curl.se/download/curl-$(CURL_VERSION).tar.gz

CURL_TARBALL := curl-$(CURL_VERSION).tar.gz
CURL_DIR     := curl-$(CURL_VERSION)
CURL_BIN     := $(CURL_DIR)/src/curl

CONFIGURE_FLAGS := \
	--with-openssl \
	--without-libpsl \
	--without-libssh2 \
	--without-libssh \
	--without-librtmp \
	--disable-ftp \
	--disable-file \
	--disable-ipfs \
	--disable-ldap \
	--disable-ldaps \
	--disable-rtsp \
	--disable-dict \
	--disable-tftp \
	--disable-pop3 \
	--disable-imap \
	--disable-smtp \
	--disable-smb \
	--disable-gopher \
	--disable-mqtt \
	--disable-websockets \
	--disable-docs \
	--disable-manual

NPROC := $(shell nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 1)

.PHONY: all clean
.DELETE_ON_ERROR:

all: $(CURL_BIN)
	cd $(CURL_DIR)/src && ./curl --version

$(CURL_TARBALL):
	curl -fsSL --retry 3 -o $@ $(CURL_URL)
	echo "$(CURL_SHA256)  $@" | sha256sum -c -

$(CURL_DIR)/configure: $(CURL_TARBALL)
	tar xzf $<
	touch $@

$(CURL_DIR)/Makefile: $(CURL_DIR)/configure
	cd $(CURL_DIR) && ./configure $(CONFIGURE_FLAGS)

$(CURL_BIN): $(CURL_DIR)/Makefile
	$(MAKE) -C $(CURL_DIR) -j$(NPROC)

clean:
	rm -rf $(CURL_DIR) $(CURL_TARBALL)
