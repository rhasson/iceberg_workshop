# Local deployment of an Iceberg lakehouse

## Configuring Polaris Catalog

To get the root credentials you'll need to start a Polaris session, run the following command in your console: 
`docker logs -t polaris-catalog| grep "principal credentials:"` take the last result.


## Configuring Spark

## Configuring Trino

## Launching your environment

First you need to update the `awskeys.env` file by adding your AWS access and secret keys. These will be used by Polaris Catalog to delegate permissions.

To launch the full stack execute: `docker compose --env-file awskeys.env up`
