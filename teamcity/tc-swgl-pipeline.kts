import jetbrains.buildServer.configs.kotlin.v2019_2.*
import jetbrains.buildServer.configs.kotlin.v2019_2.buildFeatures.dockerSupport
import jetbrains.buildServer.configs.kotlin.v2019_2.buildSteps.ScriptBuildStep
import jetbrains.buildServer.configs.kotlin.v2019_2.buildSteps.script
import jetbrains.buildServer.configs.kotlin.v2019_2.projectFeatures.dockerRegistry
import jetbrains.buildServer.configs.kotlin.v2019_2.projectFeatures.githubConnection
import jetbrains.buildServer.configs.kotlin.v2019_2.triggers.vcs
import jetbrains.buildServer.configs.kotlin.v2019_2.vcs.GitVcsRoot

/*
The settings script is an entry point for defining a TeamCity
project hierarchy. The script should contain a single call to the
project() function with a Project instance or an init function as
an argument.

VcsRoots, BuildTypes, Templates, and subprojects can be
registered inside the project using the vcsRoot(), buildType(),
template(), and subProject() methods respectively.

To debug settings scripts in command-line, run the

    mvnDebug org.jetbrains.teamcity:teamcity-configs-maven-plugin:generate

command and attach your debugger to the port 8000.

To debug in IntelliJ Idea, open the 'Maven Projects' tool window (View
-> Tool Windows -> Maven Projects), find the generate task node
(Plugins -> teamcity-configs -> teamcity-configs:generate), the
'Debug' option is available in the context menu for the task.
*/

version = "2020.2"

project {
    description = "Sweagle integration with TeamCity CI/CD"

    params {
        param("SWGL_TENANT", "https://testing.sweagle.com")
    }

    features {
        dockerRegistry {
            id = "PROJECT_EXT_3"
            name = "Sweagle Registry"
            url = "docker.sweagle.com:8444"
            /* ACTION: enter your docker registry credentials */
            userName = ""
            password = ""
        }
    }

    subProject(Swgl)
}


object Swgl : Project({
    name = "swgl"
    description = "Sweagle CLI"

    vcsRoot(Swgl_HttpsGithubComCyrRivSwglDemoRefsHeadsMain)

    buildType(Swgl_Cli)

    features {
        githubConnection {
            id = "PROJECT_EXT_2"
            displayName = "swgl-demo"
            /* ACTION: enter your GitHub credentials if apply */
            clientId = ""
            clientSecret = ""
        }
    }
})

object Swgl_Cli : BuildType({
    name = "cli"
    description = "Sweagle CLI"

    params {
        param("VALIDATOR_NAME", "noDevValue")
        param("EXPORTER_FORMAT", "json")
        param("CONFIG_FILE", "./frontend.properties")
        param("EXPORTER_ARG", "frontend")
        param("CONFIG_TYPE", "PROPS")
        param("EXPORTER_NAME", "ReturnData4Node")
        param("SWEAGLE_MAPPED_TENANT", "https://testing.sweagle.com")
        /* ACTION: enter Sweagle API user username */
        param("SWEAGLE_MAPPED_USER", "")
        param("env.PATH", "/opt:/usr/bin")
        /* ACTION: enter Sweagle nodepath to upload data */
        param("NODE_PATH", "")
        /* ACTION: enter Sweagle API user token */
        param("SWEAGLE_MAPPED_TOKEN", "")
        /* ACTION: enter Sweagle Config Data Set */
        param("CDS_NAME", "")
    }

    vcs {
        root(Swgl_HttpsGithubComCyrRivSwglDemoRefsHeadsMain)
    }

    steps {
        script {
            name = "check connection"
            scriptContent = """
                sweagle options --newenv %SWEAGLE_MAPPED_TENANT% --newusername %SWEAGLE_MAPPED_USER% --newtoken %SWEAGLE_MAPPED_TOKEN%
                sweagle info
            """.trimIndent()
            dockerImagePlatform = ScriptBuildStep.ImagePlatform.Linux
            dockerImage = "docker.sweagle.com:8444/sweagle-docker/sweagle-cli:1.1.0"
            dockerRunParameters = "-e PATH=%env.PATH%"
        }
        script {
            name = "Update data model"
            scriptContent = "sweagle uploadData --filePath %CONFIG_FILE% --type %CONFIG_TYPE% --nodePath %NODE_PATH% --autoApprove"
            dockerImagePlatform = ScriptBuildStep.ImagePlatform.Linux
            dockerImage = "docker.sweagle.com:8444/sweagle-docker/sweagle-cli:1.0.0"
            dockerRunParameters = "-e PATH=%env.PATH%"
        }
        script {
            name = "validate config"
            scriptContent = """
                #!/bin/bash
                response=${'$'}(sweagle validateCDS -v %VALIDATOR_NAME% %CDS_NAME% --forIncoming)
                if [[ ${'$'}response == *"Request failed with status code 404"* ]]; then
                echo "### No pending DCS, trying with stored values instead ###"
                response=${'$'}(sweagle validateCDS -v %VALIDATOR_NAME% %CDS_NAME%)
                fi
                echo ${'$'}response
                if [[ ${'$'}{response,,} == *"error"* ]]; then exit 1; fi
            """.trimIndent()
            dockerImagePlatform = ScriptBuildStep.ImagePlatform.Linux
            dockerImage = "docker.sweagle.com:8444/sweagle-docker/sweagle-cli:1.1.0"
            dockerRunParameters = "-e PATH=%env.PATH%"
        }
        script {
            name = "snapshot config"
            scriptContent = "sweagle storeSnapshots -n %CDS_NAME%"
            dockerImagePlatform = ScriptBuildStep.ImagePlatform.Linux
            dockerImage = "docker.sweagle.com:8444/sweagle-docker/sweagle-cli:1.1.0"
            dockerRunParameters = "-e PATH=%env.PATH%"
        }
        script {
            name = "get config"
            scriptContent = """
                #!/bin/bash
                reponse=${'$'}(sweagle exportCDS %CDS_NAME% -e %EXPORTER_NAME% -f %EXPORTER_FORMAT% -a %EXPORTER_ARG%)
                echo ${'$'}reponse > ./output.%EXPORTER_FORMAT%
                echo "###################################"
                echo "#####   DISPLAY OUTPUT FILE   #####"
                echo "###################################"
                if [ "${'$'}{%EXPORTER_FORMAT%,,}" = "json" ]; then
                cat ./output.%EXPORTER_FORMAT% | jq .
                else
                cat ./output.%EXPORTER_FORMAT%
                fi
                echo ${'$'}reponse
            """.trimIndent()
            dockerImagePlatform = ScriptBuildStep.ImagePlatform.Linux
            dockerImage = "docker.sweagle.com:8444/sweagle-docker/sweagle-cli:1.1.0"
            dockerRunParameters = "-e PATH=%env.PATH%"
        }
    }

    triggers {
        vcs {
            branchFilter = ""
        }
    }

    features {
        dockerSupport {
            loginToRegistry = on {
                dockerRegistryId = "PROJECT_EXT_3"
            }
        }
    }
})

object Swgl_HttpsGithubComCyrRivSwglDemoRefsHeadsMain : GitVcsRoot({
    /* ACTION: enter your GitHub repository details tials if apply */
    name = ""
    url = ""
    branch = ""
    /* ACTION: enter your GitHub credentials if apply */
    authMethod = password {
        userName = ""
        password = ""
    }
})
