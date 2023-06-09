package main

import (
	"os"
	"runtime/debug"
	_ "unsafe"

	"github.com/momiji/gojq/cli"
)

//go:linkname cliRevision github.com/momiji/gojq/cli.revision
var cliRevision string

func main() {
	if bi, ok := debug.ReadBuildInfo(); ok {
		for _, dep := range bi.Deps {
			if dep.Path == "github.com/momiji/gojq" {
				cliRevision = "github.com/momiji/xjq@" + dep.Version
			}
		}
	}
	os.Exit(cli.Run())
}
