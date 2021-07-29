# Release checklist

- [ ] Is the [changelog] up-to-date?


- [ ] Pick the release version, for example `2.3.0`
- [ ] Create a matching branch from `main`, for example `release-2.3.0`
- [ ] Push your branch
- [ ] Did the _Create a draft release_ [workflow] run automatically?


- [ ] Rename _Unreleased_ section of CHANGELOG.md to release version
- [ ] Any other changes to make?
- [ ] Push all changes


- [ ] Finalize and publish the [release], which pushes the release tag
- [ ] Did the _Update major tag_ [workflow] run automatically?


- [ ] Delete any [branches] you're done with


[changelog]: https://github.com/solvaholic/octodns-sync/blob/main/docs/CHANGELOG.md
[workflow]: https://github.com/solvaholic/octodns-sync/actions
[release]: https://github.com/solvaholic/octodns-sync/releases
[branches]: https://github.com/solvaholic/octodns-sync/branches