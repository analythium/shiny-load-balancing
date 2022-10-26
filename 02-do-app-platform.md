
# DigitalOcean App Platform

Using [`doctl`](https://docs.digitalocean.com/reference/doctl/):

You'll need to [authenticate](https://docs.digitalocean.com/reference/doctl/reference/auth/)) first, and possibly use a named context if you are using multiple accounts:

```bash
# simplest
doctl auth init

# or use a specific token for an account
export TOKEN=$(cat ~/.do/doctl-token)
doctl auth init -t $TOKEN

# or use a named context
doctl auth list
doctl auth switch --context <context_name>
```

We use the [app spec](https://docs.digitalocean.com/products/app-platform/reference/app-spec/) in the `app.yml` file to validate and create the app:

```bash
# Validate app spec
doctl apps spec validate app.yml

# Create app
doctl apps create --spec app.yml
```

Use the app ID from the output of the deployment or from `doctl apps list` if you want to delete the app:

```bash
export ID=d53da7f9-7b23-48af-9f2f-5224210df12c
doctl apps delete $ID --force
```

## Scaling on DO App Platform

Scale the app: first change the instance size to professional (basic plan cannot have instance count >1):

```yaml
[...]
  instance_size_slug: professional-xs
[...]
```

Run `doctl apps create --spec app.yml --upsert` to apply the changes to an existing app.

Next change the instance count:
```yaml
[...]
  instance_count: 2
[...]
```

And run `doctl apps create --spec app.yml --upsert` once more.

Visit the app URL, and you'll see _Status: Failure!_.

For the R app, use the `app-r.yml` file.
