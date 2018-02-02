FROM bitnami/redmine:3.4.4-r0

COPY plugins/ /opt/bitnami/redmine/plugins/

RUN install_packages ruby-dev gcc libmysqlclient-dev libpq-dev libmagickwand-dev imagemagick make build-essential libssh2-1 libssh2-1-dev cmake libgpg-error-dev pkg-config openssh-client openssh-server jed && \
    # install redmine_git_hosting plugins
    cd /opt/bitnami/redmine/plugins && \
    /opt/bitnami/git/bin/git clone https://github.com/jbox-web/redmine_bootstrap_kit.git && \
    cd redmine_bootstrap_kit/ && \
    /opt/bitnami/git/bin/git checkout 0.2.5 && \
    cd ..  && \
    /opt/bitnami/git/bin/git clone https://github.com/jbox-web/redmine_git_hosting.git && \
    cd redmine_git_hosting/ && \
    /opt/bitnami/git/bin/git checkout 1.2.3 && \
    # git hosting plugins invokes git with non existing no-color param, remove it
    sed -i -e "s|sudo_git('--version', '--no-color')|sudo_git('--version')|g" /opt/bitnami/redmine/plugins/redmine_git_hosting/lib/redmine_git_hosting/commands/git.rb && \
    # redcarpet is defined twice with different versions, problems during bundle install, remove one
    sed -i -e "s|gem 'redcarpet'|# gem 'redcarpet'|g" /opt/bitnami/redmine/plugins/redmine_git_hosting/Gemfile && \
    cd /opt/bitnami/redmine && \
    bundle install --without development test --no-deployment && \
    # bitnami doesn't allow a customized base uri, hack it into the configuration
    sed -i -e 's|### END|passenger_base_uri "/redmine";\n        ### END|g' /opt/bitnami/redmine/vendor/bundle/ruby/2.3.0/gems/passenger-5.1.12/resources/templates/standalone/config.erb && \
    sed -i -e 's|### END|passenger_base_uri "/redmine";\n        ### END|g' /opt/bitnami/ruby/lib/ruby/gems/2.3.0/gems/passenger-5.1.12/resources/templates/standalone/config.erb

# install gitolite

RUN useradd -m -d /opt/bitnami/redmine/gitolite -s /bin/bash git && \
    # gitolite and git hosting plugin needs access to git and ruby, link them to /usr/bin
    ln -s /opt/bitnami/git/bin/git* /usr/bin/ && \
    ln -s /opt/bitnami/ruby/bin/* /usr/bin/ && \
    mkdir -p /var/run/sshd && \
    su - git -c 'mkdir /opt/bitnami/redmine/gitolite/bin' && \
    su - git -c 'git clone git://github.com/sitaramc/gitolite' && \
    su - git -c 'gitolite/install -to /opt/bitnami/redmine/gitolite/bin' && \
    echo "Defaults:redmine !requiretty" >> /etc/sudoers.d/redmine && \
    echo "redmine ALL=(git) NOPASSWD:ALL" >> /etc/sudoers.d/redmine && \
    chmod 440 /etc/sudoers.d/redmine && \
    # start ssh daemon when the container comes up
    sed -i -e 's|nami_initialize redmine|nami_initialize redmine\n  . /sshd.sh\n  . /database.sh\n  . /mailserver.sh|g' /app-entrypoint.sh && \
    # persist the ssh_keys directory
    sed -i -e 's|"public/plugin_assets",|"public/plugin_assets",\n                    "ssh_keys",\n                    "gitolite",|g' /root/.nami/registry.json && \
    # set the correct permissions on the ssh_keys and gitolity directory
    sed -i -e "s|componentFunctions.createExtraConfigurationFiles|componentFunctions.configurePermissions([{path: 'gitolite',user: 'git',group: 'git',}], {followInnerSymLinks: true});\n  componentFunctions.configurePermissions([{path: 'ssh_keys',user: \$app.redmineSystemUser,group: \$app.redmineSystemGroup,mod: {directory: '775', file: '600'},}], {followInnerSymLinks: true});\n  componentFunctions.createExtraConfigurationFiles|g" /root/.nami/components/com.bitnami.redmine/main.js  && \
    # change default language to german
    sed -i -e 's|"language": "en"|"language": "de"|g' /root/.nami/registry.json



COPY sshd.sh database.sh mailserver.sh notify-jenkins /
