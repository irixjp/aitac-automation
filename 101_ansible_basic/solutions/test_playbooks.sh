#!/bin/bash

# step4
ansible-playbook first_playbook.yml

# step5
ansible-playbook vars_debug_playbook.yml
ansible-playbook vars_host_group_playbook.yml
ansible-playbook vars_play_playbook.yml
ansible-playbook vars_register_playbook.yml
ansible-playbook vars_task_playbook.yml

# step6
ansible-playbook loop_playbook.yml
ansible-playbook when_playbook.yml
ansible-playbook handler_playbook.yml

# step7
ansible-playbook block_playbook.yml
ansible-playbook rescue_playbook.yml

# step8
ansible-playbook ansible-playbook template_playbook.yml

#ansible-playbook collection_playbook.yml

#ansible-playbook galaxy_playbook.yml

#ansible-playbook lb_web.yml

#ansible-playbook reporting_playbook.yml

#ansible-playbook role_playbook.yml

#ansible-playbook testing_assert_playbook.yml
