# Copyright 2018, Adam Edwards
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

. (import-script ..\metadata\GraphBuilder)

function Update-GraphMetadata {
    [cmdletbinding()]
    param(
        [string] $Version = 'v1.0',

        [PSCustomObject] $Connection,
        [parameter(parametersetname='Path', mandatory=$true)]
        $Path = $null,

        [parameter(parametersetname='Data', valuefrompipeline=$true)]
        $SchemaData,

        [switch] $Force,
        [switch] $Wait
    )
    if ( ! $Path ) {
        throw "Not yet implemented!"
    }

    $metadata = [xml] (get-content $Path | out-string)

    if ( $Force.ispresent ) {
        $::.GraphBuilder |=> StopPendingGraph $Version $Connection
    }

    $asyncGraph = $::.GraphBuilder |=> GetGraphAsync $Version $Connection $metadata

    if ( $Wait.ispresent ) {
        $::.GraphBuilder |=> WaitForGraphAsync $asyncGraph | out-null
    }
}
