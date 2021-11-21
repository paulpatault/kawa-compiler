all:
	dune build src/

install:
	dune build src/kawac.exe
	mv ./_build/default/src/kawac.exe ./bin/kawac
	rm -rf _build

compile:
ifdef file
	@dune exec src/kawac.exe $(file)
else
	@echo 'Il faut appeler cette commande avec un argument: make compile file=<fichier>.kawa'
endif

run:
ifdef file
	java -jar ./bin/Mars4_5.jar $(file)
else
	@echo 'Il faut appeler cette commande avec un argument: make compile file=<fichier>.asm'
endif

clean:
	rm -rf ./bin/kawac
	dune clean

cleanall:
	make clean
	find -name '*.pimp' -type f -delete
	find -name '*.pmimp' -type f -delete
	find -name '*.vips' -type f -delete
	find -name '*.vipsopt' -type f -delete
	find -name '*.gips' -type f -delete
	find -name '*.asm' -type f -delete
