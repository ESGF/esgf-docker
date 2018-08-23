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

These branches are only committed to using pull requests.
[Jenkins](https://jenkins.io/) is configured to automatically build pull requests
when they are submitted, and a pull request should not be merged without a
successful build.

Jenkins is also configured to automatically build, tag and push each commit to the
`master` and `devel` branches, using the `latest` and `devel` Docker tags
respectively. Each commit is also given a unique Docker tag that combines the
closest tag and the commit hash, allowing deployments to target a specific commit.

## Making a contribution

These steps describe the process to follow when making a contribution. They assume
that you do **not** have write access to the main `esgf-docker` repository. Those
with write access to the main `esgf-docker` repository are free to work in branches
in that repository if they wish.

  * Unless you are working on an existing issue, create a Github issue [in the
    main esgf-docker repository](https://github.com/ESGF/esgf-docker/issues)
    describing the change you intend to make.
  * If this is your first contribution, create a GitHub fork of the main `esgf-docker`
    repository in your own workspace and check it out to your development machine.
    ```
    git clone git@github.com:<github username>/esgf-docker
    ```
  * Ensure you have pulled the latest changes from the `devel` branch.
    ```
    git checkout devel
    git pull upstream
    ```
  * Create a new branch from `devel`.  
    The preferred format for the branch name is `issue/<issue number>/<descriptive slug>` -
    for example, the branch that created this page is called `issue/46/contributing-docs`.
    ```
    git checkout -b <branch name>
    ```
  * Make your changes in this branch, referencing the issue from above using the
    `ESGF/esgf-docker#<issue number>` syntax in commit messages.
    ```
    git add [-A | list of files]
    git commit -m "ESGF/esgf-docker#<issue number> <commit message>"
    ```
  * Make sure all your changes are pushed to your GitHub fork.
    ```
    git push
    ```
  * Once you have completed and tested your changes, submit a pull request from
    the branch in your GitHub fork targeting the `devel` branch in the main
    `esgf-docker` repository.
  * Iterate with the reviewer until your pull request is accepted and merged to `devel`.  
    If `devel` has changed since you created your branch, this may involve
    [rebasing](https://git-scm.com/docs/git-rebase) to the current `HEAD` of `devel`
    and fixing any merge conflicts.

## Committing to master

The following describe the process of committing to the `master` branch. This will
generally only happen for a release. The steps assume you have write access to the
main `esgf-docker` repository.

Releases should have the format `{major}.{minor}.{patch}[.{alpha|beta}.{increment}]`,
e.g. `2.0.1`, `2.1.0.alpha.0` or `3.0.0.beta.2`.

  * Create an integration branch from the current `devel`.  
    The preferred format for naming of integration branches is `integration/<release>`.
    ```
    git checkout devel
    git pull
    git checkout -b integration/<release>
    ```
  * [Rebase](https://git-scm.com/docs/git-rebase) the integration branch onto `master`
    and fix any merge conflicts.
    ```
    git rebase master
    ```
  * Perform the required testing for a release, making any required fixes. Once
    you are satisfied, submit a pull request targeting `master`.
  * Merge the pull request onto `master`.
  * Tag `master` with the release.
    ```
    git checkout master
    git pull
    git tag <release>
    git push --tags
    ```
  * Rebase `devel` to the current `HEAD` of `master`. If `devel` has changed since
    the integration branch was created, this may involve fixing any merge conflicts.
    ```
    git checkout master
    git pull
    git checkout devel
    git pull
    git rebase master
    git push
    ```
