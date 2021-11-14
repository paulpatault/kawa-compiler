all:
	dune build src/

run:
ifdef file
	@dune exec src/kawac.exe $(file)
else
	@echo 'file is not defined'
endif

clean:
	dune clean

cleanall:
	make clean
	rm -f tests/*imp tests/*ips* tests/*.asm
	rm -f tests/must_work/*imp tests/must_work/*ips* tests/must_work/*.asm
	rm -f tests/errors/*imp tests/errors/*ips* tests/errors/*.asm
