#!/usr/bin/env bash

cd /tests || exit 1
poetry run behave --junit --junit-directory "$TEST_REPORT_ABSOLUTE_DIR"
