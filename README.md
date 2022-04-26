# conventional-hooks

Small repo for git hooks to ensure conventional commit stuff is followed.

## The hooks

So far, there's only 2 hooks:

### pre-commit

It's rather annoying to open a PR, or trigger a lengthy build and then remember you neglected to update the CHANGELOG file. The `pre-commit` hook just checks if the `CHANGELOG.md` file has changed compared to your main brainch. If it hasn't, the commit is aborted so you can add the changelog update.

By default, the `CHANGELOG.md` we're comparing to is the one on `develop`. If you don't have `develop` as a main branch (`master` or `main`), you can either update the script, or use something like `direnv` to set an environment variable (`MAIN_BRANCH`) to whichever branch you're comparing to.

```bash
## Change the default value from this:
target_branch="${MAIN_BRACH:-develop}"
## to this to check against main instead of develop
target_branch="${MAIN_BRACH:-main}"
```

### commit-msg

As expected, this hook just ensures the commit messages all follow the expected format of `<noun>[(optional scope)]: <commit message>`. The format in this hook is quite liberal in that it accepts some nouns that you may not. It also allows certain formatting issues that you may want to block. If so, here's a few alternatives in a copy paste format, in case you don't want to write your own:

```bash
## Don't allow "feat." and "perf.", only the noun is allowed
[[ $commit_msg =~ ^(build|fix|ci|docs|feat|fix|perf|refactor|style|test|chore)(\([^\)]*\)){0,1}[[:space:]]{0,1}:[[:space:]]{1,}[[:alnum:]] ]] && exit 0
## Don't allow whitespace after the noun and/or optional scope before the colon
[[ $commit_msg =~ ^(build|fix|ci|docs|feat\.?|fix|perf\.?|refactor|style|test|chore)(\([^\)]*\)){0,1}:[[:space:]]{1,}[[:alnum:]] ]] && exit 0
## Same again, but combined with the previous pattern, no longer allowing the "." after perf and feat
[[ $commit_msg =~ ^(build|fix|ci|docs|feat|fix|perf|refactor|style|test|chore)(\([^\)]*\)){0,1}:[[:space:]]{1,}[[:alnum:]] ]] && exit 0
## Only allow a single space after the colon
[[ $commit_msg =~ ^(build|fix|ci|docs|feat\.?|fix|perf\.?|refactor|style|test|chore)(\([^\)]*\)){0,1}[[:space:]]{0,1}:[[:space:]][[:alnum:]] ]] && exit 0
## Single space after colon, no "." allowed in the nouns, no space allowed before the colon
[[ $commit_msg =~ ^(build|fix|ci|docs|feat|fix|perf|refactor|style|test|chore)(\([^\)]*\)){0,1}:[[:space:]][[:alnum:]] ]] && exit 0
```

This hook outputs an error message if the message doesn't match the expected pattern. Feel free to change the pattern and/or error message according to taste/preference/requirements.


## TODO list

1. Ensure scripts are portable. These hooks have been tested on Linux only. Mac runs an old version of bash by default, so POSIX BRE for the matching might be advisable.
2. Expand on hooks when applying patches, rebasing, merging, ...
3. See whether the pre-commit hook can be used as a pre-push hook to avoid making a minor change to `CHANGELOG.md`.
4. Automate hook deployment/customisation (ie have scripts to set up the hooks, use parameters to customise them during deployment).
