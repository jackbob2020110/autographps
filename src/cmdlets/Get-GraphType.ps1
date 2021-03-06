# Copyright 2020, Adam Edwards
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

. (import-script ../typesystem/TypeManager)
. (import-script common/TypeHelper)
. (import-script common/TypeParameterCompleter)

function Get-GraphType {
    [cmdletbinding(positionalbinding=$false, defaultparametersetname='optionallyqualified')]
    [OutputType('GraphTypeDisplayType')]
    param(
        [parameter(position=0, parametersetname='optionallyqualified', mandatory=$true)]
        [parameter(position=0, parametersetname='fullyqualified', mandatory=$true)]
        [Alias('Name')]
        $TypeName,

        [ValidateSet('Primitive', 'Enumeration', 'Complex', 'Entity')]
        [Alias('Class')]
        $TypeClass = 'Entity',

        [parameter(parametersetname='optionallyqualified')]
        [parameter(parametersetname='fullyqualified')]
        $Namespace,

        $GraphName,

        [parameter(parametersetname='fullyqualified', mandatory=$true)]
        [switch] $FullyQualifiedTypeName,

        [parameter(parametersetname='list', mandatory=$true)]
        [switch] $List
    )

    Enable-ScriptClassVerbosePreference

    $targetContext = $::.ContextHelper |=> GetContextByNameOrDefault $GraphName

    if ( ! $List.IsPresent ) {
        $typeManager = $::.TypeManager |=> Get $targetContext

        $isFullyQualified = $FullyQualifiedTypeName.IsPresent -or ( $typeClass -ne 'Primitive' -and $TypeName.Contains('.') )

        $type = $typeManager |=> FindTypeDefinition $typeClass $TypeName $isFullyQualified $true

        if ( ! $type ) {
            throw "The specified type '$TypeName' of type class '$typeClass' was not found in graph '$($targetContext.name)'"
        }

        $::.TypeHelper |=> ToPublic $type
    } else {
        $::.TypeProvider |=> GetSortedTypeNames $typeClass $targetContext
    }
}

$::.ParameterCompleter |=> RegisterParameterCompleter Get-GraphType TypeName (new-so TypeParameterCompleter)
$::.ParameterCompleter |=> RegisterParameterCompleter Get-GraphType GraphName (new-so GraphParameterCompleter)
