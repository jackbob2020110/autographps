# <img src="https://raw.githubusercontent.com/adamedx/autographps/master/assets/PoshGraphIcon.png" width="50"> AutoGraphPS

| [Documentation](https://github.com/adamedx/autographps/blob/master/docs/WALKTHROUGH.md) | [Installation](#Installation) | [Usage](#usage) | [Reference](#reference) | [Contributing and development](#contributing-and-development) |
|-------------|-------------|-------------|-------------|-------------|

[![Build Status](https://adamedx.visualstudio.com/AutoGraphPS/_apis/build/status/AutoGraphPS-CI?branchName=master)](https://adamedx.visualstudio.com/AutoGraphPS/_build/latest?definitionId=5&branchName=master)

**AutoGraphPS** is a PowerShell-based CLI for exploring the [Microsoft Graph](https://graph.microsoft.io/). It can be thought of as a CLI analog to the browser-based [Graph Explorer](https://developer.microsoft.com/en-us/graph/graph-explorer). AutoGraphPS enables powerful command-line access to the Microsoft Graph REST API gateway. The Graph exposes a growing list of services such as

* Azure Active Directory (AAD)
* OneDrive
* Exchange / Outlook
* SharePoint
* And many more!

If you're an application developer, DevOps engineer, system administrator, or enthusiast power user, AutoGraphPS was made just for you. If you're building Graph-based applications in PowerShell, consider using the lighter-weight [AutoGraphPS-SDK](https://github.com/adamedx/autographps-sdk) which contains a smaller kernel of Graph cmdlets focused on automation and omits the UX affordances found in this module.

If you have ideas on how to improve **AutoGraphPS**, please consider [opening an issue](https://github.com/adamedx/autographps/issues) or a [pull request](https://github.com/adamedx/autographps/pulls).

### System requirements

On the Windows operating system, PowerShell 5.1 and higher are supported. On Linux, PowerShell 6.1.2 and higher are supported. MacOS has not been tested, but should work with PowerShell 6.1.2 and higher.

## Installation
AutoGraphPS is available through the [PowerShell Gallery](https://www.powershellgallery.com/packages/autographps); run the following command to install the latest stable release of AutoGraphPS into your user profile:

```powershell
Install-Module AutoGraphPS -scope currentuser
```

## Usage
Once you've installed, you can use an AutoGraphPS cmdlet like `Get-GraphItem` below to test out your installation. You'll need to authenticate using a [Microsoft Account](https://account.microsoft.com/account) or an [Azure Active Directory (AAD) account](https://docs.microsoft.com/en-us/azure/active-directory/active-directory-whatis):

```powershell
PS> get-graphitem me
```

After you've responded to the authentication prompt, you should see output that represents your user object similar to the following:

    id                : 82f53da9-b996-4227-b268-c20564ceedf7
    officeLocation    : 7/3191
    @odata.context    : https://graph.microsoft.com/v1.0/$metadata#users/$entity
    surname           : Okorafor
    mail              : starchild@mothership.io
    jobTitle          : Professor
    givenName         : Starchild
    userPrincipalName : starchild@mothership.io
    businessPhones    : +1 (313) 360 3141
    displayName       : Starchild Okorafor

Now you're ready to use any of AutoGraphPS's cmdlets to access and explore Microsoft Graph! Visit the [WALKTHROUGH](docs/WALKTHROUGH.md) for detailed usage of the cmdlets.

### How do I use it?

If you're familiar with the Microsoft Graph REST API or you've used [Graph Explorer](https://developer.microsoft.com/en-us/graph/graph-explorer), you know that Graph is accessed via [URI's that look like the following](https://developer.microsoft.com/en-us/graph/docs/concepts/overview#popular-requests):

```
https://graph.microsoft.com/v1.0/me/calendars
https://graph.microsoft.com/v1.0/me/people
https://graph.microsoft.com/v1.0/users
```

With AutoGraphPS cmdlets, you can invoke REST methods from PowerShell and omit the common `https://graph.microsoft.com/v1.0` of the URI as follows:

```powershell
Get-GraphItem me/calendars
Get-GraphItem me/people
Get-GraphItem users
```

These commands retrieve the same data as a `GET` for the full URIs given earlier. Of course, `Get-GraphItem` supports a `-AbsoluteUri` option to allow you to specify that full Uri if you so desire.

As with any PowerShell cmdlet, you can use AutoGraphPS cmdlets interactively or from within simple or even highly complex PowerShell scripts and modules since the cmdlets emit and operate upon PowerShell objects. For help with any of the commands in this module, try the standard `Get-Help` command, e.g. `Get-Help Get-GraphItem`.

To more details or reference material describing the resources available in the Graph API and how to make valid requests, visit the [Graph API documentation](https://docs.microsoft.com/en-us/graph/api/overview?toc=./ref/toc.json&view=graph-rest-1.0).

### More fun commands

Run the command below to grant permissions that allow AutoGraphPS to read your **mail**, **contacts**, **calendar**, and **OneDrive files**:

```powershell
# You only have to do this once, not each time you use AutoGraphPS
Connect-Graph User.Read, Mail.Read, Contacts.Read, Calendars.Read, Files.Read
```

Now traverse the Graph via the `gcd` alias to "move" to a new Uri current location in the Graph. This is analgous to the usage of "cd" to change to a new current working directory in file-system oriented shells like `bash` and PowerShell:

```
gcd me
[starchild@mothership.io] /v1.0:/me
PS>
```

Notice the update to your prompt showing your authenticated identity and your new current location after invoking that last cmdlet: `[starchild@mothership.io] /v1.0:/me`. **Tip:** the `gwd` alias acts like `pwd` in the file system and retrieve your current working location in the Graph.

Now you can use the `gls` alias as you would `ls` in the file system relative to your current location. Here's how you can read your email:

```
[starchild@mothership.io] /v1.0:/me
PS> gls messages
```

Here are a few more commands to try -- note that you can also use absolute paths rather than paths relative to the current location
```powershell
# Lists your calendars, assuming you're at /me
gls calendars

# Same thing, uses an absolute path
gls /me/calendars

# Get data about your organizationn
gls /organization

# Get all the paths at the root of the Graph
gls /

```

Finally, here's one to enumerate your OneDrive files
```
[starchild@mothership.io] /v1.0:/me
PS> gcd drive/root/children
[starchild@mothership.io] /v1.0:/me/drive/root/children
PS> gls

Info Type      Preview       Name
---- ----      -------       ----
t +> driveItem Recipes       13J3XD#
t +> driveItem Pyramid.js    13J3KD2
```

#### Don't forget write operations

Yes, you can perform write-operations using the `Invoke-GraphRequet` command, as in this example which creates a new `contact`:

```powershell
$contactData = @{givenName='Cleopatra Jones';emailAddresses=@(@{name='Work';Address='cleo@soulsonic.org'})}
Invoke-GraphRequest me/contacts -Method POST -Body $contactData
```

As its name suggests, the `Method` parameter of `Invoke-GraphRequest` lets you specify any **REST** method, i.e. `PUT`, `POST`, `PATCH`, and `DELETE`. Thus `Invoke-GraphRequest` is capable of executing any capability of Graph and can be considered *the universal Graph command.*

Note that the `Body` parameter allows you to specify the JSON body of the request which typically describes the information to write. In the example above, rather than specify the JSON directly, we chose to express it as a PowerShell `HashTable` object. When the `Body` parameter is not a JSON string, `Invoke-GraphRequest` converts whatever type you specify to JSON for you. The way the `HashTable` was structured in this example allowed it to be serialized into exactly the JSON format required to `POST` a `contact` object to `/me/contacts` as a well-formed request.

##### New-GraphObject makes write operations easier

In the example above we constructed a PowerShell `HashTable` to supply the argument; specifying this structure is fairly intuitive if you know the JSON format you need. Just make the keys of the JSON object keys of the `HashTable`, and the values of the JSON object values of the `HashTable`. AutoGraphPS can use PowerShell's JSON serialization to transform it into the JSON required by Graph. If you commonly deal with PowerShell `HashTable` objects and syntax, this is a natural and concise way to specify JSON parameters.

The `New-GraphObject` command makes this even easier. If you know the name of the type of object, in this case `contact`, and you know the properties you need to set, you can specify that information explicitly. This would result in the more readable version of the previous example below:

```powershell
$emailAddress = New-GraphObject -TypeClass Complex emailAddress -Property name, address -value Work, cleo@soulsonic.org
$contactData = New-GraphObject contact -Property givenName, emailAddresses -value 'Cleopatra Jones', $emailAddress
Invoke-GraphRequest me/contacts -Method POST -Body $contactData

```

Note that support for a simpler command interface for write operations is coming soon to AutoGraphPS that will bring ease-of-use parity with the read-only commands. Key problems to solve here include discovering the kinds of object and types you need (including removing the need to know when to use the `TypeClass` parameter in the example above) and simplifying and standardizing the command and parameters used to issue the actual write operation.

#### So how do I find all the URIs and JSON for Graph?

In the examples above, specific URIs were featured to explain how common uses of the Graph API are surfaced in AutoGraphPS. But in general how does one discover which URIs implement which functionality? And particularly for write requests, what is the required structure for the JSON body?

In general, this information may be found in the [Graph documentation](https://docs.microsoft.com/en-us/graph/?view=graph-rest-1.0). The [reference section](https://docs.microsoft.com/en-us/graph/api/overview?toc=./ref/toc.json&view=graph-rest-1.0) in particular is organized around *resources* such as `user`, `group`, `message`, `contact`, `driveItem`, `profilePhoto`, .etc, which model the surface of what can be managed with Graph. These resources are named after concepts that are likely familiar and accessible to you; you can learn browse through the reference and related documentation with these concepts as a guide to finding the resource, and thus its documented URI, that corresponds to the capability you'd like to exercise.

In the spirit of documentation, AutoGraphPS includes the `Show-GraphHelp` command that provides a shortcut to the documentation. Just specify the name of a resource, such as `user`, and it will launch a web browser to that landing page:

```powershell
Show-GraphHelp user
```

This command above shows help for user for the `v1.0` API version. To see help for the `beta` version, you can use

```powershell
Show-GraphHelp user -version beta
```

`Show-GraphHelp` launches the system's default web browser to display documentation. If you'd like to use a different web browser, or if AutoGraphPS is running in a browser-free environment, `ShowGraph-Help` can output the URI instead of starting a browser. Specify the `ShowHelpUri` parameter to obtain this URI:

```powershell
Show-GraphHelp user -ShowHelpUri
https://developer.microsoft.com/en-us/graph/docs/api-reference/v1.0/resources/user
```

#### AutoGraphPS tips
Here are a few simple tips to keep in mind as you first start using AutoGraphPS:

**1. Permissions matter:** AutoGraphPS can only access parts of the Graph for which you (or your organization's administrator) have given consent. Use the `Connnect-Graph` cmdlet to request additional permissions for AutoGraphPS, particularly if you run into authorization errors. Also, consult the [Graph permissions documentation](https://developer.microsoft.com/en-us/graph/docs/concepts/permissions_reference) to understand what permissions are required for particular subsets of the Graph. Note that if you're using an Azure Active Directory account to access the Graph, you may need your organization's administrator to consent to the permissions on your behalf in order to grant them to AutoGraphPS.

**2. Use tab-completion to learn and save time:** Many AutoGraphPS commands, including `Get-GraphITem`, `gls`, and `gcd` will tab-complete command parameters just like many other popular PowerShell commands do. URIs, resource names, and permission names are just some of the kinds of parameters that AutoGraphPS will tab-complete for you to reduce the time needed to issue a command and also clue you in on when you're potentially providing invalid input.

**3. Use commands like `gcd` and `gls` to explore the Graph!** In addition to browsing Graph documentation to find out how to use Graph APIs, you can use AutoGraphPS to browse the Graph itself. Try executing the command `gls`, and then performing a `gcd` to one of the items of the output. Invoking another `gls` may show you additional destinations to which you can `gcd`. And auto-complete is there to auto-complete URIs and minimize user input labor. By using AutoGraphPS commands in this way, you can explore the API surface of the Graph in the way you'd explore your local file system with commands like `cd` and `ls`.

**4. You can access the Beta version of the Graph API**: By default, AutoGraphPS is targeted at the default API version of Graph, `v1.0`. It also works with the `beta` version -- many commands provide a `-Version` parameter for which you can supply the value `beta` to run that command against the `beta` API version. You can tell AutoGraphPS to use `beta` for all commands by "mounting" the `beta` version. Below we mount `beta`  and set the current location to its root:

```powershell
# You could also issue the command 'new-graph beta' to mount beta explicitly
gcd /beta:/ # This sets the current location and implicitly mounts the 'beta' API version
```

And that brings us to this **Warning**: *AutoGraphPS takes some time to get fully ready for each API version.* When you first execute commands like `gls` and `gcd`,, some information about the structure of the Graph may be incomplete. In these cases you should see a "warning" message. You can also Use the `gg` alias to see the status of your mounted API versions, i.e. `Ready`, `Pending`, etc., which can take a few minutes to reach the desired `Ready` state. Eventually the warning will no longer occur and the cmdlets will return full information after the background metadata processing completes.

For a much more detailed description of AutoGraphPS's usage and capabilities, including advanced query and authentication features, see the [WALKTHROUGH](docs/WALKTHROUGH.md).

## Common uses

AutoGraphPS is your PowerShell interface to the Microsoft Graph REST API. In what contexts is such a tool useful? Here are several:

* **Developer - Graph education:** The Microsoft Graph is aimed at developers, and just as Graph Explorer helps developers learn how to make API calls to the Graph and debug them, AutoGraphPS offers the same capability, with the added benefit of the CLI's speed and automation
* **Developer - testing and debugging:** AutoGraphPS makes it trivial to reproduce errors you encounter in your application's REST calls to the Graph -- simply use the same credentials, REST method, and Uri in one of the Graph cmdlets, and you can obtain diagnostics without rebuilding your application or otherwise altering it to isolate failure cases and add debugging information. AutoGraphPS is also useful for pursuing ad hoc "what if"-style investigations of Graph functionality that is new to you or understanding Graph's corner cases without building a new application.
* **System administration:** Sysadmins manage the same services such as AAD, Exchange, and SharePoint that are exposed by the Microsoft Graph. Sysadmins are also heavy users of PowerShell. AutoGraphPS allows administrators to author PowerShell automation that takes full advantage of the management capabilities constantly being added to Microsoft Graph. Your existing PowerShell automation can be enhanced with AutoGraphPS or included in new tools based on it.
* **Developer - management tools:** Configuration management and system administration tools are popular output for developers, particularly in OSS communities. AutoGraphPS offers developers building PowerShell-based configuration management tools for their users a key library that solves authentication, modeling, querying, and deserialization. Graph calls with AutoGraphPS are typically one-liners requiring little in the way of setup, a quality that enhances your productivity as a developer.
* **Enthusiast / power user:** Users who enjoy learning about what powers their software will find AutoGraphPS a great way to not only learn about Graph, but exploit its capabilities to do things such as advanced e-mail or photo management through Exchange and OneDrive, implement their own backup features with OneDrive and SharePoint, or simply automate common tasks.

There are probably many more uses for AutoGraphPS, as wide-ranging as the Graph itself.

## Reference

The full list of cmdlets is given below; they go well beyond simply reading information from the Graph. As this library is in the early stages of development, that list is likely to evolve significantly along with their usage. Additional documentation will be provided for them as their status solidifies.

Note that since AutoGraphPS is built on [AutoGraphPS-SDK](https://github.com/adamedx/autographps-sdk), this list includes cmdlets from AutoGraphPS-SDK as well. If you are building a Graph-based application in PowerShell, consider taking a dependency on AutoGraphPS-SDK rather than AutoGraphPS if its subset of cmdlets suits your use case.

| Cmdlet (alias)            | Description                                                                                             |
|---------------------------|---------------------------------------------------------------------------------------------------------|
| Clear-GraphLog            | Clear the log of REST requests to Graph made by the module's commands                                   |
| Connect-Graph             | Establishes authentication and authorization context used across cmdlets for the current graph          |
| Disconnect-Graph          | Clears authentication and authorization context used across cmdlets for the current graph               |
| Find-GraphPermissions     | Given a search string, `Find-GraphPermissions` lists permissions with names that contain that string    |
| Find-GraphLocalCertificate  | Gets a list of local certificates created by AutoGraphPS-SDK to for app-only or confidential delegated auth to Graph |
| Format-GraphLog (fgl)       | Emits the Graph request log to the console in a manner optimized for understanding Graph and troubleshooting requests |
| Get-Graph (gg)            | Gets the current list of versioned Graph service endpoints available to AtuoGraphPS                     |
| Get-GraphChildItem (gls)  | Retrieves in tabular format the list of entities for a given Uri AND child segments of the Uri          |
| Get-GraphApplication              | Gets a list of Azure AD applications in the tenant                                              |
| Get-GraphApplicationCertificate   | Gets the certificates with public keys configured on the application                            |
| Get-GraphApplicationConsent       | Gets the list of the tenant's consent grants (entries granting an app access to capabilities of users)     |
| Get-GraphApplicationServicePrincipal | Gets the service principal for the application in the tenant                                 |
| Get-GraphConnectionInfo           | Gets information about a connection to a Graph endpoint, including identity and  `Online` or `Offline` |
| Get-GraphError (gge)      | Retrieves detailed errors returned from Graph in execution of the last command                          |
| Get-GraphItem (ggi)       | Given a relative (to the Graph or current location) Uri gets information about the entity               |
| Get-GraphItemWithMetadata (gls) | Retrieves in tabular format the list of entities and metadata for a given Uri                     |
| Get-GraphLocation (gwd)   | Retrieves the current location in the Uri hierarchy for the current graph                               |
| Get-GraphLog (ggl)        | Gets the local log of all requests to Graph made by this module                                         |
| Get-GraphLogOption        | Gets the configuration options for logging of requests to Graph including options that control the detail level of the data logged |
| Get-GraphToken            | Gets an access token for the Graph -- helpful in using other tools such as [Graph Explorer](https://developer.microsoft.com/en-us/graph/graph-explorer)  |
| Get-GraphType             | Gets metadata for the specified resource type as documented in the [Graph reference](https://developer.microsoft.com/en-us/graph/docs/concepts/v1-overview)         |
| Get-GraphUri (ggu)        | Gets detailed metadata about the segments of a Graph Uri or child segments of the Uri                   |
| Invoke-GraphRequest       | Executes a REST method (e.g. `GET`, `PUT`, `POST`, `DELETE`, etc.) for a Graph Uri                      |
| New-Graph                 | Mounts a new Graph connection and associated metadata for availability to AutoGraphPS cmdlets           |
| New-GraphApplication      | Creates an Azure AD application configured to authenticate to Microsoft Graph                           |
| New-GraphApplicationCertificate | Creates a new certificate in the local certificate store and configures its public key on an application |
| New-GraphConnection       | Creates an authenticated connection using advanced identity customizations for accessing a Graph        |
| New-GraphObject           | Creates a local representation of a type defined by the Graph API that can be specified in the body of write requests in commands such as `Invoke-GraphRequest` |
| Register-GraphApplication | Creates a registration in the tenant for an existing Azure AD application    |
| Remove-Graph              | Unmounts a Graph previously mounted by `NewGraph`                                                       |
| Remove-GraphApplication   | Deletes an Azure AD application                                                                         |
| Remove-GraphApplicationCertificate | Removes a public key from the application for a certificate allowed to authenticate as that application |
| Remove-GraphApplicationConsent | Removes consent grants for an Azure AD application                                                 |
| Remove-GraphItem                  | Makes generic ``DELETE`` requests to a specified Graph URI to delete items                      |
| Set-GraphApplicationConsent       | Sets a consent grant for an Azure AD application                                                |
| Set-GraphConnectionStatus | Configures `Offline` mode for use with local commands like `GetGraphUri` or re-enables `Online` mode for accessing the Graph service |
| Set-GraphLocation (gcd)   | Sets the current graph and location in the graph's Uri hierarchy; analog to `cd` / `set-location` cmdlet for PowerShell when working with file systems |
| Set-GraphLogOption        | Sets the configuration options for logging of requests to Graph including options that control the detail level of the data logged |
| Set-GraphPrompt           | Adds connection and location context to the PowerShell prompt or disables it                            |
| Show-GraphHelp            | Given the name of a Graph resource (e.g. 'user', 'group', etc.) launches a web browser focused on documentation for it |
| Test-Graph                | Retrieves unauthenticated diagnostic information from instances of your Graph endpoint                  |
| Unregister-GraphApplication | Removes consent and service principal entries for the application from the tenant                     |
| Update-GraphMetadata      | Downloads the the latest `$metadata` for a Graph and updates local Uri and type information accordingly |

### Limited support for Azure Active Directory (AAD) Graph

Some AutoGraphPS cmdlets also work with [Azure Active Directory Graph](https://msdn.microsoft.com/Library/Azure/Ad/Graph/howto/azure-ad-graph-api-operations-overview), simply by specifying the `-aadgraph` switch as in the following:

```powershell
Get-GraphItem me -aadgraph
```

Most functionality of AAD Graph is currently available in MS Graph itself, and in the future all of it will be accessible from MS Graph. In the most common cases where a capability is accessible via either graph, use MS Graph to ensure long-term support for your scripts and code and your ability to use the full feature set of AutoGraphPS.

### More about how it works

If you'd like a behind the scenes look at the implementation of AutoGraphPS, take a look at the following article:

* [Microsoft Graph via PowerShell](https://adamedx.github.io/softwarengineering/2018/08/09/Microsoft-Graph-via-PowerShell.html)

## Developer installation from source
For developers contributing to AutoGraphPS or those who wish to test out pre-release features that have not yet been published to PowerShell Gallery, run the following PowerShell commands to clone the repository and then build and install the module on your local system:

```powershell
git clone https://github.com/adamedx/autographps
cd autographps
.\build\install-fromsource.ps1
```

## Contributing and development

Read about our contribution process in [CONTRIBUTING.md](CONTRIBUTING.md). In addition to submitting pull requests, we also invite bug reports, eature requests, and architectural improvements through this repository's [issues page](https://github.com/adamedx/autographps/issues).

See the [Build README](build/README.md) for instructions on building and testing changes to AutoGraphPS.

## Quickstart
The Quickstart is a way to try out AutoGraphPS without installing the AutoGraphPS module. In the future it will feature an interactive tutorial. Additionally, it is useful for developers to quickly test out changes without modifying the state of the operating system or user profile. Just follow these steps on your workstation to start **AutoGraphPS**:

* [Download](https://github.com/adamedx/autographps/archive/master.zip) and extract the zip file for this repository **OR** clone it with the following command:

  `git clone https://github.com/adamedx/autographps`

* Within a **PowerShell** terminal, `cd` to the extracted or cloned directory
* Execute the command for **QuickStart**:

  `.\build\quickstart.ps1`

This will download dependencies, build the AutoGraphPS module, and launch a new PowerShell console with the module imported. You can execute a AutoGraphPS cmdlet like the following in the console -- try it:

  `Test-Graph`

This should return something like the following:

    ADSiteName : wst
    Build      : 1.0.9736.8
    DataCenter : west us
    Host       : agsfe_in_29
    PingUri    : https://graph.microsoft.com/ping
    Ring       : 4
    ScaleUnit  : 000
    Slice      : slicea
    TimeLocal  : 2/6/2018 6:05:09 AM
    TimeUtc    : 2/6/2018 6:05:09 AM

If you need to launch another console with AutoGraphPS, you can run the faster command below which skips the build step since QuickStart already did that for you (though it's ok to run QuickStart again):

    .\build\import-devmodule.ps1

These commmands can also be used when testing modifications you make to AutoGraphPS, and also give you an isolated environment in which to test and develop applications and tools that depend on AutoGraphPS.

License and authors
-------------------
Copyright:: Copyright (c) 2020 Adam Edwards

License:: Apache License, Version 2.0

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

