# geoserver_client

> A simple gem to control your GeoServer installation using the REST API

## Introduction

There is a very good gem to interact with the GeoServer API: [rgeoserver](https://github.com/sul-dlss/rgeoserver)
which I decided not to use because I wanted a more light-weight, simpler alternative and I prefer to use
HttpClient in general.

This gem was created for my own limited interactions with GeoServer and the `geoserver_migrations` gem.


This is, for now, a very naive approach to writing an API client, but it allowed me to discover how the Geoserver API
worked and gets the job done for me (controlling layer/style management).


## Todo

* add tests :)
* add more API entries?
* 


## Copyright

Copyright (c) 2018 Nathan Van der Auwera. See LICENSE.txt for further details.
