#!/bin/bash

echo "http://localhost:9115/probe?target=$(hostname):8080/api/sleep/1000&module=http_2xx"
