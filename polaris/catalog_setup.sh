#!/bin/bash

set -e

input=$1
arr=(${input//:/ })

POLARIS_ID=${arr[0]}
POLARIS_SECRET=${arr[1]}
HOST=localhost


./polaris \
  --host ${HOST} \
  --client-id ${POLARIS_ID} \
  --client-secret ${POLARIS_SECRET} \
  catalogs \
  create \
  --type INTERNAL \
  --storage-type S3 \
  --default-base-location s3://upsolver-workshop-lake/sparkwarehouse/ \
  --role-arn arn:aws:iam::765307950567:role/upsolver-workshop-s3-role \
  polariscatalog &&

./polaris \
  --host ${HOST} \
  --client-id ${POLARIS_ID} \
  --client-secret ${POLARIS_SECRET} \
  principals \
  create \
  sparkuser &&

./polaris \
  --host ${HOST} \
  --client-id ${POLARIS_ID} \
  --client-secret ${POLARIS_SECRET} \
  principal-roles \
  create \
  spark_principal_role &&

./polaris \
  --host ${HOST} \
  --client-id ${POLARIS_ID} \
  --client-secret ${POLARIS_SECRET} \
  principal-roles \
  grant \
  --principal sparkuser \
  spark_principal_role &&

./polaris \
  --host ${HOST} \
  --client-id ${POLARIS_ID} \
  --client-secret ${POLARIS_SECRET} \
  catalog-roles \
  create \
  --catalog polariscatalog \
  polaris_catalog_role &&

./polaris \
  --host ${HOST} \
  --client-id ${POLARIS_ID} \
  --client-secret ${POLARIS_SECRET} \
  catalog-roles \
  grant \
  --catalog polariscatalog \
  --principal-role spark_principal_role \
  polaris_catalog_role &&

./polaris \
  --host ${HOST} \
  --client-id ${POLARIS_ID} \
  --client-secret ${POLARIS_SECRET} \
  privileges \
  catalog \
  grant \
  --catalog polariscatalog \
  --catalog-role polaris_catalog_role \
  CATALOG_MANAGE_CONTENT

