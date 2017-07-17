# SURFsara HPC Cloud Useradmin

[![Build Status](https://travis-ci.org/sara-nl/surfsara-useradmin.svg?branch=master)](https://travis-ci.org/sara-nl/surfsara-useradmin)
[![Code Coverage](http://codecov.io/github/sara-nl/surfsara-useradmin/coverage.svg?branch=master)](http://codecov.io/github/sara-nl/surfsara-useradmin/coverage.svg?branch=master)
[![Code Climate](https://codeclimate.com/github/sara-nl/surfsara-useradmin/badges/gpa.svg)](https://codeclimate.com/github/sara-nl/surfsara-useradmin)

## Local Development

### OSX - Prerequisites

#### Xcode:
```sh
open macappstores://itunes.apple.com/us/app/xcode/id497799835
xcode-select --install
```

#### Homebrew:
```sh
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

#### Rbenv:
```sh
brew install rbenv                      # Ruby Version Manager
brew install rbenv-communal-gems        # Prevent many gem installs
brew install ruby-build                 # for installing ruby versions
```

Follow `rbenv` post install messages.


#### Other:

```sh
brew install postgres
brew install qt5       # for capybara-webkit
```

Follow 'postgres' post install messages.

#### VirtualBox:

Download from `https://www.virtualbox.org/wiki/Downloads`

### Vagrant:

```sh
brew install vagrant
vagrant plugin install vagrant-vbguest
```

### Ansible:

```sh
brew install ansible
ansible-galaxy install carlosbuenosvinos.ansistrano-deploy
```

## Initial setup

### Checkout repository

```sh
git clone git@github.com:zilverline/surfsara-useradmin.git
cd surfsara-useradmin
```

### OpenNebula VM

```sh
cd servers
vagrant up opennebula
./ansible-dev opennebula.yml
vagrant ssh opennebula
sudo su -
service opennebula start
```

Visit `http://192.168.111.170` to see opennebula running.

### Rails server

```sh
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

Accept environment is used as a fully working reference environment. Replace `acceptance` with `production` to provision the production environment.

### Users

Users will be created in the provisioning process.

- `surfsara` is responsible for running the application server.
- `postgres` is responsible for running the database server.


### Configuration with ansible

- See `servers/inv/acceptance` for targeted servers.
- See `servers/group_vars/` for relevent configurations in:
    - `opennebula.yml`
    - `opennebula-acceptance.yml`
    - `useradmin.yml`
    - `useradmin-acceptance.yml`

```sh
cd servers
ansible-playbook opennebula.yml -i inv/acceptance
ansible-playbook useradmin.yml -i inv/acceptance
```

- OpenNebula runs at https://_USERADMIN_HOSTNAME_/
- UserAdmin app runs at https://_USERADMIN_HOSTNAME_/useradmin
- Mails aren't actually sent but captured by mailcatcher which runs at https://_USERADMIN_HOSTNAME_:1080

### Secrets

Secrets are read from files on the server.

- `/etc/useradmin/db_password`
    - should contain the database password
    - should only be readable by the `postgres` and `surfsara` users.

- `/etc/useradmin/one_credentials`
    - contains the OpenNebula API user credentials in `username:api_token` format. i.e. `useradmin:hl234jklhvksdr3`
    - should only be readable by the `surfsara` user.

### Rails application environment configurations

See `useradmin/config/environments/acceptance.rb` as a reference of environment configurations.Relevant configurations to change are:

- Mailer host for linking in emails:
```rb
  config.action_mailer.default_url_options = {
    host: 'https://useradmin.cloudconext-sara.surf-hosted.nl'
  }
```

- Mailer host for images in emails:
```rb
  config.action_mailer.asset_host = 'https://useradmin.cloudconext-sara.surf-hosted.nl'
```

- SMTP server settings:
```rb
  config.action_mailer.smtp_settings = {
    address:              'smtp.gmail.com',
    port:                 587,
    domain:               'example.com',
    user_name:            '<username>',
    password:             '<password>',
    authentication:       'plain',
    enable_starttls_auto: true
  }
```

- OpenNebula API endpoint:
```rb
  config.one_client.endpoint = "http://10.100.155.4:2633/RPC2"
```

- Invite expiration time:
```rb
  config.invites.expire_after = 5.minutes
```

- SURFsara admin entitlement flag received from SURFconext:
```rb
  config.surfsara_admin_entitlement = "urn:mace:dir:entitlement:common-lib-terms-example"
```

## Database columns

### Invites: Every invite has one record in this column

```
invites.email       - string   - The email the invite has been sent to
invites.token       - string   - A random token (SecureRandom.hex) that is emailed and then stored hashed with SHA-256
invites.group_id    - integer  - Identifier of the group as it is known in OpenNebula
invites.group_name  - string   - Name of the group as it is known in OpenNebula
invites.role        - string   - Role within the group the invite is for [Group Admin/Member]
invites.created_at  - datetime - Timestamp when the invite was sent
invites.created_by  - string   - SURFconext REMOTE_USER of the invite creator
invites.accepted_at - datetime - Timestamp when the invite was accepted
invites.accepted_by - string   - SURFconext REMOTE_USER of the invite acceptor
invites.revoked_at  - datetime - Timestamp when the invite was revoked
invites.revoked_by  - string   - SURFconext REMOTE_USER of the invite revoker
invites.updated_at  - datetime - Timestamp of the last time the record was updated
```

### Migrations: Logs migrations as they happen.

```
migrations.one_username - string   - The username of the OpenNebula account being migrated
migrations.accepted_by  - string   - SURFconext REMOTE_USER that accepted the terms of service
migrations.accepted_at  - datetime - Timestamp when the terms of service were accepted
migrations.created_at   - datetime - Timestamp when the migration was completed
migrations.updated_at   - datetime - Timestamp of the last time the record was updated
```

## OpenNebula

### API user

The useradmin app requires an account in OpenNebula to make XML-RPC API calls. In order to execute the necessary commands, the follow ACL permissions are required:
- *Applies to:* User useradmin (Or whatever the useradmin's username is)
- *Affected resources:* Users, Groups, Security Groups
- *Resource ID / Owned by:* All
- *Allowed operations*: use, manage, admin, create
- *Zone:* All

### Configuration

Some configuration is required for remote authentication to function correctly:

- Enable remote authentication: In `/etc/one/sunstone-server.conf` configure `:auth: remote`
- Show password column in admin view: In `/etc/one/sunstone-views/admin.yaml` under `tabs.users_tab.table_columns` enable column 5 (Password)
- Disable password management: For all files in `/etc/one/sunstone-views/` make sure `User.update_password` and `Settings.change_password` are set to false

### Core Changes

Two small patches need to be done in OpenNebula Sunstone. In non-production environments these are provisioned with ansible. See: `servers/roles/opennebula/tasks/one_patches.yml`. Production requires these same modifications in:

- `/usr/lib/one/ruby/cloud/CloudAuth/RemoteCloudAuth.rb`
  - Replace `env['REMOTE_USER']` with `env['HTTP_REMOTE_USER']`. Required due to apache adding `HTTP_` to headers.

- `/usr/lib/one/sunstone/views/_login_x509.erb`
  - Change the `<span id="auth_error">` line to include a notice for migrating users. See `one_patches.yml:14` for the most recent version of this code.

### Firewall

All traffic to OpenNebula should go through the useradmin proxy (Shibboleth).
OpenNebula should not be directly exposed to the internet and only available for the IP address of the useradmin server.
Preferably through a private LAN connection and over SSL.

### Logs

In addition to the detailed information UserAdmin provides on the Invite and Migration resources all API, CLI and Sunstone actions are logged in `/var/log/one/oned.log` on the OpenNebula server.

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

## Backup data and logs

The following data should be backed up:

- The postgres database containing the application data (invites and migrations)
- `/var/www/useradmin/shared/log/*` contains the rails logs
- `/var/log/apache2/*` contains the apache and passenger logs
- `/var/log/shibboleth/*` contains the shibboleth logs
- `/var/log/postgresql/*` contains the database logs
- `/etc/useradmin/*` contains secrets

## Restoring the Backup

- Provision a new server following the steps mentioned in 'Server Provisioning'
- Restore secrets to `/etc/useradmin/*`
- Restore the postgres database
- Deploy the application following the steps mentioned in 'Deployment'
