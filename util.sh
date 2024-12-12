---
- name: Check and remediate CPU/Memory utilization
  hosts: localhost
  become: yes
  tasks:

  - name: Check CPU utilization
    shell: "top -bn1 | grep 'Cpu(s)' | awk '{print $2 + $4}'"
    register: cpu_utilization_output

  - name: Extract CPU utilization percentage
    set_fact:
      cpu_utilization: "{{ cpu_utilization_output.stdout.strip() | float }}"

  - name: Check Memory utilization
    shell: "free -m | awk '/Mem:/ {printf(\"%.2f\", $3/$2 * 100)}'"
    register: memory_utilization_output

  - name: Extract Memory utilization percentage
    set_fact:
      memory_utilization: "{{ memory_utilization_output.stdout.strip() | float }}"

  - name: Log CPU and Memory Utilization
    debug:
      msg:
        - "CPU Utilization: {{ cpu_utilization }}%"
        - "Memory Utilization: {{ memory_utilization }}%"

  - name: Remediate if CPU/Memory utilization is above threshold
    block:
      - name: Cleanup temp folder
        file:
          path: /tmp
          state: absent
      - name: Recreate temp folder
        file:
          path: /tmp
          state: directory
    when: (cpu_utilization | float) > 80 or (memory_utilization | float) > 80

  - name: Post-check Memory utilization
    shell: "free -m | awk '/Mem:/ {printf(\"%.2f\", $3/$2 * 100)}'"
    register: post_memory_utilization_output

  - name: Extract Post-check Memory utilization percentage
    set_fact:
      post_memory_utilization: "{{ post_memory_utilization_output.stdout.strip() | float }}"

  - name: Log Post-check Memory Utilization
    debug:
      msg: "Post Memory Utilization: {{ post_memory_utilization }}%"
