bump:
	version_assist bump --patch
	flutter packages pub run build_runner build
	version_assist badge