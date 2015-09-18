---
layout: post
title: "Keep sensitive data encrypted in dotfiles"
categories: en
tags: []
---

In my previous [post]({{site.url}}{% post_url en/2015-09-13-keep-your-sh-together %})
I showed you how I keep all my scripts and dotfiles in sync
between my computers using git. Also I suggested to use
own private git repository for security reasons, as it easier to maintain
sensitive information.
I still believe that it is true, but sometimes you may need to sync your
dotfiles and scripts on some machines, which you may share with somebody else.

And even if you are on hundred percent sure that nobody has access to your dotfiles, it
is still better to add additional level of security. Especially if it so easy to
do with [passwordstore](http://www.passwordstore.org).

To install it on OS X use *brew*

```bash
brew install pass
```

In `.zshrc` you can specify location for the *password store* and *keys*

```bash
# Where to keep my encrypted passwords
export PASSWORD_STORE_DIR=~/.dotfiles/pass
# Where to keep encryption keys
export GNUPGHOME=~/.dotfiles/gnupg
```

As you can see I keep both encrypted passwords and keys in my *dotfiles*
repository. Not the best idea, but no mater how I'm going to store them anyway
I always need to sync these keys between machines.

And I also enforce passphrase to access my private key, to do that you need
to call `gpg` first (don't know why *passwordstore* does not support passphrases
with *init*)

```bash
gpg --get-key
```

Enter all required information and at the end also enter passphrase.

After that you can initialize your *passwordstore* database using these keys.
At first you need to find the identity of the keys, just list the keys

```bash
gpg --list-keys
```

The output will be similar to

```text
/Users/user/.dotfiles/gnupg/pubring.gpg
---------------------------------------------
pub   4096R/DEB94552 2015-09-15
uid                  Your Name <someemail@somedomain>
sub   4096R/B32EB207 2015-09-15
```

You will need to use the pub key id `DEB94552` to initialize *passwordstore*
database

```bash
pass init DEB94552
```

After that you are ready to add all keys/passwords to database. For example
to add GitHub API token you can run

```bash
pass insert github.api.token
```

And later in your scripts you can use it as

```bash
brew-token () {
	export HOMEBREW_GITHUB_API_TOKEN=$(pass show github.api.token)
}
```

So when you will try to execute this function you will get request for the
passphrase to decrypt this password, like

```
$ (brew-token && brew update)

You need a passphrase to unlock the secret key for
user: "Your name <someemail@somedomain>"
4096-bit RSA key, ID B32EB207, created 2015-09-15 (main key ID DEB94552)

Enter passphrase:
```

One note that you can include `gnupg/random_seed` in `.gitignore` file as it
will be regenerated every time you will try to get access to the database.
