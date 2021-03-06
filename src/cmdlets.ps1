# Copyright 2019, Adam Edwards
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

. (import-script client/LocationContext)

. (import-script cmdlets\Find-GraphPermission)
. (import-script cmdlets\Get-Graph)
. (import-script cmdlets\Get-GraphItemWithMetadata)
. (import-script cmdlets\Get-GraphChildItem)
. (import-script cmdlets\Get-GraphLocation)
. (import-script cmdlets\Get-GraphType)
. (import-script cmdlets\Get-GraphUri)
. (import-script cmdlets\New-Graph)
. (import-script cmdlets\Remove-Graph)
. (import-script cmdlets\Set-GraphLocation)
. (import-script cmdlets\Set-GraphPrompt)
. (import-script cmdlets\Show-GraphHelp)
. (import-script cmdlets\Update-GraphMetadata)
. (import-script cmdlets\New-GraphObject)

# Add parameter completion to commands exported by a different module as a UX enhancement
$::.ParameterCompleter |=> RegisterParameterCompleter Invoke-GraphRequest RelativeUri (new-so GraphUriParameterCompleter ([GraphUriCompletionType]::LocationOrMethodUri ))
$::.ParameterCompleter |=> RegisterParameterCompleter Get-GraphItem ItemRelativeUri (new-so GraphUriParameterCompleter ([GraphUriCompletionType]::LocationOrMethodUri ))
