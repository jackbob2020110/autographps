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

. (import-script TypeMember)

ScriptClass TypeDefinition {
    . {}.module.newboundscriptblock($::.TypeSchema.EnumScript)

    $TypeId = $null
    $BaseType = $null
    $Name = $null
    $Namespace = $null
    $Members = $null
    $Class = $null
    $IsComposite = $false
    $DefaultValue = $null
    $DefaultCollectionValue = $null
    $NativeSchema = $null

    function __initialize($typeId, [GraphTypeClass] $class, $name, $namespace, $baseType, $members, $defaultValue, $defaultCollectionValue, $isComposite, $nativeSchema) {
        $this.TypeId = $typeId
        $this.Class = $class
        $this.BaseType = $baseType
        $this.Name = $name
        $this.Namespace = $namespace
        $this.IsComposite = $IsComposite
        $this.DefaultValue = $defaultValue
        $this.DefaultCollectionValue = $defaultCollectionValue
        $this.Members = $members
        $this.NativeSchema = $nativeSchema
    }

    static {
        . {}.module.newboundscriptblock($::.TypeSchema.EnumScript)

        function Get($graph, [GraphTypeClass] $typeClass, $typeId) {
            $typeProvider = $::.TypeProvider |=> GetTypeProvider $typeClass $graph
            $typeProvider |=> GetTypeDefinition $typeClass $typeId
        }
    }
}
