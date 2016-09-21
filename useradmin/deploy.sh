#!/bin/bash
set -ex

git pull -r
ansible-playbook ../servers/deploy.yml -i ../servers/inv/acceptance
