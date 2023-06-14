gcloud builds submit --tag us.gcr.io/glowscript-py38/testhost .
gcloud run deploy testhost --image us.gcr.io/glowscript-py38/testhost
