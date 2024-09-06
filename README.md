# DigitalOcean Container Registry Cleanup

This GitHub Action deletes image tags in DigitalOcean Container Registry using
[doctl](https://github.com/digitalocean/action-doctl) and optionally runs 
garbage collection based on provided inputs. It allows you to manage and clean up 
your container registry by specifying which repositories and tags to include or exclude.

## Usage

```yaml
- name: Checkout repository
  uses: actions/checkout@v4
- name: Install doctl
  uses: digitalocean/action-doctl@v2
  with:
    token: ${{ secrets.DIGITALOCEAN_API_KEY }}
- name: Run DigitalOcean Container Registry Cleanup
  uses: oventskovich/docr-cleanup@v1
  with:
    # Extended Regular Expression (ERE) pattern of repositories to include. 
    # This allows you to specify which repositories should be considered for cleanup,
    # for example, '^(repo1|repo2|repo3)$'.
    # Default: null
    reps_to_include: ''

    # Extended Regular Expression (ERE) pattern of repositories to exclude. 
    # Use this to define which repositories should be excluded from the cleanup, 
    # for example, '^(repo4|repo5|repo6)$'.
    # Default: null
    reps_to_exclude: ''

    # Number of the most recent tags to skip in each repository. 
    # This is useful to keep a certain number of the latest tags safe from deletion. 
    # Must be zero or a positive integer.
    # Default: 10
    tags_to_skip_size: ''

    # Extended Regular Expression (ERE) pattern of tags to include. 
    # Only tags matching this pattern will be considered for deletion, 
    # for example, '^(tag1|tag2|tag3)$'.
    # Default: null
    tags_to_include: ''

    # Extended Regular Expression (ERE) pattern of tags to exclude. 
    # Tags matching this pattern will not be deleted, 
    # for example, '^(tag4|tag5|tag6)$'.
    # Default: null
    tags_to_exclude: ''

    # Whether to run garbage collection after deleting tags. 
    # Set to true to enable garbage collection or false to skip it.
    # Default: true
    perform_gc: ''
```