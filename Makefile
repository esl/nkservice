REPO ?= nkservice

.PHONY: deps release dev

all: deps compile

compile:
	./rebar compile

cnodeps:
	./rebar compile skip_deps=true

deps:
	./rebar get-deps

clean: 
	./rebar clean

distclean: clean
	./rebar delete-deps

tests: compile eunit

eunit:
	./rebar eunit skip_deps=true

shell:
	erl -config util/shell_app.config -args_file util/shell_vm.args -s nkservice_app -s nklib_reloader


docs:
	./rebar skip_deps=true doc



APPS = kernel stdlib sasl erts ssl tools os_mon runtime_tools crypto inets \
	xmerl webtool snmp public_key mnesia eunit syntax_tools compiler
COMBO_PLT = $(HOME)/.$(REPO)_combo_dialyzer_plt

check_plt: 
	dialyzer --check_plt --plt $(COMBO_PLT) --apps $(APPS) deps/*/ebin

build_plt: 
	dialyzer --build_plt --output_plt $(COMBO_PLT) --apps $(APPS) deps/*/ebin

dialyzer:
	dialyzer -Wno_return --plt $(COMBO_PLT) ebin/nkdist*.beam #| \
	    # fgrep -v -f ./dialyzer.ignore-warnings

cleanplt:
	@echo 
	@echo "Are you sure?  It takes about 1/2 hour to re-build."
	@echo Deleting $(COMBO_PLT) in 5 seconds.
	@echo 
	sleep 5
	rm $(COMBO_PLT)



	#export ERL_FLAGS="-config test/app.config -args_file test/vm.args"; \

build_tests:
	erlc -pa ebin -o ebin -I include -pa deps/nklib \
	+export_all +debug_info \
	test/*.erl


