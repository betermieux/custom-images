#!/bin/bash -e
. /opt/bitnami/base/functions
. /opt/bitnami/base/helpers

info "Initializing DB..."

count=$(mysql -hredmine-mariadb -uroot -p$REDMINE_DB_PASSWORD -e "select count(*) from bitnami_redmine.settings;" | cut -d \t -f 3)
if [ $count == "1" ];
then
    echo Inserting Rows
    mysql -hredmine-mariadb -uroot -p$REDMINE_DB_PASSWORD <<'EOF'
    insert into bitnami_redmine.auth_sources
      (type, name, host, port, account, account_password, base_dn, attr_login, attr_firstname, attr_lastname, attr_mail, onthefly_register, tls, filter, timeout)
    values
      ('AuthSourceLdap', 'HFU LDAP', 'ldap.fu.hs-furtwangen.de', 636, 'uid=$login,ou=people,ou=IN,dc=hs-furtwangen,dc=de', '', 'dc=hs-furtwangen,dc=de', 'uid', 'givenName', 'sn', 'mail', 1, 1, '', NULL);

    insert into bitnami_redmine.settings
      (name, value, updated_on)
    values
      ('rest_api_enabled', 1, now()),
      ('protocol', 'https', now()),
      ('host_name', 'kube.informatik.hs-furtwangen.de/redmine', now()),
      ('default_language', 'de', now()),('app_title', 'Redmine on Kubernetes', now()),
      ('mail_from', 'redmine@kube.informatik.hs-furtwangen.de', now()),
      ('enabled_scm', '---\n- Git\n- Xitolite\n', now()),
      ('autologin', '365', now()),
      ('commit_ref_keywords', '*', now()),
      ('default_projects_tracker_ids', '---\n- \'1\'\n- \'2\'\n- \'3\'', now()),
      ('new_project_user_role_id', '3', now());

    update bitnami_redmine.settings
    set value="---
:gitolite_cache_max_time: '86400'
:gitolite_cache_max_size: '16'
:gitolite_cache_max_elements: '2000'
:gitolite_cache_adapter: database
:ssh_server_domain: localhost
:http_server_domain: kube.informatik.hs-furtwangen.de
:https_server_domain: kube.informatik.hs-furtwangen.de
:http_server_subdir: ''
:show_repositories_url: 'true'
:gitolite_daemon_by_default: 'false'
:gitolite_http_by_default: '1'
:gitolite_config_file: gitolite.conf
:gitolite_identifier_prefix: redmine_
:gitolite_identifier_strip_user_id: 'false'
:gitolite_temp_dir: '/tmp/redmine_git_hosting/'
:gitolite_recycle_bin_expiration_time: 24.0
:gitolite_log_level: info
:git_config_username: Redmine Git Hosting
:git_config_email: redmine@kube.informatik.hs-furtwangen.de
:gitolite_overwrite_existing_hooks: 'true'
:gitolite_hooks_are_asynchronous: 'true'
:gitolite_hooks_debug: 'false'
:gitolite_hooks_url: http://localhost:3000
:gitolite_notify_by_default: 'false'
:gitolite_notify_global_prefix: '[REDMINE]'
:gitolite_notify_global_sender_address: redmine@kube.informatik.hs-furtwangen.de
:gitolite_notify_global_include: []
:gitolite_notify_global_exclude: []
:redmine_has_rw_access_on_all_repos: 'true'
:all_projects_use_git: 'true'
:init_repositories_on_create: 'false'
:delete_git_repositories: 'true'
:download_revision_enabled: 'true'
:gitolite_use_sidekiq: 'false'
:hierarchical_organisation: 'false'
:unique_repo_identifier: 'true'
:gitolite_user: git
:gitolite_server_host: 127.0.0.1
:gitolite_server_port: '22'
:gitolite_ssh_private_key: '/opt/bitnami/redmine/ssh_keys/redmine_gitolite_admin_id_rsa'
:gitolite_ssh_public_key: '/opt/bitnami/redmine/ssh_keys/redmine_gitolite_admin_id_rsa.pub'
:gitolite_global_storage_dir: repositories/
:gitolite_redmine_storage_dir: ''
:gitolite_recycle_bin_dir: recycle_bin/"
    where name='plugin_redmine_git_hosting';

    update bitnami_redmine.users
    set language='de'
    where id=1;

    update bitnami_redmine.roles
    set permissions='---
- :add_project
- :add_messages
- :view_calendar
- :view_documents
- :view_files
- :view_gantt
- :view_issues
- :add_issues
- :add_issue_notes
- :save_queries
- :comment_news
- :browse_repository
- :view_changesets
- :view_time_entries
- :view_wiki_pages
- :view_wiki_edits
- :view_news
- :view_messages'
    where id=1;

EOF
else
    echo Database already initialized
fi
