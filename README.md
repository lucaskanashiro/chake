# chake

Simple host management with chef and rake. No chef server required.

## Installation

    $ gem install chake

## Creating the repository

```
$ chake init
[create] nodes.yaml
[create] config.rb
[ mkdir] config/roles
[ mkdir] cookbooks/basics/recipes/
[create] cookbooks/basics/recipes/default.rb
[create] Rakefile
```

A brief explanation of the created files:

|File|Description|
|----|-----------|
| `nodes.yaml`  | where you will list the hosts you will be managing, and what recipes to apply to each of them. |
| `config.rb` | contains the chef-solo configuration. You can modify it, but usually you won't need to. |
| `config/roles` | directory is where you can put your role definitions. |
| `cookbooks` | directory where you will store your cookbooks. A sample cookbook called "basics" is created, but feel free to remove it and add actual cookbooks. |
| `Rakefile` | Contains just the `require 'chake'` line. You can augment it with other tasks specific to your intrastructure. |

After the repository is created, you can call either `chake` or `rake`, as they
are completely equivalent.

## Managing nodes and recipes

Just after you created your repository, the contents of `nodes.yaml` is the
following:

```yaml
host1.mycompany.com:
  run_list:
    - recipe[basics]
```

You can list your hosts with `rake nodes`:

```
$ rake nodes
host1.mycompany.com                      ssh
```

To add more nodes, just append to `nodes.yaml`:

```yaml
host1.mycompany.com:
  run_list:
    - recipe[basics]
host2.mycompany.com:
  run_list:
    - recipes[basics]
```

And chake now knows about your new node:

```
$ rake nodes
host1.mycompany.com                      ssh
host2.mycompany.com                      ssh
```

## Preparings nodes to be managed

Nodes has very few requirements to be managed with `chake`:

- The node must be accessible via SSH.
- The node must have `sudo` installed.
- The user you connect to the node must either be `root`, or be allowed to run
  `sudo`.

**A note on password prompts:** every time chake calls ssh on a node, you may
be required to type in your password; every time chake calls sudo on the node,
you may be require to type in your password. For managaing one or two nodes
this is probably fine, but for larger numbers it is not practical. To avoid
password prompts, you can:

- configure SSH key authentication.
    - this is more secure than using passwords, anyway.
    - bonus points: disable password authentication completely, and only allow
      key-based authentication
- configure passwordless `sudo` access for your user on the server

## Applying cookbooks

To apply the configuration to all nodes, run

```bash
$ rake converge
```

To apply the configuration to a single node, run

```bash
$ rake converge:$NODE
```

## Writing cookbooks

Since chake is actually a wrapper for Chef Solo, you should read the [chef
documentation](https://docs.chef.io/). In special, look at the [Chef Solo
Documentation](https://docs.chef.io/chef_solo.html).

## The node bootstrapping process

When chake acts on a node for the first time, it has to bootstrap it. The
bootstrapping process includes doing the following:

- installing chef and rsync
- disabling the chef client daemon
- setting up the hostname

## Node URLs

The keys in the hash that is represented in `nodes.yaml` is a node URL. All
components of the URL but the hostname are optional, so just listing hostnames
is the simplest form of specifying your nodes. Here are all the components of
the node URLs:

```
[backend://][username@]hostname[:port][/path]
```

|Parameter|Meaning|Default value|
|---------|-------|-------------|
| backend | backend to use to connect to the host. `ssh` or `local` | `ssh` |
| username | user name to connect with | The username on your local workstation |
| hostname | the hostname to connect to | _none_ |
| port | port number to connect to | 22 |
| /path | where to store the cookbooks at the node | `/var/tmp/chef.$USERNAME` |


## Extra features

### Encrypted files

Any files ending matching `*.gpg` and `*.asc` will be decrypted with GnuPG
before being sent to the node. You can use them to store passwords and other
sensitive information (SSL keys, etc) in the repository together with the rest
of the configuration.

### repository-local SSH configuration

If you need special SSH configuration parameters, you can create a file called
`.ssh_config` (or whatever name you have in the `$CHAKE_SSH_CONFIG` environment
variable, see below for details) in at the root of your repository, and chake
will use it when calling `ssh`.

### Converging local host

If you want to manage your local workstation with chake, you can declare a local node like this in `nodes.yaml`:

```yaml
local://thunderbolt:
  run_list:
    - role[workstation]
```

To apply the configuration to the local host, you can use the conventional
`rake converse:thunderbolt`, or the special target `rake local`.

When converging all nodes, `chake` will skip nodes that are declared with the
`local://` backend and whose hostname does not match the hostname  in the
declaration. For example:

```yaml
local://desktop:
  run_list:
    - role[workstation]
local://laptop:
  run_list:
    - role[workstation]
```

When you run `rake converge` on `desktop`, `laptop` will be skipped, and
vice-versa.

### Environment variables

|Variable|Meaning|Default value|
|--------|-------|-------------|
| `$CHAKE_SSH_CONFIG` | local SSH configuration file | `.ssh_config` |
| `$CHAKE_RSYNC_OPTIONS` | extra options to pass to `rsync`. Useful to e.g. exclude large files from being upload to each server | _none_ |
| `$CHAKE_NODES` | File containing the list of servers to be managed | _nodes.yaml` |

## Contributing

1. Fork it ( http://github.com/terceiro/chake/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
