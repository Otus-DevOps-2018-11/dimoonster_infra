#!/bin/sh

gcloud compute instances create test-reddit-app --image-family=reddit-full --zone=europe-west1-b --machine-type=f1-micro --tags=ul-srv1
