all:
	dune build src/

compile:
ifdef file
	@dune exec src/kawac.exe $(file)
else
	@echo 'Il faut appeler cette commande avec un argument: make compile file=<fichier>.kawa'
endif

run:
ifdef file
	java -jar Mars4_5.jar $(file)
else
	@echo 'Il faut appeler cette commande avec un argument: make compile file=<fichier>.asm'
endif

clean:
	dune clean

cleanall:
	make clean
	find tests/ -name '*.pimp' -type f -delete
	find tests/ -name '*.pmimp' -type f -delete
	find tests/ -name '*.vips' -type f -delete
	find tests/ -name '*.vipsopt' -type f -delete
	find tests/ -name '*.gips' -type f -delete
	find tests/ -name '*.asm' -type f -delete
