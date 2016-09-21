#!/bin/bash
set -ex

git checkout master
git pull -r
rspec spec/
rubocop
ansible-playbook ../servers/deploy.yml -i ../servers/inv/acceptance
