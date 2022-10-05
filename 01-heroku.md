### Heroku

Install Git and the [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli) and log in using `heroku login`.

Then follow [this guide](https://devcenter.heroku.com/articles/git) to set up and deploy with Git:

```bash
# creat the app
heroku create -a python-shiny
# check that the heroku remote is added
git remote -v
```

Now we use the `heroku.yml` as our manifest to build the Docker image on Heroku:

```bash
# set the stack of your app to container:
heroku stack:set container
```

Check in your commits, then `git push heroku main`. This will build the image and deploy your app on Heroku.

Get the app URL from `heroku info`, then check the app.

[Delete the app](https://help.heroku.com/LGKL6LTN/how-do-i-delete-destroy-a-heroku-application) from the dashboard or use `heroku apps:destroy --confirm=python-shiny` (this will remove the git remote as well).

#### Scaling on Heroku


Change [dyno type](https://devcenter.heroku.com/articles/dyno-types) to allow scaling to >1:

```bash
# change dyno type 
heroku ps:type web=standard-1x
```

[Scale](https://devcenter.heroku.com/articles/scaling) the number of web dynos to 2:

```bash
heroku ps:scale web=2
```

Visit the app URL, and you'll see _Status: Failure!_.
