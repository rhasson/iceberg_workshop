# Local deployment of an Iceberg lakehouse

## AWS Credentials

1. Create an S3 bucket where you'll be writing your table data into.
2. Create an IAM role with proper permissions to read and write to the S3 bucket you created in 1
3. Create an IAM user and assign it the role you created in 2
4. Get the access key and secret key and save them in an environment file like so:

```
AWS_ACCESS_KEY_ID=<YOUR_ACCESS_KEY>
AWS_SECRET_ACCESS_KEY=<YOUR_SECRET_KEY>
AWS_REGION=us-east-1
```
Name this file `keys.env`.

## Polaris Catalog

### Configuring the catalog
The polaris catalog comes with default configuration that you shouldn't need to change if you're testing locally. 
If you want to change anything, you can configure it by editing `/polaris/polaris-server.yml`. This file will be copied into the container when it starts.

### Lanching the catalog
Launch the Polaris Catalog container using: `docker compose --env-file keys.env up polaris`
Once the catalog is running it will print out (at the beginning of the stdout) the root credentials.

To get the root credentials you can scroll up in the docker output window or run the following command in your console: 
`docker logs -t polaris-catalog | grep "principal credentials:"` and take the last string you see of the form XXX:YYY

Now that the catalog is running you can set it up in one of two ways: First using the provided script and second via Jupyter Notebook. 

To use the Notebook, skip this part and jump to the Spark section below.

To use the script, first edit the `/polaris/catalog_setup.sh` file to fit your needs. Most importantly is updating the ARN for your IAM role and the warehouse location with your S3 bucket path. Then execute the following: `docker exec -it polaris-catalog /app/catalog_setup.sh XXX:YYY` where XXX:YYY are the root catalog credentials you got from the `docker logs` output.

After you execute the catalog setup script you'll have:
1. A new catalog named `polariscatalog`
2. A new user named `sparkuser`
3. User client-id and client-secret for `sparkuser` which were printed to stdout after the script completed running

Save the user credentials for later in this workshop.

## Spark

### Configuring Spark

NOTE: The Spark image provided is built using Spark v3.5.2 and Iceberg v1.6.1. If you want to build your own container using different package versions, you'll need to edit the `/spark/Dockerfile` and build the image from scratch.

Configure your Spark environment by editing the `/spark/spark-default.conf`. The default configuration implements two types of catalogs - Glue and Polaris. You can skip configuring this file and reconfigure it at runtime during the workshop.

If you followed the catalog setup approach, you can, before launching the Spark container, edit the file and update `spark.sql.catalog.polaris.warehouse` with your S3 bucket name and `spark.sql.catalog.polaris.credential` with the client-id and client-secret you got from the catalog setup script. If you choose to use the notebook to setup the catalog, you will not have these credentials yet to configure Spark, so leave the configuration file unchanged.

### Launching Spark

Launch the Spark container by executing `docker compose --env-file keys.env up spark`

Once launched, you can open the Jupyter Lab in your browser by going to `http://localhost:8888/lab`

## Learning Iceberg using Jupyter notebook and Spark
To get you started with Iceberg, we've created a few notebooks that walk through basic concepts in an easy to follow manner.

1. Start with `Setting Up Polaris Catalog` notebook to configure your Polaris catalog. This notebook walks you step by step and demonstrate how to use the Polaris APIs. The catalog setup script `/app/catalog_setup.sh` does basically the same thing using the Polaris CLI for you. Feel free to explore it as well.

2. Next explore the `Getting Started with Spark and Iceberg` notebook to learn how to use Spark SQL to create and update Iceberg tables. 

3. Next explore the `Working with Branches and WAP` to understand implement workflows that enable you to backfill, test and publish changes to your dataset without impacting user queries.

4. Finally, explore the `Maintaining Iceberg Tables` to understand the functions and procedures you'd need to implement in order to keep your tables optimial. 

## Trino

### Configuring Trino
Start by editing `/trino/catalog/iceberg.properties` set `iceberg.rest-catalog.oauth2.credential` to your Polaris catalog `sparkuser` client-id and client-secret in the form of XXX:YYY.  If you gave your catalog a name other than `polariscatalog` you'll need to also update `iceberg.rest-catalog.warehouse`, otherwise you can leave it unchanged.

### Launching Trino
To launch Trino, execute `docker compose --env-file keys.env up trino`

### Executing queries in Trino CLI
Connect to the Trino CLI by executing `docker exec -it trino trino`

If you completed the excercises in the Spark notebooks you should have a few schemas defined, view them by running: `show schemas from iceberg;`. You should be able to query these tables from Trino.

If starting from scratch, you can:

1. Create a new Iceberg table, for example by running: `create table iceberg.demo.users (id bigint, name varchar);`

2. Insert some values to your table: `insert into iceberg.demo.users values (1, 'roy'), (2, 'ori');`

3. Query your new Iceberg table: `select * from iceberg.demo.users;`

4. Update a value in the table: `update iceberg.demo.users set name = 'bob' where id=2;`

5. Query the table again to see your changes: `select * from iceberg.demo.users;`