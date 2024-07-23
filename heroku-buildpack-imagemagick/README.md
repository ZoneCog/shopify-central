## Description

This is a [Heroku buildpack](http://devcenter.heroku.com/articles/buildpacks) for vendoring the ImageMagick binaries into your project.

## Projects

This repository is used by the following Heroku apps:
- growth-tools
- growth-tools-staging

At any time, you can determine if a Heroku app is using this repository with the following command. Replace `APP_NAME` with the name of the Heroku app.

```
$ heroku buildpacks --app APP_NAME
```
