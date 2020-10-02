
<br><img src="https://github.com/tenantcloud/ansible-role-dashboard/workflows/Ansible Lint/badge.svg?branch-master"><br>
<br><img src="https://github.com/tenantcloud/ansible-role-dashboard/workflows/Yaml Lint/badge.svg?branch-master"><br>

tenantcloud.dashboard
=========

Ansible role for install dashboard project.

  - tenantcloud_dashboard
  - keller_dashboard

Requirements
------------

Install tenantcloud.software_common
Install tenantcloud.software_dev

Role Variables
--------------

ansible_user: "user" os username 
work_dir: "work"
dashboard_git:
dashboard_git_branch:
dashboard_dir:
docker_dir:
docker_git:
bcl_url:
bcl_package_install:
work_domain:
mysql_host:
mysql_admin_user:
mysql_admin_password:
mysql_database:
mysql_db_user:
mysql_db_user_pass:
pusher_app_id:
pusher_app_key:
pusher_app_secret:
app_key:
mysql_user:
minio_key:
minio_secret:
zencoder_key:
webhook_token:
rentrange_key:
aws_lambda_key:
aws_lambda_secret:
aws_lambda_region:
aws_lambda_s3:
aws_default_region:
php_api_version:
php_version:
php_release:
composer_url:
add_trusted_cert_command:
app_env:

Dependencies
------------

  - homebrew
  - python@3
  - ansible

Example Playbook
----------------

    - hosts: localhost
      become: no
      vars:
        ansible_user: "user"
        work_dir: "work"
        dashboard_git:
        dashboard_git_branch:
        dashboard_dir:
        docker_dir:
        docker_git:
        bcl_url:
        bcl_package_install: 'false'
        work_domain:
        mysql_host:
        mysql_admin_user:
        mysql_admin_password:
        mysql_database:
        mysql_db_user:
        mysql_db_user_pass:
        pusher_app_id:
        pusher_app_key:
        pusher_app_secret:
        app_key:
        mysql_user:
        minio_key:
        minio_secret:
        zencoder_key:
        webhook_token:
        rentrange_key:
        aws_lambda_key:
        aws_lambda_secret:
        aws_lambda_region:
        aws_lambda_s3:
        aws_default_region:
        app_env: "local"
      roles:
        - tenantcloud.dashboard

License
-------

BSD

Author Information
------------------

TenantCloud DevOps Team
