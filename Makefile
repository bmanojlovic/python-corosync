all: clean
	#python setup.py build_ext --inplace
	make -C lib/corosync/
clean:
	make -C lib/corosync/ clean
	rm -rf dist build
	