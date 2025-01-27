#!/bin/sh

# Generated with ChatGPT. Ofcourse

BASE_URL='http://localhost:3000'

print_response() {
    response=$1
    code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d' | jq .)

    case $code in
        2*)
            tput setaf 2
            echo "Response Code: $code"
            ;;
        4*|5*)
            tput setaf 1
            echo "Response Code: $code"
            ;;
        *)
            tput setaf 3
            echo "Response Code: $code"
            ;;
    esac
    tput sgr0
    echo "$body"
}

print_input() {
    echo "Input Data:"
    echo "$1" | jq .
}

print_request() {
    method=$1
    url=$2
    echo "Method: $method"
    echo "URL: $url"
}

echo "ERROR | it should return user not found / 404"
print_request "GET" "${BASE_URL}/users?email=john%40EXAMPLE.com"
response=$(curl --silent --location --write-out "\n%{http_code}" "${BASE_URL}/users?email=john%40EXAMPLE.com")
print_response "$response"

echo "ERROR | it should return user not found / 404"
data='{
    "lastName": "Snow"
}'
print_request "PUT" "${BASE_URL}/users/edit/101"
print_input "$data"
response=$(curl --silent --location --request PUT --write-out "\n%{http_code}" "${BASE_URL}/users/edit/101" \
--header 'Content-Type: application/json' \
--data "$data")
print_response "$response"

echo "ERROR | it should throw a validation error / 400"
data='{
    "username": "john",
    "email": "john@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "notValidField": "error"
}'
print_request "POST" "${BASE_URL}/users/new"
print_input "$data"
response=$(curl --silent --location --write-out "\n%{http_code}" "${BASE_URL}/users/new" \
--header 'Content-Type: application/json' \
--data-raw "$data")
print_response "$response"

echo "SUCCESS | it should create the user / 201"
data='{
    "username": "john",
    "email": "john@example.com",
    "firstName": "John",
    "lastName": "Doe"
}'
print_request "POST" "${BASE_URL}/users/new"
print_input "$data"
response=$(curl --silent --location --write-out "\n%{http_code}" "${BASE_URL}/users/new" \
--header 'Content-Type: application/json' \
--data-raw "$data")
print_response "$response"

echo "ERROR | it should return username already in use / 409"
data='{
    "username": "john",
    "email": "john-snow@example.com",
    "firstName": "John",
    "lastName": "Doe"
}'
print_request "POST" "${BASE_URL}/users/new"
print_input "$data"
response=$(curl --silent --location --write-out "\n%{http_code}" "${BASE_URL}/users/new" \
--header 'Content-Type: application/json' \
--data-raw "$data")
print_response "$response"

echo "ERROR | it should return email already in use / 409"
data='{
    "username": "john-snow",
    "email": "john@example.com",
    "firstName": "John",
    "lastName": "Doe"
}'
print_request "POST" "${BASE_URL}/users/new"
print_input "$data"
response=$(curl --silent --location --write-out "\n%{http_code}" "${BASE_URL}/users/new" \
--header 'Content-Type: application/json' \
--data-raw "$data")
print_response "$response"

echo "SUCCESS | it should return the user / 200"
print_request "GET" "${BASE_URL}/users?email=john%40EXAMPLE.com"
response=$(curl --silent --location --write-out "\n%{http_code}" "${BASE_URL}/users?email=john%40EXAMPLE.com")
print_response "$response"

echo "ERROR | it should return validation error / 400"
data='{
    "admin": true
}'
print_request "PUT" "${BASE_URL}/users/edit/101"
print_input "$data"
response=$(curl --silent --location --request PUT --write-out "\n%{http_code}" "${BASE_URL}/users/edit/101" \
--header 'Content-Type: application/json' \
--data "$data")
print_response "$response"

echo "SUCCESS | it should update the user / 201"
data='{
    "username": "winter-is-coming",
    "lastName": "Snow"
}'
print_request "PUT" "${BASE_URL}/users/edit/101"
print_input "$data"
response=$(curl --silent --location --request PUT --write-out "\n%{http_code}" "${BASE_URL}/users/edit/101" \
--header 'Content-Type: application/json' \
--data "$data")
print_response "$response"
