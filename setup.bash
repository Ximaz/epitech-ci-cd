#:/bin/bash -e

get_variable()
{
    local DEFAULT="${1}"
    local VARIABLE_NAME="${2}"

    [[ "${DEFAULT}" == "" ]] && read -p "Specify the ${VARIABLE_NAME}: " DEFAULT
    echo "${DEFAULT}"
}

main()
{
    local PROJECT_NAME=$(get_variable "${CICD_PROJECT_NAME}" "project's name")
    local REPOSITORY=$(get_variable "${CICD_REPOSITORY}" "repository's url")

    [[ "${PROJECT_NAME}" != "" && "${REPOSITORY}" != "" ]]              \
    && git clone "git@github.com:Ximaz/epitech-ci-cd" "${PROJECT_NAME}" \
    && cd "${PROJECT_NAME}"                                             \
    && rm -rf .git README.md setup.bash                                 \
    && git init .                                                       \
    && git branch -M main                                               \
    && git remote add origin "${REPOSITORY}"                            \
    && git add .github .gitignore
    unset -f get_variable
    unset -f main
}

main
