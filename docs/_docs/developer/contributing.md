---
title: Contributing
category: Developers
order: 2.3
toc: false
---

Contribution to `esgf-docker` happens via the GitHub repository -
[https://github.com/ESGF/esgf-docker](https://github.com/ESGF/esgf-docker) -
following a feature-branch-style workflow.

## Protected branches

The `esgf-docker` repository has two protected branches:

  * `master` contains only code that has been tested. The intention is that any
    commit to `master` could be deployed in production. This is the branch against
    which releases are tagged.

  * `devel` contains the latest development code. The intention is that each commit
    to `devel` works, but is not as well tested as `master`.

These branches are only committed to using pull requests from feature branches.
[Travis](https://travis-ci.org/ESGF/esgf-docker) is configured to automatically
build pull requests when they are submitted, and a pull request should not be
merged without a successful build.

Travis is also configured to automatically build, tag and push each commit to the
`master` and `devel` branches, using the `latest` and `devel` Docker tags
respectively. Each commit is also given a unique Docker tag that combines the
closest tag and the commit hash, allowing deployments to target a specific commit.

## Making a contribution

The steps to follow when making a contribution are:

  * Create an issue describing the change you intend to make, if one does not already exist
  * Ensure you have pulled the latest changes from the `devel` branch
  * Create a new branch from `devel`, either in the `esgf-docker` repository (if you have
    permission) or in your own fork
  * Make your changes - referencing the issue from above using the `#<issue number>` syntax in commit messages
  * Once you are confident that your changes are working, submit a pull request
    targeting the `devel` branch
  * Iterate with the reviewer until your pull request is accepted and merged to `devel`
