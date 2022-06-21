# Release checklist

- [ ] Is the [changelog] up-to-date?


- [ ] Pick the release version, for example `2.3.0`
- [ ] Run [_Create a draft release_] to create the release branch and draft.


- [ ] Rename _Unreleased_ section of CHANGELOG.md to release version
- [ ] Any other changes to make?
- [ ] Push all changes


- [ ] Finalize and publish the [release], which pushes the release tag
- [ ] Did the [_Update major tag_] workflow run automatically?


- [ ] Delete any [branches] you're done with


[_Create a draft release_]: https://github.com/solvaholic/octodns-sync/actions/workflows/release.yml
[_Update major tag_]: https://github.com/solvaholic/octodns-sync/actions/workflows/update-major.yml
[branches]: https://github.com/solvaholic/octodns-sync/branches
[changelog]: https://github.com/solvaholic/octodns-sync/blob/main/docs/CHANGELOG.md
[release]: https://github.com/solvaholic/octodns-sync/releases
