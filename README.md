# About this Repo

This is the Git repo of the [Smartwave's](https://www.smartwavesa.com/) Docker image for Wordpress. (Version 4.5)

It's a Docker image for wordpess based on the [official image](https://docs.docker.com/docker-hub/official_repos/) for [wordpress](https://registry.hub.docker.com/_/wordpress/).

The big difference with the official image, is that the [Smartwave's](https://www.smartwavesa.com/) image is completed with the wp-content of a based git reposotory website.

The goal : Have a dockerized website  CI - CD ready.

To Build the image :

docker build --build-arg GIT_REPO=your-git-repository-withcredentials-if-necesasry  --force-rm --no-cache  -t image_name .

To run :