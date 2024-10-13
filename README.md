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

### xqml

On xqml project, main branch:

- do any required modifications if any issue is found

To release a new version, use `./update.sh xqml` from xjq project (here).

### gojq

On gojq project, main branch:

- fetch all changes from upstream: `git fetch upstream`
- merge all changes from upstream: `git merge upstream/main`
- once merge is done, run tests: `go test ./...`
- review all changes by comparing with upstream: should show only html/xml changes
- finish merge by committing all changes
- use `make` to build
- perform any tests to check `./gojq` is working fine
- push changes once everything is good: `git push` and `git push --tags`

To release a new version, use `./update.sh gojq [NEW_TAG]` from xjq project (here):

- use NEW_TAG only when gojq version has changed
- example of NEW_TAG: `v0.12.16-x23`
- it allows to keep track of gojq version `v0.12.16` and my additions with `x23`

### xjq

On xjq project (here), main branch:

- update go.mod with new gojq version
- use `make` to build `./xjq`
- check version with `./xjq --version`
- perform any other tests

To release a new version, use `./update.sh xjq` from xjq project (here).
