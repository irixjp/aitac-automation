#!/bin/bash

# step4
ansible-playbook -i first_playbook.yml

# step5
ansible-playbook -i vars_debug_playbook.yml
ansible-playbook -i vars_host_group_playbook.yml
ansible-playbook -i vars_play_playbook.yml
ansible-playbook -i vars_register_playbook.yml
ansible-playbook -i vars_task_playbook.yml

# step6
ansible-playbook -i loop_playbook.yml
ansible-playbook -i when_playbook.yml
ansible-playbook -i handler_playbook.yml

# step7
ansible-playbook -i block_playbook.yml
ansible-playbook -i rescue_playbook.yml

#ansible-playbook -i collection_playbook.yml

#ansible-playbook -i galaxy_playbook.yml

#ansible-playbook -i lb_web.yml

#ansible-playbook -i reporting_playbook.yml

#ansible-playbook -i role_playbook.yml
#ansible-playbook -i template_playbook.yml
#ansible-playbook -i testing_assert_playbook.yml
