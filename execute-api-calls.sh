#!/bin/bash
CALLS="auth-service/auth-service-admin/sample-data"
#CALLS="${CALLS} businessunit-service-businessunit/businessunit-service-admin/sample-data"
CALLS="${CALLS} calendar-service-calendar/calendar-service-admin/sample-data"
CALLS="${CALLS} capacity-service-capacity/capacity-service-admin/sample-data"
CALLS="${CALLS} characteristic-service/characteristic-service-admin/sample-data"
#CALLS="${CALLS} excel-integration-service/excel-integration-service-admin/sample-data"
#CALLS="${CALLS} integration-persistence-service/integration-persistence-service-admin/sample-data"
CALLS="${CALLS} methodology-service-methodology/methodology-service-admin/sample-data"
CALLS="${CALLS} portfolio-item-service/portfolio-item-service-admin/sample-data"
CALLS="${CALLS} simulation-service-simulation/simulation-service-admin/sample-data"

IFS=" "; for call in ${CALLS}; do
echo "Executing api call for: $call"
curl -sL -X POST -H 'Authorization: Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZG1pbiIsInJvbGVzIjpbIlJPTEVfQURNSU4iXSwicHJpdmlsZWdlcyI6WyJST0xFX0FETUlOIl0sImV4cCI6MTU4Njc4OTI3MX0.68jZsm7l1byep54Fslu4NwNU6lyF7FB5wbfjU2_iCs0KlsVmWt9MraSY6NgCVkOMBifr5UZYwvmpdYBnPBFlUA' http://nginx/api/$call
done
