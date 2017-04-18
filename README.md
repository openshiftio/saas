# SaaS

This repository holds information about where to find OpenShift templates for the DSaaS.

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