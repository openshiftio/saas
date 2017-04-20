# SaaS

This repository holds information about where to find OpenShift templates for the DSaaS.

# Service YAML

```
services:
- hash: aab9fc5fa5c24360079998f2209b2b55c3af29ae
  hash_length: 6
  name: some-name
  path: /openshift/template.yaml
  url: https://github.com/org/repo/
  parameters:
    SOME_PARAM: some_value
```

* *hash*: Commit hash or branch which is used a) for downloading OpenShift template and b) to generate image tag for template processing (`master` is translated to `latest`)
* *hash_length*: Number of characters to be used from *hash* as an image tag
* *name*: Name of the service
* *path*: Path to the template in the repo
* *url*: URL of the repository which contains the template
* *parameters*: An object where key is the parameter name and value is the parameter value. These parameters will be added to `oc process` when processing the template

## Basic Usage

```
python saasherder/cli.py -h
```

You can pull all the templates by running

```
python saasherder/cli.py -D dsaas-templates -s dsaas-services/ pull
```

You'll find the downloaded templates in `dsaas-templates/` dir.

You can update commit hash in the `$service.yaml` file by running

```
python saasherder/cli.py -D dsaas-templates -s dsaas-services/ update -o foo.yaml hash core b52c33c8f6c40a5dca70c8b3c25387b01881bf2d
```

This will create file `foo.yaml` which will be a copy of file `services/core.yaml` with updated commit hash for `core` service.

You can also process downloaded templates to use commit hash as an image tag.

```
python saasherder/cli.py -D dsaas-templates -s dsaas-services/ template --output-dir test tag
```

This will take templates in `dsaas-templates/` and commit hashes in `dsaas-services/*.yaml` and produce processed template to `test/` directory.
It requires `oc` binary to be present on path and logged into some OpenShift instance (it actually calls `oc process` to leverage existing tooling)

## Jenkins Update

All of the SaaS services are built in CentOS CI. There is missing piece in automatic update of service.yaml files in this repo. To overcome this, `jenkins-update.py`
was created. It goes over the services in this repo and checks status of latest build in CI. If it's `SUCCESS` it updates commit has with the one from the CI build.

The usage is as simple as

```
python jenkins-update.py
```

You can easily check updated services with `git diff`