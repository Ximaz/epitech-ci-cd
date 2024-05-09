# Epitech CI/CD

This repository contains the most essentials CI/CD GitHub actions for you to
have the "cleanest" code in terms of Epitech, and making sure it respects both
it's Coding Style and it doesn't leak, thanks to Valgrind.

This project may remember you of the `B-DOP-200 chocolatine` project, because
it's the exact same thing, except is has many more features.

# Triggers

The CI/CD will be triggered on push and when merging pull requests, on all
branches.

# Setup

## Clone this repository

To setup the workflow, you first need to clone this repository. You can copy
that one-line bash script, it will setup everyting for you :
```bash
curl -sSL https://raw.githubusercontent.com/Ximaz/epitech-ci-cd/main/setup.bash | bash
```

## Repository's Variables

### ARTIFACTS

The `ARTIFACTS` variable contains all the files that Automated Tests (Marvin)
will look for in order to evaluate your project. It is a **space-separated** list
of strings. An example could be :

`myteams_server myteams_cli`

for the `MyTeams` project.

### MIRROR_URL (optionnal)

The `MIRROR_URL` variable contains the Epitech repository you want to push your
code onto. For instance, let's keep the `MyTeams` example.

I would configure my `MIRROR_URL` with the value :

`git@github.com:EpitechPromo2027/B-NWP-400-LIL-4-1-myteams-malo.durand`

Please, note that the `MIRROR_URL` format is the SSH format, because the code
will be pushed using your `SSH_PRIVATE_KEY` secret.

### VALGRIND_SUPPRESSIONS (optionnal)

If during the `run-tests` rule execution you need to explicitly avoid memory
checks for a specific library or function, like the `_dl_open` calls for
instance, you can specify `Valgrind Suppressions` (check `2.5. Suppressing errors` from [Valgrind's Documentation](https://valgrind.org/docs/manual/valgrind_manual.pdf)
for more information about that.)

Do not abuse that feature as, the more suppressions, the less efficient memory
checks are. It's just meant for some functions of the standard library which
are known to be leaks-prone. It's not meant to avoid memory checks on your own
bad memory management.

## Repository's Secrets

### SSH_PRIVATE_KEY (if MIRROR_URL is specified)

The SSH Private Key will be used to push all the references (commits and
branches) to the Epitech mirror repository.

### SSH_PRIVATE_KEY_PASSPHRASE (optionnal)

If your `SSH_PRIVATE_KEY` was generated with a passphrase, you have to specify
it inside this secret. Make sure no one can read what while you're typing this
passphrase to your repository's secrets.

# Jobs

## `basics` :

This job makes sure you did not push any temporary file as defined by EPITECH :
- `*.o`: Object files
- `*.log`: Logs files
- `*.so`: Shared Object files
- `*.a`: Archive files
- `*.gcno`, `*.gcda`: Coverage files

But is also makes sure you did not push a `.env` file, which is really
interesting for the `DOP` (DevOPs) modules.

It also checks for Coding Style errors and, if some were found, it will print
them as error on the GitHub Action summary page, so you can identify them
quickly.

Finally, it makes sure your `Makefile` doesn't relink and that all the expected
rules are doing their jobs :
- `all`: Builds the project
- `<binary>`: Builds the specified binary (ex: `myteams_server`, `myteams_cli`)
- `clean`: Removes all temporary files
- `fclean`: Removes all the binaries and libraries built for Automated Tests
- `re`: `fclean` and `all`

## `run-tests` :

***Only executed if :***
- the `basics` job passed without error
- the `tests_run` rule is found in your `Makefile`

This job makes sure that all the tests you have write are located inside the
`tests` folder and that they all are passing. Also, the unit tests binary
ran by the `tests_run` command **MUST BE** named `unit_tests`.

If you have write your unit tests correctly, and have the most coverage
possible, then the valgrind tests will make sure that the code you wrote, both
the tests and the actual implementations, are not leaking at all. Valgrind will
look for :
- memory leaks (including inside `fork()` children),
- invalid `free()`, `delete` and `delete[]`,
- invalid system call params (uninitialised bytes),
- overlaping for memory operations (`memmove`, `memcpy`, ...),
- `fishy` arguments (possibly negative values),
- invalid arguments for `*alloc` functions (`*alloc(0)`),
- invalid alignment value,
- unclosed file descriptor,
- invalid read/writes,
- conditionnal jumps or move depends on uninitialised value(s),
- the "still reachable" bytes

## `mirror-commits` :

***Only executed if :***
- the `run-tests` job passed without error

This job makes sure to mirror all the current branches, opened pull requests,
commits onto the `MIRROR_URL` repository using your `SSH_PRIVATE_KEY`.

# Specific projects

For some project, this workflow good, but will not suit well. I'll once again
take the `MyTeams` proejct as an example. In this project, you'll be asked to
break two rules of the following workflow :

- You have to push a `libmyteams.so` : breaks the temporary files rules
- You have to push a header file containing functions with more than 4 args,
thus breaking the Coding Style rule.

For such projects, you'll have to adapt this workflow. For instance, we were
asked to put both the library and the header file inside a folder located at
`libs/myteams` were the Coding Style would not have been checked by Epitech's
Automated Tests.

What you can do is reproduce the same behaviour by changing the `basics` job to
delete the `libs/myteams` folder, so that the Coding Style wouldn't look inside
of it. Don't be scared, all the compilation checks are run before the
Coding Style rule, so removing some files is not a problem to pass the
`basics`. And the other rules are going to clone the repo once again anyway,
so you will be fine.

# Restrictions

## Timeouts

All jobs which imply compilations process are limited to 1 minute before
running out of time, in order to save you some GitHUb Action usage. You can
change this value according to your needs, but it applies to :
- `basics`: `Makefile` relink checks
- `run-tests`: Criterion unit tests checks (not including Valgrind checks)

## Repository Mirroring Action

The original action that you would normaly use in order to mirror your commits,
branches and opened pull requests is [`pixta-dev/repository-mirroring-action`](https://github.com/pixta-dev/repository-mirroring-action).
The problem with this GitHub Action is that it doesn't support any kind of
SSH private key passphrase.

To workaround this issue, I added a fork of this
repository which implements this feature. For now, you would like to use it.
A [pull request has been opened](https://github.com/pixta-dev/repository-mirroring-action/pull/32) to enhance their project and making them adding
this feature natively, so that you wouldn't have need to use the local GitHub
Action anymore.
