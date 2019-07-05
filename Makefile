.PHONY: main

main: syntax_check

syntax_check:
	ansible-playbook -i test/hosts.ini setup.yml  --syntax-check