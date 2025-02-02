#!/bin/bash

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


image_base_name="jackcviers"
image_component_name="cp-base-new"
image_name=${image_base_name}/${image_component_name}

build_base(){
    local build_tool=$1
    local version=$2
    local docker_context_path=$3
    local arch=$4
    
    local tag="${image_name}:${version}.${arch}"
    local docker_file="${docker_context_path}/Dockerfile.${arch}"
    log_info "Building ${tag} from ${docker_file} with ${build_tool}"
    $build_tool build \
		--arch=${arch} \
		-t ${image_name}:${version}.${arch} \
		--build-arg ARCH=${arch} \
		--build-arg VERSION=$version \
		-f $docker_file
}
