# ctail: The cluster tail tool

A simple tool for merging tail streams from many machines in a cluster.

[tail(1)](http://www.freebsd.org/cgi/man.cgi?query=tail) across large clusters of machines, with many log files.  It relies upon existing SSH authentication infrastructure, rather than introducing central points of log collection, or other large infrastructure changes, which aren't easily changed in many systems.

`ctail` is built on top of [APR and APR-Util](http://apr.apache.org).
It is made avaialble under the [Apache Software License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0), which means it is suitable for use in both open and closed source software, and that you can make modifications
to it without being required to distribute them, as long as you abide
by the terms set forth in the license.  Although, if you do fix bugs
or add new features it would certainly be nice if you contributed
them back, helping development.

# Usage

```sh
$ ctail --help

ctail 0.1.0-release
Usage:
   ctail (options)
Options:
   -b --bulk                    Enable Bulk IO Buffering for output.
   -d --debug                   Enable debug output.
   -h --help                    Print this help message.
   -f --file=&lt;path&gt;       Sets default target file to tail
   -m --machines=&lt;list&gt;   List of machines to connect to.
   -p --prefix                  Show machine names before every line.

```

The `--machines` option lists the machines for `ctail` to connect to. Machines can either be bare hostnames, or hostnames plus a log path.

`ctail` assumes that your SSH is configured to work without prompting for passwords or other information. You can test this by running `ssh -o BatchMode=yes machine_name`.
This is most commonly done using ssh-keys, but more information
on how to use Password-less authentication [can be found on the internet](http://www.google.com/search?hl=en&safe=off&q=openssh+ssh-keygen").

# Examples

`ctail -m "w01:/var/log/messages"`: Would connect to the machine `w01`, and tail the file `/var/log/messages`

`ctail -m "w01" -f /var/log/messages` Would result in the same operations as the previous command, since the file path is ommited in the machine list, but the default is set with `-f`

`ctail -m "w01 w02 w03 w04 w05" -f /var/log/httpd/access_Log` To tail files on multiple machines, just put spaces in the `-m` parameter. `-m` can also be passed multiple times.

`ctail -m "w01 w02 w03 w04 w05 s01:/var/log/messages" -f /var/log/httpd/access_Log` It is also possible to mix and match default log paths, with log paths for an individual host.


# Development

`ctail` is developed on Github.

Patches, comments, ideas and rants should be sent to Paul Querna &lt;pquerna@apache.org&gt;.
