# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ECM_HANDBOOK="forceoptional"
ECM_TEST="optional"
KFMIN=5.106.0
QTMIN=5.15.9
inherit ecm gear.kde.org optfeature

DESCRIPTION="File archiver by KDE"
HOMEPAGE="https://apps.kde.org/ark/"

LICENSE="GPL-2" # TODO: CHECK
SLOT="5"
KEYWORDS="amd64 arm64 ~loong ~ppc64 ~riscv x86"
IUSE="zip"

RDEPEND="
	>=app-arch/libarchive-3.5.3:=[bzip2,lzma]
	>=dev-qt/qtdbus-${QTMIN}:5
	>=dev-qt/qtgui-${QTMIN}:5
	>=dev-qt/qtwidgets-${QTMIN}:5
	>=kde-frameworks/kcompletion-${KFMIN}:5
	>=kde-frameworks/kconfig-${KFMIN}:5
	>=kde-frameworks/kconfigwidgets-${KFMIN}:5
	>=kde-frameworks/kcoreaddons-${KFMIN}:5
	>=kde-frameworks/kcrash-${KFMIN}:5
	>=kde-frameworks/kdbusaddons-${KFMIN}:5
	>=kde-frameworks/ki18n-${KFMIN}:5
	>=kde-frameworks/kiconthemes-${KFMIN}:5
	>=kde-frameworks/kio-${KFMIN}:5
	>=kde-frameworks/kitemmodels-${KFMIN}:5
	>=kde-frameworks/kjobwidgets-${KFMIN}:5
	>=kde-frameworks/kparts-${KFMIN}:5
	>=kde-frameworks/kpty-${KFMIN}:5
	>=kde-frameworks/kservice-${KFMIN}:5
	>=kde-frameworks/kwidgetsaddons-${KFMIN}:5
	>=kde-frameworks/kxmlgui-${KFMIN}:5
	sys-libs/zlib
	zip? ( >=dev-libs/libzip-1.6.0:= )
"
DEPEND="${RDEPEND}
	>=dev-qt/qtconcurrent-${QTMIN}:5
	test? ( >=dev-libs/libzip-1.6.0:= )
"
# app-arch/rar is binary only
BDEPEND="
	sys-devel/gettext
	elibc_glibc? ( test? ( amd64? ( app-arch/rar ) x86? ( app-arch/rar ) ) )
"

src_configure() {
	local mycmakeargs=(
		$(cmake_use_find_package zip LibZip)
	)

	ecm_src_configure
}

src_test() {
	local myctestargs=(
		# bug 822177: kerfuffle-addtoarchivetest: may segfault or hang indefinitely
		# bug 827840: plugins-clirartest: continuously broken with translations installed
		-E "(kerfuffle-addtoarchivetest|plugins-clirartest)"
	)

	ecm_src_test
}

pkg_postinst() {
	if [[ -z "${REPLACING_VERSIONS}" ]]; then
		optfeature "rar archive creation/extraction" "app-arch/rar"
		optfeature "rar archive extraction only" "app-arch/unar" "app-arch/unrar"
		optfeature "7-Zip archive support" "app-arch/p7zip"
		optfeature "lrz archive support" "app-arch/lrzip"
		optfeature "Markdown support in text previews" "kde-misc/markdownpart:${SLOT}"
	fi
	ecm_pkg_postinst
}
