#############################################################
#
# pkgconfig
#
#############################################################
PKGCONFIG_VERSION:=0.23
PKGCONFIG_SOURCE:=pkg-config-$(PKGCONFIG_VERSION).tar.gz
PKGCONFIG_SITE:=http://pkgconfig.freedesktop.org/releases/
PKGCONFIG_DIR:=$(BUILD_DIR)/pkg-config-$(PKGCONFIG_VERSION)
PKGCONFIG_CAT:=$(ZCAT)
PKGCONFIG_BINARY:=pkg-config
PKGCONFIG_TARGET_BINARY:=usr/bin/pkg-config

$(DL_DIR)/$(PKGCONFIG_SOURCE):
	 $(call DOWNLOAD,$(PKGCONFIG_SITE),$(PKGCONFIG_SOURCE))

pkgconfig-source: $(DL_DIR)/$(PKGCONFIG_SOURCE)

$(PKGCONFIG_DIR)/.unpacked: $(DL_DIR)/$(PKGCONFIG_SOURCE)
	$(PKGCONFIG_CAT) $(DL_DIR)/$(PKGCONFIG_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	toolchain/patch-kernel.sh $(PKGCONFIG_DIR) package/pkgconfig/ \*.patch
	touch $@

$(PKGCONFIG_DIR)/.configured: $(PKGCONFIG_DIR)/.unpacked
	(cd $(PKGCONFIG_DIR); rm -rf config.cache; \
		./configure \
		--prefix=/usr \
		--sysconfdir=/etc \
		--with-pc-path="$(STAGING_DIR)/usr/lib/pkgconfig" \
		$(DISABLE_NLS) \
		$(DISABLE_LARGEFILE) \
	)
	touch $@

$(PKGCONFIG_DIR)/$(PKGCONFIG_BINARY): $(PKGCONFIG_DIR)/.configured
	$(MAKE) -C $(PKGCONFIG_DIR)

$(STAGING_DIR)/$(PKGCONFIG_TARGET_BINARY): $(PKGCONFIG_DIR)/$(PKGCONFIG_BINARY)
	$(MAKE) DESTDIR=$(STAGING_DIR) -C $(PKGCONFIG_DIR) install
	rm -rf $(STAGING_DIR)/usr/share/man

pkgconfig: uclibc $(STAGING_DIR)/$(PKGCONFIG_TARGET_BINARY)

pkgconfig-clean:
	-$(MAKE) DESTDIR=$(STAGING_DIR) -C $(PKGCONFIG_DIR) uninstall
	-$(MAKE) -C $(PKGCONFIG_DIR) clean

pkgconfig-dirclean:
	rm -rf $(PKGCONFIG_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(BR2_PACKAGE_PKGCONFIG),y)
TARGETS+=pkgconfig
endif
