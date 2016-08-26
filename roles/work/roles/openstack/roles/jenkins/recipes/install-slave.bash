#!/bin/bash -e

function main()
{
    # Load Libraries

    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../../../../../cookbooks/jenkins/attributes/slave.bash"
    source "${appFolderPath}/../../../../../../../libraries/util.bash"
    source "${appFolderPath}/../../../../../libraries/util.bash"
    source "${appFolderPath}/../attributes/slave.bash"

    # Clean Up

    resetLogs

    # Install Apps

    local -r hostName='jenkins-slave'

    apt-get update -m

    "${appFolderPath}/../../../../../../essential.bash" "${hostName}" 'centos,root,ubuntu'
    "${appFolderPath}/../../../../../../../cookbooks/ant/recipes/install.bash"
    "${appFolderPath}/../../../../../../../cookbooks/aws-cli/recipes/install.bash"
    "${appFolderPath}/../../../../../../../cookbooks/maven/recipes/install.bash"
    "${appFolderPath}/../../../../../../../cookbooks/node-js/recipes/install.bash" "${OPENSTACK_JENKINS_NODE_JS_VERSION}" "${OPENSTACK_JENKINS_NODE_JS_INSTALL_FOLDER}"
    "${appFolderPath}/../../../../../../../cookbooks/jenkins/recipes/install-slave.bash"
    "${appFolderPath}/../../../../../../../cookbooks/packer/recipes/install.bash"
    "${appFolderPath}/../../../../../../../cookbooks/ps1/recipes/install.bash" --host-name "${hostName}" --users "${JENKINS_USER_NAME}, $(whoami)"
    "${appFolderPath}/../../../../../../../cookbooks/secret-server-console/recipes/install.bash"

    # Config SSH and GIT

    addUserSSHKnownHost "${JENKINS_USER_NAME}" "${JENKINS_GROUP_NAME}" "$(cat "${appFolderPath}/../files/known_hosts")"

    configUserGIT "${JENKINS_USER_NAME}" "${OPENSTACK_JENKINS_GIT_USER_NAME}" "${OPENSTACK_JENKINS_GIT_USER_EMAIL}"
    generateUserSSHKey "${JENKINS_USER_NAME}"

    # Clean Up

    cleanUpSystemFolders
    cleanUpMess

    # Display Notice

    displayNotice "${JENKINS_USER_NAME}"
}

main "${@}"