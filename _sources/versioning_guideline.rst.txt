********************
Versioning Guideline
********************

TLDR
====

This document is a proposal that describes the syntax of the version name of any kind of ESGF stack component.

X ; Y ; Z ; N  are zero or positive integers
v ; a ; b ; rc are just symbols::

  vX.Y   aN   syntax for alpha releases
   ^ ^   bN   syntax for beta releases
   | |   rcN  syntax for release candidates
   | |   .Z   syntax for production/maintenance releases
   | |
   | |____ minor version
   |
   |____major version


X.Y.0 is the first production release of the X.Y version family.
X.Y.Z where Z > 0, are maintenance releases of the X.Y version family.

Introduction
============

Software versioning is a process that aims to assign unique identity tag to a
unique state of a software. This process is very important as the actors of
a software development can rely on these tags so as to debug, add new features, etc.

This document is a proposal, a starting material for  discussion that will hopefully produce a guideline for the ESGF versioning.

At first, this document presents a simplified development/release cycle as
a guiding thread for the versioning syntax. The last section gives some
recommendations about the git workflow.

Release steps
=============

An example of release cycle (ascending order):

1. untag/unreleased version of ESGF stack (but versioned in a branch of the
   git repository)
2. alpha releases (optional, at the developer's discretion, to be tested by friendly users)
3. beta releases (optional, at the developer's discretion, can be tested by users knowing bugs will remain)
4. release candidates (rc)
5. production releases (first production version followed by maintenance versions)

Syntax of production release
============================

**vX.Y.Z**

X ; Y ; Z: zero or positive integer values (can take more than one character ; start at zero).
ex: v2.5.0

Note: of course, we can add another level (we have just to describe the
semantic of the level).

X: major release
****************

This value reflects the familly of the version - major version -

This value should be incremented only when the ESGF stack is substantially
modified. For example when:

- the backward compatibility is not supported with the second to last release
- the software architecture is refactored.
- core functionalities are refactored.
- etc.

Y: minor release
****************

This value reflects minor changes within the same version family 
- minor version -
This value should be incremented when the modifications of the
ESGF stack are between maintenance patches and deep modifications.
Typically when:

- adding a new feature
- substantial ui modifications
- substantial installation procedure modifications
- substantial bug fix
- etc.

Z: maintenance release
**********************

This value reflects a batch of bug fixes or cosmetic modifications.
In fact, these little modifications should have been implemented at the
release candidate step... but they have been discovered afterward.

X.Y.0 is the first production release of the X.Y version family.
X.Y.Z where Z > 0, are maintenance releases of the X.Y version family
(successors of the X.Y.0)

Maintenance release (X.Y.Z) should not have alpha/beta or rc version
(e.g. 2.5.10rc9) :
maintenance releases are just production release with lightweight modifications
or simple bug fixes. However if an important bug has been discovered, the
development team should start a new release cycle: increment the Y number and release (alpha/beta and) rc versions of the fixed stack.

Syntax of alpha/beta release
============================

Alpha and beta releases are usually for development purposes.
They are hardly ever distributed to users.
These versions are associated to the version currently in development.

* Alpha syntax: **vX.YaN** where X ; Y are like the syntax of the production
  release and N is also a zero or positive integer that refers to a specific alpha version.

* Beta syntax: **vX.YbN** where X ; Y ; N like alpha version but refers to a
  specific beta version.

Examples: v2.5a10 and v2.5b9 are, respectively, an alpha and an beta version
of the version v2.5 currently being in development.

Syntax of release candidate
===========================

Release candidates (RC) are versions of ESGF stack for real world testing.
They are distributed to users so as to get feedback and fix the last bugs, just
before the release of the production version.
The other rcs must not be distributed when the production release comes out.

RC syntax: **vX.YrcN** , where X ; Y are like the syntax of the production release
and N is also a zero or positive integer that refers to a specific release candidate.

Example: v2.5rc9 is a release candidate of the version v2.5 currently being
in development.

Rejected forms of syntax
========================

- vX.Y.aN|bN|rcN (e.g. v2.5.rc9): a dot symbol should not be placed between minor
  version and development version tag. Development versions are associated to a
  X.Y family. They are not a subfamily on their own.

- v2.5rc09 : Zeros should not be added, the number of characters of X, Y, Z and
  N is not limited.

- v2.5.9-master : Git branch information should also not be indicated, since v2.5.9 is
  enough to describe that this version is the maintenance version 9 of the 2.5
  family.

Transition from development to production version
=================================================

the latest development versions (alpha, beta or rc) are usually production
releases. They normally refer to the same state of the ESGF stack.
So the transition from the last development version to the production version
is pretty simple: create the git tag of the production release from the same set of source files of the last development version.

For example if v2.5rc10 is the version to be used as the first
production version (v2.5.0) of the v2.5 family. So v2.5rc10 and v2.5.0 refer to
the same state of the git repository.