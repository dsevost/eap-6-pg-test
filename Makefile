#
#
#

APP_NAME := webapp01

EAP_SECRETS := https://raw.githubusercontent.com/jboss-openshift/application-templates/master/secrets/eap-app-secret.json

GIT_URI := https://github.com/dsevost/eap-6-pg-test
JNDI_NAME := mypg1

POSTGRESQL_USER := user01

OPASSWD := welcome1
OPENSHIFT_URL := https://master01.ose.lab.mont.com:8443
OPROJECT := eap-6-pg-show
OUSER := alice

all: login project new-app secrets

login:
	oc \
	    login \
	    -u $(OUSER) -p $(OPASSWD)

project:
	oc project $(OPROJECT)

new-app:
	oc \
	    new-app \
		--template=eap6-postgresql-sti \
		    -p APPLICATION_NAME=$(APP_NAME),GIT_URI=$(GIT_URI),DB_JNDI=java:/jboss/datasources/$(JNDI_NAME),DB_USERNAME=$(POSTGRESQL_USER)

secrets:
	oc \
	    create \
		-f $(EAP_SECRETS)

clean:
	oc \
	    delete \
		-l application=$(APP_NAME) \
		all

clean-all: clean
	oc \
	    delete \
		secret eap-app-secret \
	|| true
	oc \
	    delete \
		sa eap-service-account \
	|| true

pg: load-pg-schema-and-data

load-pg-schema-and-data: POD := $(shell oc get pods | awk ' /$(APP_NAME)-postgresql-[0-9]-[a-z0-9]+[[:space:]]+1\/1[[:space:]]+Running/ { print $$1; }')
load-pg-schema-and-data:
	oc rsh $(POD) bash -c "psql -d root -U $(POSTGRESQL_USER) -c \"\
	    drop table if exists map1 ; \
	    create table map1 (key int primary key, value varchar(265)); \
	    insert into map1 (key, value) values (1, 'value 1') ; \
	    insert into map1 (key, value) values (2, 'value 2') ; \
	    select * from map1; \
	    \""
