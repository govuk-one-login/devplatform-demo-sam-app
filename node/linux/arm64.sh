#!/usr/bin/env sh

npm config rm proxy
npm config rm https-proxy
npm config set registry http://registry.npmjs.org/
