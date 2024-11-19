patch_bump:
	dart run bin/version_assist.dart bump --patch
	flutter packages pub run build_runner build
	dart run bin/version_assist.dart badge
	git add README.md
	git add version.dart
	dart run bin/version_assist.dart commit