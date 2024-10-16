SHELL=/bin/bash

checks: breakage language symlinks deps lint

breakage:
	swift package --disable-sandbox check-api-breakage

symlinks:
	swift package --disable-sandbox check-broken-symlinks

deps:
	swift package --disable-sandbox check-local-swift-dependencies

security:
	swift package --disable-sandbox check-openapi-security

validation:
	swift package --disable-sandbox check-openapi-validation

language:
	swift package --disable-sandbox check-unacceptable-language

contributors:
	swift package --disable-sandbox generate-contributors-list

install-format:
	swift package --disable-sandbox install-swift-format

run-clean:
	swift package --disable-sandbox run-clean
	
chmod:
	swift package --disable-sandbox run-chmod

lint:
	swift package --disable-sandbox run-swift-format

format:
	swift package --disable-sandbox run-swift-format --fix
