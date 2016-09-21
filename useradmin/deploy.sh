#!/bin/bash
set -ex

git checkout master
git pull -r
rspec spec/ || (echo 'Not deploying due to failed specs!'; exit 1)
rubocop || (echo 'Not deploying due to style violations!'; exit 1)
ansible-playbook ../servers/deploy.yml -i ../servers/inv/acceptance
