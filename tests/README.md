# Testing with data.yaml

Since each environment is different, we want to keep a set of test manifests that is easy to share. The goal is to keep the manifests generic so it doesn't require changes for testing. Copy the sample.yaml into data.yaml and modify it to suit your lab environment.

    $ cp sample.yaml data.yaml
    $ enc_apply --noop vcsa.pp
