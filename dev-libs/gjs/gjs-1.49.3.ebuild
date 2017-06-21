# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit gnome2 pax-utils virtualx

DESCRIPTION="Javascript bindings for GNOME"
HOMEPAGE="https://wiki.gnome.org/Projects/Gjs"

LICENSE="MIT || ( MPL-1.1 LGPL-2+ GPL-2+ )"
SLOT="0"
IUSE="+cairo examples gtk test"

KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~sparc ~x86"

RDEPEND="
	>=dev-libs/glib-2.36:2
	>=dev-libs/gobject-introspection-1.41.4:=

	sys-libs/readline:0
	dev-lang/spidermonkey:38
	virtual/libffi
	cairo? ( x11-libs/cairo[X] )
	gtk? ( x11-libs/gtk+:3 )
"
DEPEND="${RDEPEND}
	gnome-base/gnome-common
	sys-devel/gettext
	virtual/pkgconfig
	test? ( sys-apps/dbus )
"

src_prepare() {
	eautoreconf
	gnome2_src_prepare
}

src_configure() {
	# FIXME: add systemtap/dtrace support, like in glib:2
	# FIXME: --enable-systemtap installs files in ${D}/${D} for some reason
	# XXX: Do NOT enable coverage, completely useless for portage installs
	gnome2_src_configure \
		--disable-systemtap \
		--disable-dtrace \
		--disable-coverage \
		$(use_with cairo cairo) \
		$(use_with gtk) \
		$(use_with test dbus-tests) \
		$(use_with test xvfb-tests)
}

src_test() {
	virtx emake check
}

src_install() {
	# installation sometimes fails in parallel, bug #???
	gnome2_src_install -j1

	if use examples; then
		insinto /usr/share/doc/"${PF}"/examples
		doins "${S}"/examples/*
	fi

	# Required for gjs-console to run correctly on PaX systems
	pax-mark mr "${ED}/usr/bin/gjs-console"
}
