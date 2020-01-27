#!/bin/bash

cd ~

curl -o- -L https://yarnpkg.com/install.sh | bash

source ~/.zshrc

cd /Users/{{ work_user }}/{{ work_dir }}/{{ dashboard_dir }}

/Users/{{ work_user }}/.yarn/bin/yarn install --frozen-lockfile

/Users/{{ work_user }}/.yarn/bin/yarn release

cp tests/Protractor/protractorEnvironment.example.js tests/Protractor/protractorEnvironment.js
