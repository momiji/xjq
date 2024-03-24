# xjq

This is a `gojq` replacement, adding yaml and xml support.

Related projects:

- [gojq](https://github.com/momiji/gojq) - gojq fork with xml/html support
- [xqml](https://github.com/momiji/xqml) - xml library with xq ideas (from pip install yq): KeepNamespace, ForceList, FixRoot 

## Additions

New additions to original `gojq` are:

- automatic input format detection using [xqml](https://github.com/momiji/xml) library
- additional options for xml, yaml and html input/output

```
  -y, --yaml-output         output in YAML format
  -x, --xml-output          output in XML format
  -J, --json-input          read input as JSON format
  -X, --xml-input           read input as XML format
      --xml-no-attributes   remove attributes from XML elements
      --xml-no-namespaces   remove namespace from XML elements and attributes
      --xml-force-list=     force XML elements as array
      --xml-root=           root XML element name
      --xml-element=        element XML element name
  -H, --xml-html            HTML compatibility mode
  -Y, --yaml-input          read input as YAML format
```

## Build a new release

On xqml project, main branch:

- do any required modifications if any issue is found

On gojq project, main branch:

- fetch all changes from upstream: `git fetch upstream`
- merge all changes from upstream: `git merge upstream/main`
- once merge is done, run tests: `go test ./...`
- review all changes by comparing with upstream: should show only html/xml changes
- finish merge by committing all changes
- use `make` to build 
- perform any tests to check `./gojq` is working fine
- push changes once everything is good

On xjq project (here):

To test changes, update go.mod with new gojq version
- use `make` to build `./xjq`
- check version with `./xjq --version`
- perform any other tests

To release
- `./update.sh xqml`
- `./update.sh gojq [NEW_TAG]` - use NEW_TAG only when gojq version has changed
- `./update.sg xjq`
