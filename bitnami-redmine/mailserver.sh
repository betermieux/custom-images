#!/bin/bash -e
. /opt/bitnami/base/functions
. /opt/bitnami/base/helpers

info "configuring mailserver"

if grep --quiet "hs-furtwangen" /opt/bitnami/redmine/conf/configuration.yml;
then
    echo "mailserver already configured"
else
    echo "inserting mail config"
    sed -i -e 's|^  email_delivery:|  email_delivery:\n    delivery_method: :smtp\n    smtp_settings:\n      address: "mail1.informatik.hs-furtwangen.de"\n      port: 25|g' /opt/bitnami/redmine/conf/configuration.yml
fi
