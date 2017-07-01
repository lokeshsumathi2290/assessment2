#!/bin/bash

export GOROOT="/usr/local/go"
export GOPATH="/opt/gocode"
nohup /usr/local/go/bin/go run blueprint.go > nohup.out 2> Error.err < /dev/null &
