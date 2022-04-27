#!/usr/bin/env bash

target_repo=""
# soft -> default (copy unless existing hook is found)
# force -> blind cp
# interactive -> prompt on duplicate
mode="soft"

Usage() {
    local exit_code
    exit_code="${1:-0}"
    cat <<-__EOF_
${0##*/} Quickly install the conventional hooks in a given repo
    -r         : Repo where these hooks should be installed
    -F         : Force-overwrite existing hooks (cannot be used with -i)
    -i         : Interactive, when setting up hooks, manually prompt to overwrite any existing hooks
    -h         : Display this help message

Example:

    Install all hooks in repo "foo", skip existing hooks
        ${0##*/} -r /home/me/repos/foo 

    Install all hooks in repo "foo", ask to overwrite/skip existing hooks
        ${0##*/} -r /home/me/repos/foo -i

    Install all hooks in repo "foo", ignoring any existing hooks
        ${0##*/} -r /home/me/repos/foo -F

__EOF_
    exit "${exit_code}"
}

copy_hook() {
    if [ "${mode}" = "force" ]; then
        cp "hooks/${2}" "${1}/${2}" && echo "Replaced hook ${2}" # copy to target
    elif [ "${mode}" = soft ]; then
        ## only copy if overwrite is needed
        [ -f "${1}/${2}" ] && echo "A ${2} hook was already found, skipping..." || cp "hooks/${2}" "${1}/${2}"
    else
        prompt_copy "${1}" "${2}"
    fi
    ## ensure hook is executable (if it exists)
    [ -f "${1}/${2}" ] && chmod +x "${1}/${2}" # make executable
}

prompt_copy() {
    local resp
    read -p "Target repo already contains a ${2} hook, overwrite? [y/N] " -r -n 2 resp
    resp="${resp:-N}"
    resp="${resp:0:1}"
    ## case insensitive match, overwrite in case the answer is yes
    [[ $resp =~ ^[yY]$ ]] && cp "hooks/${2}" "${1}/${2}" && echo "Hook replaced" || echo "Skipping hook ${2}"
}

while getopts :r:Fih: f; do
    case $f in
        r)
            target_repo="${OPTARG}"
            ;;
        F)
            mode="force"
            ;;
        i)
            mode="interactive"
            ;;
        h)
            Usage 0
            ;;
        *)
            echo "Unknown option ${OPTARG}"
            Usage 1
            ;;
    esac
done

hooks_path="${target_repo}/.git/hooks"

## Sanity-check input
[ -z "${target_repo}" ] && echo "No target repo given" && Usage 2
[ ! -d "${target_repo}" ] && echo "${target_repo} is not a directory" && Usage 2
[ ! -d "${hooks_path}" ] && echo "${target_repo} does not contain the expected .git/hooks subdirectories" && Usage 2

# copy hooks
for f in $(ls hooks/); do
    copy_hook "${hooks_path}" "${f}" "${mode}"
done

echo "DONE"
