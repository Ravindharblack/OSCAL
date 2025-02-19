# OSCAL Website

This subdirectory contains source code for the OSCAL Pages web site. For development you may need to know how to run it.

## Developing with Ruby

Jekyll, a Ruby application, is documented with a Quickstart here: https://jekyllrb.com/docs/

The USWDS framework, a Jekyll customization we are using, is documented here: https://designsystem.digital.gov/

On Windows 10, for best results, install a Linux subsystem (LSW) such as an Ubuntu VM. This avoids Windows-related Jekyll configuration madness.

The first time you run the installation, Ruby sources must be acquired and compiled:

```
bundle install
```

To build a site for preview, open a command line in the  `docs` subdirectory (where the file you are reading is located):

```
bundle exec jekyll build
```

To build the entire site including schema documentation requires more:

```
JEKYLL_ENV=production bundle exec jekyll build
```


To serve the site, rebuilding on changes to contents or templates:

```
jekyll serve
```

or even

```
JEKYLL_ENV=production bundle exec jekyll serve --incremental
``` 

At that point you should have a Jekyll site running at http://localhost:4000

## Developing with Docker

The website can also be developed and built using the included Docker resources. Assuming you've [installed Docker](https://docs.docker.com/install/) and [Docker Compose](https://docs.docker.com/compose/install/) for your system, you can build and serve the site using Docker Compose as follows:

```
docker-compose up
```

Once the site is running, it can be accessed at http://localhost:4000

The `docker-compose.yml` file uses the `Dockerfile.dev` image to build the development version of the website.

