#!/usr/bin/env bash

set -euo pipefail

CORE_NAME="Archie"
MAIN_BRANCH="master"

if [[ "$(git log -n 1 --pretty=format:%an)" == "The CI/CD Bot" ]] ; then
    echo "The CI/CD Bot doesn't deliver a new release."
    exit 0
fi

RELEASE_FILE="${CORE_NAME}_$(date +%Y%m%d).rbf"
echo "Creating release ${RELEASE_FILE}."

export GIT_MERGE_AUTOEDIT=no
git config --global user.email "theypsilon@gmail.com"
git config --global user.name "The CI/CD Bot"
git fetch origin --unshallow 2> /dev/null || true
git checkout -qf ${MAIN_BRANCH}

echo
echo "Build start:"
docker build -t artifact . || ./.github/notify_error.sh "COMPILATION ERROR" $@
docker run --rm artifact > releases/${RELEASE_FILE}
echo
echo "Pushing release:"
git add releases
git commit -m "BOT: Releasing ${RELEASE_FILE}" -m "After pushed https://github.com/${GITHUB_REPOSITORY}/commit/${GITHUB_SHA}"
git push origin ${MAIN_BRANCH}