![https://travis-ci.org/Shopify/chef-git](https://travis-ci.org/Shopify/chef-git.svg)

# chef-git-client

`chef-git-client` is an augmented `chef-client`. It will pull down a git repo
with cookbooks and roles, and source things from there. Databag-access still
goes to the Chef server, though.

In addition to checkout out a git repo, it also implements some expectations
from [Cooker](https://github.com/Shopify/cooker), namely role-namespacing
(roles with `--` to delimit namespaces, eg. `app--shopify--rails` becomes
`app/shopify/rails.rb`), and branches-as-environments, which means after
updating the repo, `chef-git-client` will checkout the branch named after
the node's environment.

Aside from that, it'll run the regular `chef-client` code, and should thus
be quite compatible and maintainable.
