#!/usr/bin/env bats

# Copyright 2021 Jack Viers

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

load "${BATS_LIBS_INSTALL_LOCATION}/bats-support/load.bash"
load "${BATS_LIBS_INSTALL_LOCATION}/bats-assert/load.bash"

setup_file(){
     echo "BATS_BUILD_TOOL: $BATS_BUILD_TOOL"
     $BATS_BUILD_TOOL run -d -t --arch=$ARCH --name cp-base-test-${ARCH} ${BATS_IMAGE} tail -f /dev/null
}

teardown_file(){
    container=cp-base-test-${ARCH}
    sleep 1
    $BATS_BUILD_TOOL stop ${container}
    $BATS_BUILD_TOOL container rm ${container}
}

@test "openssl should be installed" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} openssl version
    assert_output --partial "OpenSSL 1.1.1k  25 Mar 2021"
}

@test "wget should be installed" {
      run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} wget -V
      assert_output --partial "GNU Wget 1.21"
}

@test "nmap should be installed" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} which nmap
    assert_output --partial "/usr/bin/nmap"
}

@test "ncat should be installed" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} which ncat
    assert_output --partial "/usr/bin/ncat"
}

@test "python3 should be installed" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} python3 --version
    assert_output --partial "3.9.2"
}

@test "tar should be installed" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} which tar
    assert_output --partial "/bin/tar"
}

@test "propcs should be installed" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} dpkg -l procps
    assert_output --partial "ii  procps"
}

@test "kerberos should be installed" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} dpkg -l krb5-user
    assert_output --partial "ii  krb5-user"
}

@test "iputils should be installed" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} dpkg -l iputils-arping
    assert_output --partial "ii  iputils-arping"
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} dpkg -l iputils-clockdiff
    assert_output --partial "ii  iputils-clockdiff"
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} dpkg -l iputils-ping
    assert_output --partial "ii  iputils-ping"
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} dpkg -l iputils-tracepath
    assert_output --partial "ii  iputils-tracepath"
}

@test "hostname should be installed" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} dpkg -l hostname
    assert_output --partial "ii  hostname"
}

@test "java should be java 11" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} java -version
    assert_output --partial "openjdk version \"11."
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} javac -version
    assert_output --partial "javac 11."
}

@test "pip3 should be installed" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} dpkg -l python3-pip
    assert_output --partial "ii  python3-pip"
}

@test "python command should be python3" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} python --version
    assert_output --partial "Python 3."
}

@test "pip version should be 21.*" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} pip -V
    assert_output --partial "21."
}

@test "confluent-docker-utils should be installed" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} pip show confluent-docker-utils
    assert_output --partial "Version: 0.0.49"
}

@test "git should not be installed after installing confluent-docker-utils" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} dpkg -l git
    refute_output --partial "ii  git"
}

@test "tzdata should be installed" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} dpkg -l tzdata
    assert_output --partial "ii  tzdata"
}

@test "libgcc-s1 should be installed" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} dpkg -l libgcc-s1
    assert_output --partial "ii  libgcc-s1"
}

@test "gcc-10-base should be installed" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} dpkg -l gcc-10-base
    assert_output --partial "ii  gcc-10-base"
}

@test "libstdc++6 should be installed" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} dpkg -l libstdc++6
    assert_output --partial "ii  libstdc++6"
}

@test "/etc/confluent/docker should be a directory" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -d /etc/confluent/docker
    assert_success 
}

@test "/usr/logs should be a directory" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -d /usr/logs
    assert_success 
}

@test "the user: appuser should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} id "appuser"
    assert_success
}

@test "the /etc/confluent/docker directory should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /etc/confluent/docker
    assert_output --partial "appuser"
}

@test "/usr/share/java/cp-base-new/argparse4j-0.7.0.jar should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/share/java/cp-base-new/argparse4j-0.7.0.jar
    assert_success
}

@test "/usr/share/java/cp-base-new/argparse4j-0.7.0.jar should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /usr/share/java/cp-base-new/argparse4j-0.7.0.jar
    assert_output --partial "appuser"
}

@test "/usr/share/java/cp-base-new/audience-annotations-0.5.0.jar should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/share/java/cp-base-new/audience-annotations-0.5.0.jar
    assert_success
}

@test "/usr/share/java/cp-base-new/audience-annotations-0.5.0.jar should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /usr/share/java/cp-base-new/audience-annotations-0.5.0.jar
    assert_output --partial "appuser"
}

@test "/usr/share/java/cp-base-new/common-utils-7.0.0.jar should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/share/java/cp-base-new/common-utils-7.0.0.jar
    assert_success
}

@test "/usr/share/java/cp-base-new/common-utils-7.0.0.jar should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /usr/share/java/cp-base-new/common-utils-7.0.0.jar
    assert_output --partial "appuser"
}

@test "/usr/share/java/cp-base-new/commons-cli-1.4.jar should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/share/java/cp-base-new/commons-cli-1.4.jar
    assert_success
}

@test "/usr/share/java/cp-base-new/commons-cli-1.4.jar should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /usr/share/java/cp-base-new/commons-cli-1.4.jar
    assert_output --partial "appuser"
}

@test "/usr/share/java/cp-base-new/confluent-log4j-1.2.17-cp2.jar should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/share/java/cp-base-new/confluent-log4j-1.2.17-cp2.jar
    assert_success
}

@test "/usr/share/java/cp-base-new/confluent-log4j-1.2.17-cp2.jar should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /usr/share/java/cp-base-new/confluent-log4j-1.2.17-cp2.jar
    assert_output --partial "appuser"
}

@test "/usr/share/java/cp-base-new/disk-usage-agent-7.0.0.jar should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/share/java/cp-base-new/disk-usage-agent-7.0.0.jar
    assert_success
}

@test "/usr/share/java/cp-base-new/disk-usage-agent-7.0.0.jar should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /usr/share/java/cp-base-new/disk-usage-agent-7.0.0.jar
    assert_output --partial "appuser"
}

@test "/usr/share/java/cp-base-new/gson-2.8.6.jar should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/share/java/cp-base-new/gson-2.8.6.jar
    assert_success
}

@test "/usr/share/java/cp-base-new/gson-2.8.6.jar should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /usr/share/java/cp-base-new/gson-2.8.6.jar
    assert_output --partial "appuser"
}
@test "/usr/share/java/cp-base-new/jackson-annotations-2.12.3.jar should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/share/java/cp-base-new/jackson-annotations-2.12.3.jar
    assert_success
}

@test "/usr/share/java/cp-base-new/jackson-annotations-2.12.3.jar should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /usr/share/java/cp-base-new/jackson-annotations-2.12.3.jar
    assert_output --partial "appuser"
}
@test "/usr/share/java/cp-base-new/jackson-core-2.12.3.jar should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/share/java/cp-base-new/jackson-core-2.12.3.jar
    assert_success
}

@test "/usr/share/java/cp-base-new/jackson-core-2.12.3.jar should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /usr/share/java/cp-base-new/jackson-core-2.12.3.jar
    assert_output --partial "appuser"
}
@test "/usr/share/java/cp-base-new/jackson-databind-2.12.3.jar should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/share/java/cp-base-new/jackson-databind-2.12.3.jar
    assert_success
}

@test "/usr/share/java/cp-base-new/jackson-databind-2.12.3.jar should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /usr/share/java/cp-base-new/jackson-databind-2.12.3.jar
    assert_output --partial "appuser"
}
@test "/usr/share/java/cp-base-new/jackson-dataformat-csv-2.12.3.jar should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/share/java/cp-base-new/jackson-dataformat-csv-2.12.3.jar
    assert_success
}

@test "/usr/share/java/cp-base-new/jackson-dataformat-csv-2.12.3.jar should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /usr/share/java/cp-base-new/jackson-dataformat-csv-2.12.3.jar
    assert_output --partial "appuser"
}
@test "/usr/share/java/cp-base-new/jackson-dataformat-yaml-2.12.3.jar should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/share/java/cp-base-new/jackson-dataformat-yaml-2.12.3.jar
    assert_success
}

@test "/usr/share/java/cp-base-new/jackson-dataformat-yaml-2.12.3.jar should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /usr/share/java/cp-base-new/jackson-dataformat-yaml-2.12.3.jar
    assert_output --partial "appuser"
}
@test "/usr/share/java/cp-base-new/jackson-datatype-jdk8-2.12.3.jar should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/share/java/cp-base-new/jackson-datatype-jdk8-2.12.3.jar
    assert_success
}

@test "/usr/share/java/cp-base-new/jackson-datatype-jdk8-2.12.3.jar should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /usr/share/java/cp-base-new/jackson-datatype-jdk8-2.12.3.jar
    assert_output --partial "appuser"
}
@test "/usr/share/java/cp-base-new/jackson-module-scala_2.13-2.12.3.jar should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/share/java/cp-base-new/jackson-module-scala_2.13-2.12.3.jar
    assert_success
}

@test "/usr/share/java/cp-base-new/jackson-module-scala_2.13-2.12.3.jar should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /usr/share/java/cp-base-new/jackson-module-scala_2.13-2.12.3.jar
    assert_output --partial "appuser"
}
@test "/usr/share/java/cp-base-new/jmx_prometheus_javaagent-0.14.0.jar should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/share/java/cp-base-new/jmx_prometheus_javaagent-0.14.0.jar
    assert_success
}

@test "/usr/share/java/cp-base-new/jmx_prometheus_javaagent-0.14.0.jar should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /usr/share/java/cp-base-new/jmx_prometheus_javaagent-0.14.0.jar
    assert_output --partial "appuser"
}
@test "/usr/share/java/cp-base-new/jolokia-core-1.6.2.jar should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/share/java/cp-base-new/jolokia-core-1.6.2.jar
    assert_success
}

@test "/usr/share/java/cp-base-new/jolokia-core-1.6.2.jar should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /usr/share/java/cp-base-new/jolokia-core-1.6.2.jar
    assert_output --partial "appuser"
}
@test "/usr/share/java/cp-base-new/jolokia-jvm-1.6.2-agent.jar should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/share/java/cp-base-new/jolokia-jvm-1.6.2-agent.jar
    assert_success
}

@test "/usr/share/java/cp-base-new/jolokia-jvm-1.6.2-agent.jar should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /usr/share/java/cp-base-new/jolokia-jvm-1.6.2-agent.jar
    assert_output --partial "appuser"
}
@test "/usr/share/java/cp-base-new/jopt-simple-5.0.4.jar should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/share/java/cp-base-new/jopt-simple-5.0.4.jar
    assert_success
}

@test "/usr/share/java/cp-base-new/jopt-simple-5.0.4.jar should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /usr/share/java/cp-base-new/jopt-simple-5.0.4.jar
    assert_output --partial "appuser"
}
@test "/usr/share/java/cp-base-new/json-simple-1.1.1.jar should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/share/java/cp-base-new/json-simple-1.1.1.jar
    assert_success
}

@test "/usr/share/java/cp-base-new/json-simple-1.1.1.jar should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /usr/share/java/cp-base-new/json-simple-1.1.1.jar
    assert_output --partial "appuser"
}

@test "/usr/share/java/cp-base-new/kafka-clients-7.0.0-ccs.jar should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/share/java/cp-base-new/kafka-clients-7.0.0-ccs.jar
    assert_success
}

@test "/usr/share/java/cp-base-new/kafka-clients-7.0.0-ccs.jar should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /usr/share/java/cp-base-new/kafka-clients-7.0.0-ccs.jar
    assert_output --partial "appuser"
}
@test "/usr/share/java/cp-base-new/kafka-metadata-7.0.0-ccs.jar should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/share/java/cp-base-new/kafka-metadata-7.0.0-ccs.jar
    assert_success
}

@test "/usr/share/java/cp-base-new/kafka-metadata-7.0.0-ccs.jar should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /usr/share/java/cp-base-new/kafka-metadata-7.0.0-ccs.jar
    assert_output --partial "appuser"
}
@test "/usr/share/java/cp-base-new/kafka-raft-7.0.0-ccs.jar should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/share/java/cp-base-new/kafka-raft-7.0.0-ccs.jar
    assert_success
}

@test "/usr/share/java/cp-base-new/kafka-raft-7.0.0-ccs.jar should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /usr/share/java/cp-base-new/kafka-raft-7.0.0-ccs.jar
    assert_output --partial "appuser"
}
@test "/usr/share/java/cp-base-new/kafka-server-common-7.0.0-ccs.jar should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/share/java/cp-base-new/kafka-server-common-7.0.0-ccs.jar
    assert_success
}

@test "/usr/share/java/cp-base-new/kafka-server-common-7.0.0-ccs.jar should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /usr/share/java/cp-base-new/kafka-server-common-7.0.0-ccs.jar
    assert_output --partial "appuser"
}
@test "/usr/share/java/cp-base-new/kafka-storage-7.0.0-ccs.jar should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/share/java/cp-base-new/kafka-storage-7.0.0-ccs.jar
    assert_success
}

@test "/usr/share/java/cp-base-new/kafka-storage-7.0.0-ccs.jar should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /usr/share/java/cp-base-new/kafka-storage-7.0.0-ccs.jar
    assert_output --partial "appuser"
}
@test "/usr/share/java/cp-base-new/kafka-storage-api-7.0.0-ccs.jar should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/share/java/cp-base-new/kafka-storage-api-7.0.0-ccs.jar
    assert_success
}

@test "/usr/share/java/cp-base-new/kafka-storage-api-7.0.0-ccs.jar should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /usr/share/java/cp-base-new/kafka-storage-api-7.0.0-ccs.jar
    assert_output --partial "appuser"
}
@test "/usr/share/java/cp-base-new/kafka_2.13-7.0.0-ccs.jar should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/share/java/cp-base-new/kafka_2.13-7.0.0-ccs.jar
    assert_success
}

@test "/usr/share/java/cp-base-new/kafka_2.13-7.0.0-ccs.jar should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /usr/share/java/cp-base-new/kafka_2.13-7.0.0-ccs.jar
    assert_output --partial "appuser"
}
@test "/usr/share/java/cp-base-new/lz4-java-1.7.1.jar should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/share/java/cp-base-new/lz4-java-1.7.1.jar
    assert_success
}

@test "/usr/share/java/cp-base-new/lz4-java-1.7.1.jar should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /usr/share/java/cp-base-new/lz4-java-1.7.1.jar
    assert_output --partial "appuser"
}
@test "/usr/share/java/cp-base-new/metrics-core-2.2.0.jar should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/share/java/cp-base-new/metrics-core-2.2.0.jar
    assert_success
}

@test "/usr/share/java/cp-base-new/metrics-core-2.2.0.jar should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /usr/share/java/cp-base-new/metrics-core-2.2.0.jar
    assert_output --partial "appuser"
}

@test "/usr/share/java/cp-base-new/metrics-core-4.1.12.1.jar should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/share/java/cp-base-new/metrics-core-4.1.12.1.jar
    assert_success
}

@test "/usr/share/java/cp-base-new/metrics-core-4.1.12.1.jar should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /usr/share/java/cp-base-new/metrics-core-4.1.12.1.jar
    assert_output --partial "appuser"
}
@test "/usr/share/java/cp-base-new/paranamer-2.8.jar should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/share/java/cp-base-new/paranamer-2.8.jar
    assert_success
}

@test "/usr/share/java/cp-base-new/paranamer-2.8.jar should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /usr/share/java/cp-base-new/paranamer-2.8.jar
    assert_output --partial "appuser"
}
@test "/usr/share/java/cp-base-new/scala-collection-compat_2.13-2.4.4.jar should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/share/java/cp-base-new/scala-collection-compat_2.13-2.4.4.jar
    assert_success
}

@test "/usr/share/java/cp-base-new/scala-collection-compat_2.13-2.4.4.jar should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /usr/share/java/cp-base-new/scala-collection-compat_2.13-2.4.4.jar
    assert_output --partial "appuser"
}
@test "/usr/share/java/cp-base-new/scala-java8-compat_2.13-1.0.0.jar should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/share/java/cp-base-new/scala-java8-compat_2.13-1.0.0.jar
    assert_success
}

@test "/usr/share/java/cp-base-new/scala-java8-compat_2.13-1.0.0.jar should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /usr/share/java/cp-base-new/scala-java8-compat_2.13-1.0.0.jar
    assert_output --partial "appuser"
}
@test "/usr/share/java/cp-base-new/scala-library-2.13.5.jar should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/share/java/cp-base-new/scala-library-2.13.5.jar
    assert_success
}

@test "/usr/share/java/cp-base-new/scala-library-2.13.5.jar should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /usr/share/java/cp-base-new/scala-library-2.13.5.jar
    assert_output --partial "appuser"
}
@test "/usr/share/java/cp-base-new/scala-logging_2.13-3.9.3.jar should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/share/java/cp-base-new/scala-logging_2.13-3.9.3.jar
    assert_success
}

@test "/usr/share/java/cp-base-new/scala-logging_2.13-3.9.3.jar should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /usr/share/java/cp-base-new/scala-logging_2.13-3.9.3.jar
    assert_output --partial "appuser"
}
@test "/usr/share/java/cp-base-new/scala-reflect-2.13.5.jar should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/share/java/cp-base-new/scala-reflect-2.13.5.jar
    assert_success
}

@test "/usr/share/java/cp-base-new/scala-reflect-2.13.5.jar should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /usr/share/java/cp-base-new/scala-reflect-2.13.5.jar
    assert_output --partial "appuser"
}
@test "/usr/share/java/cp-base-new/slf4j-api-1.7.30.jar should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/share/java/cp-base-new/slf4j-api-1.7.30.jar
    assert_success
}

@test "/usr/share/java/cp-base-new/slf4j-api-1.7.30.jar should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /usr/share/java/cp-base-new/slf4j-api-1.7.30.jar
    assert_output --partial "appuser"
}
@test "/usr/share/java/cp-base-new/slf4j-simple-1.7.30.jar should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/share/java/cp-base-new/slf4j-simple-1.7.30.jar
    assert_success
}

@test "/usr/share/java/cp-base-new/slf4j-simple-1.7.30.jar should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /usr/share/java/cp-base-new/slf4j-simple-1.7.30.jar
    assert_output --partial "appuser"
}

@test "/usr/share/java/cp-base-new/snakeyaml-1.27.jar should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/share/java/cp-base-new/snakeyaml-1.27.jar
    assert_success
}

@test "/usr/share/java/cp-base-new/snakeyaml-1.27.jar should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /usr/share/java/cp-base-new/snakeyaml-1.27.jar
    assert_output --partial "appuser"
}
@test "/usr/share/java/cp-base-new/snappy-java-1.1.8.1.jar should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/share/java/cp-base-new/snappy-java-1.1.8.1.jar
    assert_success
}

@test "/usr/share/java/cp-base-new/snappy-java-1.1.8.1.jar should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /usr/share/java/cp-base-new/snappy-java-1.1.8.1.jar
    assert_output --partial "appuser"
}
@test "/usr/share/java/cp-base-new/utility-belt-7.0.0.jar should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/share/java/cp-base-new/utility-belt-7.0.0.jar
    assert_success
}

@test "/usr/share/java/cp-base-new/utility-belt-7.0.0.jar should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /usr/share/java/cp-base-new/utility-belt-7.0.0.jar
    assert_output --partial "appuser"
}
@test "/usr/share/java/cp-base-new/zookeeper-3.6.3.jar should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/share/java/cp-base-new/zookeeper-3.6.3.jar
    assert_success
}

@test "/usr/share/java/cp-base-new/zookeeper-3.6.3.jar should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /usr/share/java/cp-base-new/zookeeper-3.6.3.jar
    assert_output --partial "appuser"
}
@test "/usr/share/java/cp-base-new/zookeeper-jute-3.6.3.jar should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/share/java/cp-base-new/zookeeper-jute-3.6.3.jar
    assert_success
}

@test "/usr/share/java/cp-base-new/zookeeper-jute-3.6.3.jar should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /usr/share/java/cp-base-new/zookeeper-jute-3.6.3.jar
    assert_output --partial "appuser"
}
@test "/usr/share/java/cp-base-new/zstd-jni-1.5.0-2.jar should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/share/java/cp-base-new/zstd-jni-1.5.0-2.jar
    assert_success
}

@test "/usr/share/java/cp-base-new/zstd-jni-1.5.0-2.jar should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /usr/share/java/cp-base-new/zstd-jni-1.5.0-2.jar
    assert_output --partial "appuser"
}
@test "/etc/confluent/docker/bash-config should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /etc/confluent/docker/bash-config
    assert_success
}

@test "/etc/confluent/docker/bash-config should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /etc/confluent/docker/bash-config
    assert_output --partial "appuser"
}
@test "/etc/confluent/docker/mesos-setup.sh should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /etc/confluent/docker/mesos-setup.sh
    assert_success
}

@test "/etc/confluent/docker/mesos-setup.sh should be owned by appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} stat -c '%U' /etc/confluent/docker/mesos-setup.sh
    assert_output --partial "appuser"
}

@test "whoami should be appuser" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} whoami
    assert_output --partial "appuser"
}

@test "pwd should be /home/appuser/" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} pwd
    assert_output --partial "/home/appuser"
}

@test "/usr/local/bin/dub should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/local/bin/dub
    assert_success
}

@test "/usr/local/bin/cub should exist" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} test -f /usr/local/bin/cub
    assert_success
}

@test "bash -c '/usr/local/bin/dub --help' should output Docker Utility Belt" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} bash -c '/usr/local/bin/dub --help'
    assert_output --partial "Docker Utility Belt"
}
@test "bash -c '/usr/local/bin/cub --help' should output Docker Utility Belt" {
    run $BATS_BUILD_TOOL exec -it cp-base-test-${ARCH} bash -c '/usr/local/bin/cub --help'
    assert_output --partial "Confluent Platform Utility Belt"
}
