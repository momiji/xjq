#!/bin/bash
set -Eeuo pipefail
cd "$(dirname "$0")"

declare -A filters
filters[xqml]="."
filters[gojq]="-x[0-9]*$"
filters[gojq.fork]="-r[0-9]*$"
filters[xjq]="."

CONTINUE=0

# functions
expand-q() {
    for i ; do
        if [[ "$i" =~ ^[-a-A0-9_.,:/*~^%+=¤]*$ ]] ; then
            echo -n "$i "
        else
            printf "%q " "$i"
            #echo -n "${i@Q} "
        fi
    done
}

error() {
    echo "$*"
    exit 1
}

run() {
    echo -e "\e[34;1m=> $(expand-q "$@")\e[m"
    YES=
    [ $CONTINUE = 0 ] && {
        read -n 1 -p "Run command [Yes/No/Continue]? " YES
        [ "${YES,}" = "c" ] && CONTINUE=1
        echo
    }
    [ $CONTINUE = 1 ] || [ "${YES,}" = "y" ] && "$@"
}

info() {
    echo
    echo -e "\e[33;1m$*\e[m"
}

head() {
    echo
    echo -e "\e[41;1m[$*]\e[K\e[m"
}

check() {
    prj=$1
    info "$prj: check commits"
    pushd "../$prj" >/dev/null
    git status -s --untracked-files=no --ignored=no | tail -1 | grep -q . && {
        error "Project $prj has pending changes, commit them"
    }
    popd >/dev/null
}

# update PATH FILTER
# create new tag if HEAD not the last tag
update() {
    prj=$1
    filter=${filters[$prj]}
    info "$prj: check if HEAD is a last tag"
    pushd "../$prj" >/dev/null
    run git pull
    run git push
    last=$( git tag | sort -V | sed -n "/$filter/p" | tail -1 )
    a=$( git rev-parse HEAD )
    b=$( git rev-parse "$last" )
    if [ "$a" = "$b" ]; then
        echo "Git HEAD is already $a"
    else
        #echo "HEAD is not latest tag $a"
        info "$prj: run tests"
        go mod tidy
        go mod verify
        go test ./...
        pre=${last%.*}
        len=${#pre}
        ver=${last:$((len+1))}
        new=$pre.$((ver+1))
        info "$prj: create new tag $new"
        run git tag "$new"
        run git push --tags
        #( mkdir t ; cd t ; go mod init x ; run go get "github.com/momiji/$prj@$new" ; cd .. ; rm t -rf )
    fi
    popd >/dev/null
}

# fix PATH URL PATH_TO_GET_TAG 
# update go.mod dependencies
fix() {
    prj=$1
    url=$2
    src=$3
    info "$prj: update dependency for $src"
    pushd "../$src" >/dev/null
    filter="${filters[$src]}"
    last=$( git tag | sort -V | sed -n "/$filter/p" | tail -1 )
    popd >/dev/null
    pushd "../$prj" >/dev/null
    sed -i "s,$url.*$,$url $last," go.mod
    ok=1
    git status -s --untracked-files=no --ignored=no | tail -1 | grep -q . && ok=0
    if [ $ok = 1 ]; then
        echo "Dependency $url is already $last"
    else
        #echo "Dependency $url is now $last"
        info "$prj: run tests"
        run go mod tidy
        run go mod verify
        run go test ./...
        info "$prj: commit dependency $url $last"
        run git commit -m "update $url version to $last" go.mod go.sum
    fi
    popd >/dev/null
}

# migrate PATH_SOURCE PATH_TO_MIGRATE
# migrate all url in all go files
migrate() {
    prj=$1
    mig=$2
    filter="${filters[$prj]}"
    pushd "../$prj" >/dev/null
    info "$mig: check if tag already exists"
    xtag=$( git tag | sort -V | sed -n "/$filter/p" | tail -1 )
    rtag=${xtag//-x/-r}
    run git pull
    git tag | sed -n "/${rtag//./\.}/p" | grep -q . && {
        echo "Git tag $rtag already exists"
        popd >/dev/null
        return 0
    }
    info "$mig: clone files from $prj"
    popd >/dev/null
    [ -d "../$mig" ] || cp -Rp "../$prj" "../$mig"
    pushd "../$mig" >/dev/null
    run git clean -f -x -d
    a=$( git branch --show-current )
    [ "$a" = "fork" ] || {
        run git checkout -b fork
        run git push --set-upstream origin fork
    }
    run git checkout fork
    run git pull
    run git reset --hard
    run git checkout "$xtag" .
    run git add --all
    run git commit -m "clone files from $xtag"
    old=$( cat go.mod | sed -n /^module/p | awk '{print $2}' )
    new=github.com/momiji/$prj
    info "$mig: rename module $old => $new"
    run sed -i "s,$old,$new,g" go.mod $( find . -name "*.go" )
    info "$mig: run tests"
    run go mod tidy
    run go mod verify
    run git add --all
    run git commit -m "rename module $old => $new"
    run git push
    info "$mig: create tag $rtag"
    run git tag "$rtag"
    run git push --tags
    popd >/dev/null
}

main() {
    head "$1"
    case "$1" in
    xqml)
        check xqml
        update xqml
        ;;
    gojq)
        check gojq
        fix gojq github.com/momiji/xqml xqml
        update gojq
        migrate gojq gojq.fork
        ;;
    xjq)
        check xjq
        fix xjq github.com/momiji/gojq gojq.fork
        make -B
        update xjq
        info "xjq: release new version"
        GITHUB_TOKEN=$(gh auth token) run goreleaser release --clean
        info "xjq: install new version"
        run sleep 1
        run go install "github.com/momiji/xjq@$(git tag | sort -V | tail -1)"
        ;;
    esac
}

if [ "${1:-}" = "" ]; then
    main xqml
    main gojq
    main xjq
else
    main "$1"
fi
