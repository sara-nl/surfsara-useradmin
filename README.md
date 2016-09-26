# SURFsara HPC Cloud Useradmin

## Local Development

### OSX - Prerequisites

#### Xcode:
```
    open macappstores://itunes.apple.com/us/app/xcode/id497799835
    xcode-select --install
```

#### Homebrew:
```
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

#### Rbenv:
```
brew install rbenv                      # Ruby Version Manager
brew install rbenv-communal-gems        # Prevent many gem installs
brew install ruby-build                 # for installing ruby versions
```

Follow `rbenv` post install messages.


#### Other:

```
brew install postgres
brew install qt5       # for capybara-webkit
```

Follow 'postgres' post install messages.

#### VirtualBox:

Download from `https://www.virtualbox.org/wiki/Downloads`

### Vagrant: 

```
brew install vagrant
vagrant plugin install vagrant-vbguest
```

### Ansible:

```
brew install ansible
ansible-galaxy install carlosbuenosvinos.ansistrano-deploy
```

## Initial setup

### Checkout repository

```
git clone git@github.com:zilverline/surfsara-useradmin.git
cd surfsara-useradmin
```

### OpenNebula VM

```
cd servers
vagrant up opennebula
./ansible-dev opennebula.yml
vagrant ssh opennebula
sudo su -
service opennebula start
```

Visit `http://192.178.111.170` to see opennebula running.

### Rails server

```
cd useradmin
rbenv install
bundle install
rbenv rehash
rails s
```

Visit `http://localhost:3000` to see useradmin running.

### Running specs

Use `rspec` to run all specs

## Rails app configuration

### Translations (I18n)

Manage translation strings in: `useradmin/config/locales/en.yml`. HTML can be used in translation keys ending with *_html. For example, the terms of service acceptance text can be translated with `en.invites.verify.accept_terms_of_service_html` where both the link and the text can be configured.

### Mail template

Mail content can be managed in the translations file under they key `en.invite_mailer.invitation.body`. Changes can be previewed locally at [http://localhost:3000/rails/mailers/invite_mailer/invitation](http://localhost:3000/rails/mailers/invite_mailer/invitation) when your rails server is running.

The following variables are available for use in the mail template:

- role: 'Group Admin' or 'Member'. The role the invitation is for
- group: The name of the group the user is being invited in.

## Deployment

Deployment is done with Ansible using the [Ansistrano](https://github.com/ansistrano/deploy) recipe. Use the following command `useradmin/deploy.sh` to:

- Pulls latest from git
- Runs specs using rspec
- Lints ruby files using rubocop
- Deploys useradmin app to acceptance

See `servers/group_vars/useradmin-acceptance` for `ansistrano_*` configurations.

## Server Provisioning

### Encrypted secrets

TODO

### Environment specific configurations

See `useradmin/config/environments/acceptance.rb` for environment specific configurations.

### Acceptance Environment

- See `servers/inv/acceptance` for targeted servers.
- See `servers/group_vars/` for relevent configurations in:
    - `opennebula.yml`
    - `opennebula-acceptance.yml`
    - `useradmin.yml`
    - `useradmin-acceptance.yml`

```
cd servers
ansible-playbook opennebula.yml -i inv/acceptance
ansible-playbook useradmin.yml -i inv/acceptance
```

- OpenNebula runs at https://_USERADMIN_HOSTNAME_/
- UserAdmin app runs at https://_USERADMIN_HOSTNAME_/useradmin
- Mails aren't actually sent but captured by mailcatcher which runs at https://_USERADMIN_HOSTNAME_:1080

## Database columns

The useradmin database contains a single table `invites` with the following fields:

```
invites.email       - string   - The email the invite has been sent to
invites.token       - string   - A random token (SecureRandom.hex) that is emailed and then stored hashed with SHA-256
invites.group_id    - integer  - Identifier of the group as it is known in OpenNebula
invites.group_name  - string   - Name of the group as it is known in OpenNebula
invites.role        - string   - Role within the group the invite is for [Group Admin/Member]
invites.created_at  - datetime - Timestamp when the invite was sent
invites.created_by  - string   - OpenNebula username of the invite creator
invites.accepted_at - datetime - Timestamp when the invite was accepted
invites.accepted_by - string   - OpenNebula username of the invite acceptor
invites.revoked_at  - datetime - Timestamp when the invite was revoked
invites.revoked_by  - string   - OpenNebula username of the invite revoker
invites.updated_at  - datetime - Timestamp of the last time the invite was updated
```

## OpenNebula Logs

In addition to the detailed information UserAdmin provides on the Invite resource all API, CLI and Sunstone actions are logged in `/var/log/one/oned.log`. 

Migrating a user to a SURFconext account looks like:

```
Thu Sep 22 08:21:26 2016 [Z0][ReM][D]: Req:4704 UID:0 UserChangeAuth invoked , 19, "public", ****
Thu Sep 22 08:21:26 2016 [Z0][ReM][D]: Req:4704 UID:0 UserChangeAuth result SUCCESS, 19
```

Adding an existing user to a group and granting group admin permissions looks like:

```
Thu Sep 22 08:07:10 2016 [Z0][ReM][D]: Req:6624 UID:4 UserPoolInfo invoked
Thu Sep 22 08:07:10 2016 [Z0][ReM][D]: Req:6624 UID:4 UserPoolInfo result SUCCESS, "<USER_POOL><USER><ID..."
Thu Sep 22 08:07:10 2016 [Z0][ReM][D]: Req:0 UID:4 UserAddGroup invoked , 18, 103
Thu Sep 22 08:07:10 2016 [Z0][ReM][D]: Req:0 UID:4 UserAddGroup result SUCCESS, 18
Thu Sep 22 08:07:10 2016 [Z0][ReM][D]: Req:160 UID:4 GroupInfo invoked , 103
Thu Sep 22 08:07:10 2016 [Z0][ReM][D]: Req:160 UID:4 GroupInfo result SUCCESS, "<GROUP><ID>103</ID><..."
Thu Sep 22 08:07:10 2016 [Z0][ReM][D]: Req:8672 UID:4 GroupAddAdmin invoked , 103, 18
Thu Sep 22 08:07:10 2016 [Z0][ReM][D]: Req:8672 UID:4 GroupAddAdmin result SUCCESS, 103
```
