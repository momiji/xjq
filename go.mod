module momiji.com/xjq

go 1.20

replace (
	github.com/clbanning/mxj/v2 v2.5.7 => github.com/momiji/mxj/v2 v2.7.0-x1
	github.com/itchyny/gojq v0.12.13 => github.com/momiji/gojq v0.12.13-x2
//github.com/itchyny/gojq v0.12.13 => ../gojq
)

require github.com/itchyny/gojq v0.12.13

require (
	github.com/clbanning/mxj/v2 v2.5.7 // indirect
	github.com/itchyny/timefmt-go v0.1.5 // indirect
	github.com/mattn/go-isatty v0.0.19 // indirect
	github.com/mattn/go-runewidth v0.0.14 // indirect
	github.com/rivo/uniseg v0.4.4 // indirect
	golang.org/x/sys v0.8.0 // indirect
	gopkg.in/yaml.v3 v3.0.1 // indirect
)