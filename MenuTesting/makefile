all: THOR

run: 
	sh run.sh

THOR: THOR.cu
	sh buildTHOR.sh

rm_output:
	rm -rf ./output-files/*

clean:
	-rm build-out