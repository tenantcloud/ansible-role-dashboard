
![Lint Ansible Roles](https://github.com/tenantcloud/ansible-role-dashboard/workflows/Lint%20Ansible%20Roles/badge.svg?branch-master)

tenantcloud.dashboard
=========

Ansible role for install dashboard project.

  - tenantcloud_dashboard

Requirements
------------

Install tenantcloud.software_common
Install tenantcloud.software_dev
pip3 install pexpect

Role Variables
--------------

ansible_user: "user" of os username
ansible_ssh_pass: "password" of os username
work_dir: "work"
work_domain:
dashboard_git:
dashboard_git_branch:
dashboard_dir:
bcl_url:
bcl_package_install:

Dependencies
------------

  - homebrew
  - python@3
  - ansible

Example Playbook
----------------

```yaml
    - hosts: localhost
      become: no
      vars:
        ansible_user: "user"
        ansible_ssh_pass: "password"
        work_dir: "work"
        work_domain:
        dashboard_git:
        dashboard_git_branch:
        bcl_url:
        bcl_package_install: true
      roles:
        - tenantcloud.dashboard
```

License
-------

BSD

Author Information
------------------

TenantCloud DevOps Team
