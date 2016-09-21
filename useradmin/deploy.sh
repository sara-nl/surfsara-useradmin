#!/bin/bash
set -ex

git checkout master
git pull -r
ansible-playbook ../servers/deploy.yml -i ../servers/inv/acceptance
