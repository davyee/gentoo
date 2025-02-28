# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="Build automation tool that executes in containers"
HOMEPAGE="https://earthly.dev/
	https://github.com/earthly/earthly/"
SRC_URI="
	https://github.com/${PN}/${PN}/archive/v${PV}.tar.gz
		-> ${P}.tar.gz
	https://dev.gentoo.org/~xgqt/distfiles/deps/${P}-deps.tar.xz
"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	|| (
		app-containers/docker
		app-containers/podman
	)
"

DOCS=( CHANGELOG.md CONTRIBUTING.md README.md )

src_compile() {
	mkdir -p bin || die

	# Git SHA is needed at runtime by earthly to pull and bootstrap images.
	local git_sha
	if [[ ${PV} == 0.7.15 ]] ; then
		git_sha=ae8f65528ad37a278985de2e234deb42b91e308f
	else
		die 'Could not detect "git_sha", please update the ebuild.'
	fi

	local go_tags="dfrunmount,dfrunsecurity,dfsecrets,dfssh,dfrunnetwork,dfheredoc,forceposix"
	local go_ldflags="
		-X main.DefaultBuildkitdImage=docker.io/earthly/buildkitd:v${PV}
		-X main.GitSha=${git_sha}
		-X main.Version=v${PV}
	"
	local -a go_buildargs=(
		-tags "${go_tags}"
		-ldflags "${go_ldflags}"
		-o bin
	)
	ego build "${go_buildargs[@]}" ./cmd/...
}

src_install() {
	exeinto /usr/bin
	doexe bin/earthly
	newexe bin/debugger earthly-debugger

	einstalldocs
}

pkg_postinst() {
	if has_version "app-containers/podman" ; then
		ewarn "Podman is supported but not recommended."
		ewarn "If issues arise, then please try running earthly with docker."
	fi

	if has_version "app-containers/podman[rootless]" ; then
		ewarn "Running podman in rootless mode is not supported because"
		ewarn "earthly/dind and earthly/buildkit require privileged access."
		ewarn "For more info see: https://docs.earthly.dev/docs/guides/podman/"
	fi
}
