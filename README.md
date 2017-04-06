# SaaS

This repository holds information about where to find OpenShift templates for the DSaaS.

## Basic Usage

```
python saasherder/cli.py -h
```

You can pull all the templates by running

```
python saasherder/cli.py -D templates -s services/ pull
```

You'll find the downloaded templates in `templates/` dir.

You can update commit hash in the `$service.yaml` file by running

```
python saasherder/cli.py -D templates -s services/ update -o foo.yaml hash launchpad-frontend b52c33c8f6c40a5dca70c8b3c25387b01881bf2d
```

This will create file `foo.yaml` which will be copy of file `services/launchpad-frontend.yaml` with updated commit hash for `launchpad-frontend` service.

You can also process downloaded templates to use commit hash as an image tag.

```
python saasherder/cli.py -D templates -s services/ template --output-dir test tag
```

This will take templates in `templates/` and commit hashes in `services/*.yaml` and produce processed template to `test/` directory.
It requires `oc` binary to be present on path and logged into some OpenShift instance (it actually calls `oc process` to leverage existing tooling)