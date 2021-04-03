all:
	make -C pkr
	make -C tf

print-% : ; $(info $* is a $(flavor $*) variable set to [$($*)] that came from $(origin $*)) @true

