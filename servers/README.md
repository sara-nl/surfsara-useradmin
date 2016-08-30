# Installation

```
brew install ansible
brew install vagrant
vagrant plugin install vagrant-vbguest
vagrant up useradmin
./ansible-dev useradmin
vagrant reload useradmin
vagrant ssh useradmin
```

And then:

```
sudo su - surfsara
gem install bundler
cd /var/www/useradmin/current
bundle install
```

To run Mujina (IDP):

```
sudo su - surfsara
cd mujina/mujina-idp
mvn jetty:run
```
