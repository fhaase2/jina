#!/usr/bin/env bash

set -e

DOC_DIR=docs
HTML_DIR=${DOC_DIR}/_build/html



cd ${DOC_DIR} && rm -rf api && pip install -r requirements.txt && make clean && cd -

# require docker installed https://github.com/pseudomuto/protoc-gen-doc
docker run --rm \
  -v $(pwd)/docs/chapters/proto:/out \
  -v $(pwd)/jina/proto:/protos \
  pseudomuto/protoc-gen-doc --doc_opt=markdown,docs.md

cd ${DOC_DIR} && make html && cd -

if [[ $1 == "commit" ]]; then
  cp ${DOC_DIR}/README.md ${HTML_DIR}/
  cd ${HTML_DIR}
  git init
  git config --local user.email "dev-bot@jina.ai"
  git config --local user.name "Jina Dev Bot"
  git add .
  git commit -m "$2" -a
  git status
  cd -
elif [[ $1 == "release" ]]; then
  VER="$(sed '3q;d' ./jina/__init__.py | cut -d \' -f2)"
  cp ${DOC_DIR}/README.md ${HTML_DIR}/
  cd ${HTML_DIR}
  git init
  git config --local user.email "dev-bot@jina.ai"
  git config --local user.name "Jina Dev Bot"
  git add .
  git tag $(VER)
  git commit -m "$2" -a
  git status
  cd -
elif [[ $1 == "serve" ]]; then
    python -m http.server $2 -d ${HTML_DIR}
fi

