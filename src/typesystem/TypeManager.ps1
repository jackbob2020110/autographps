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

. (import-script TypeSchema)
. (import-script TypeProvider)
. (import-script ScalarTypeProvider)
. (import-script CompositeTypeProvider)
. (import-script TypeDefinition)
. (import-script GraphObjectBuilder)

ScriptClass TypeManager {
    . {}.module.newboundscriptblock($::.TypeSchema.EnumScript)

    $graph = $null
    $definitions = $null
    $prototypes = $null
    $hasRequiredTypeDefinitions = $false

    function __initialize($graph) {
        $this.graph = $graph
        $this.definitions = @{}
        $this.prototypes = @{}
    }

    function GetPrototype($typeClass, $typeName, $fullyQualified = $false) {
        $typeId = GetOptionallyQualifiedName $typeClass $typeName $fullyQualified

        $prototype = $this.prototypes[$typeId]

        if ( ! $this.prototypes.containskey($typeId) ) {
            $type = FindTypeDefinition $typeClass $typeId $true $true
            $builder = new-so GraphObjectBuilder $this $type
            $prototype = $builder |=> ToObject
            $this.prototypes[$typeId] = $prototype
        }
        $prototype
    }

    function FindTypeDefinition($typeClass, $typeName, $fullyQualified, $errorIfNotFound = $false) {
        $definition = $null

        $classes = if ( $typeClass -eq 'Unknown' ) {
            GetTypeClassPrecedence
        } else {
            [GraphTypeClass] $typeClass
        }

        foreach ( $class in $classes ) {
            $typeId = GetOptionallyQualifiedName $class $typeName $fullyQualified

            $definition = $this.definitions[$typeId]

            if ( ! $definition ) {
                try {
                    $definition = GetTypeDefinition $class $typeId
                } catch {
                    if ( $errorIfNotFound ) {
                        throw
                    }
                }
            }

            if ( $definition ) {
                break
            }
        }

        if ( $errorIfNotFound -and ! $definition ) {
            throw "Unable to find type '$typeId' of type class '$typeClass'"
        }

        $definition
    }

    function GetTypeDefinition($typeClass, $typeId, $skipRequiredTypes) {
        $definition = $this.definitions[$typeId]

        if ( ! $definition ) {
            if ( ! $skipRequiredTypes ) {
                InitializeRequiredTypes
            }

            $type = $::.TypeDefinition |=> Get $this.graph $typeClass $typeId

            $requiredTypes = @($type)

            $baseTypeId = $type.BaseType

            while ( $baseTypeId ) {
                $baseType = $::.TypeDefinition |=> Get $this.graph Unknown $baseTypeId
                $requiredTypes += $baseType

                $baseTypeId = if ( $baseType | gm BaseType -erroraction ignore ) {
                    $basetype.BaseType
                }
            }

            for ( $typeIndex = $requiredTypes.length - 1; $typeIndex -ge 0; $typeIndex-- ) {
                $requiredType = $requiredTypes[$typeIndex]
                $requiredTypeId = $requiredType.typeId
                if ( ! $this.definitions[$requiredTypeId] ) {
                    AddTypeDefinition $requiredTypeId $requiredType
                }
            }

            $definition = $this.definitions[$typeId]
        }

        $definition
    }

    function AddTypeDefinition($typeId, $type) {
        if ( $this.definitions[$typeId] ) {
            throw "Type '$typeId' already exists"
        }

        $this.definitions.Add($typeId, $type)
    }

    function InitializeRequiredTypes {
        if ( ! $this.hasRequiredTypeDefinitions ) {
            $requiredTypeInfo = $::.TypeProvider |=> GetRequiredTypeInfo

            $requiredTypeInfo | foreach {
                GetTypeDefinition $requiredTypeInfo.typeClass $requiredTypeInfo.typeId $true | out-null
            }

            $this.hasRequiredTypeDefinitions = $true
        }
    }

    function GetTypeClassPrecedence {
        [GraphTypeClass]::Primitive, [GraphTypeClass]::Entity, [GraphTypeClass]::Complex, [GraphTypeClass]::Enumeration
    }

    function GetOptionallyQualifiedName($typeClass, $typeName, $isFullyQualified) {
        if ( $isFullyQualified ) {
            $typeName
        } else {
            $typeNamespace = $::.TypeProvider |=> GetDefaultNamespace $typeClass $this.graph
            $::.TypeSchema |=> GetQualifiedTypeName $typeNamespace $typeName
        }
    }

    static {
        $managerByGraph = @{}

        function Get($graph) {
            $graphId = $graph |=> GetScriptObjectHashCode
            $manager = $managerByGraph[$graphId]

            if ( ! $manager ) {
                $manager = new-so TypeManager $graph
                $managerByGraph[$graphId] = $manager
            }

            $manager
        }
    }
}

