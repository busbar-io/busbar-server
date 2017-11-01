# Summary

The Settings API _upserts_, retrieves or deletes a Setting for an Environment.

## Resource Representation

## GET /apps/:app_id/environments/:environment_name/settings/
Field  | Type   | Optional | Decription
-------|--------|----------|-----------
key    | String | No       |
value  | String | No       |
deploy | Bool   | Yes      | Whether to deploy the app after defining a setting. Defaults to `true`.

```http
HTTP/1.1 200 OK
Content-Type: application/json
{
  "data": [
    {
      "key": "PORT",
      "value": "8080"
    },
    {
      "key": "RUBY_ENV",
      "value": "production"
    }
  ]
}
```


## GET /apps/:app_id/environments/:environment_name/settings/:key

```http
HTTP/1.1 200 OK
Content-Type: application/json
{
  "data": {
    "key": "PORT",
      "value": "8080"
  }
}
```

## PUT /apps/:app_id/environments/:environment_name/settings/:key

Request:

```http
PUT /apps/app/environments/environment/settings/PORT HTTP/1.1
Content-Type: application/json
{
  "value": "8080"
}
```

Response:

```http
HTTP/1.1 200 OK
Content-Type: application/json
{
  "data": {
    "key": "PORT",
      "value": "8080"
  }
}

```
## PUT /apps/:app_id/environments/:environment_name/settings/bulk

Request:

```http
PUT /apps/app/environments/environment/settings/bulk
Content-Type: application/json
{
  "PUBLIC_URL": "www.example.com",
  "PRIVATE_URL": "www.private-example.com",
  "MONGO_URL": "mongodb://example-mongo"
}
```

Response:

```http
HTTP/1.1 200 OK
Content-Type: application/json
{
  "data": {
    {
      "PUBLIC_URL": "www.example.com",
      "PRIVATE_URL": "www.private-example.com",
      "MONGO_URL": "mongodb://example-mongo"
    }
  }
}
```

When an invalid setting is sent:

```http
PUT /apps/app/environments/environment/settings/bulk
Content-Type: application/json
{
  "PUBLIC_URL": "www.example.com",
  "PRIVATE_URL": nil,
  "MONGO_URL": "mongodb://example-mongo"
}
```

Response:

```http
HTTP/1.1 422 UNPROCESSABLE ENTITY
Content-Type: application/json
{
  "data": {
    {
      "PUBLIC_URL": "www.example.com",
      "MONGODB_URL": "mongodb://example-mongo"
    }
  },
  "errors": {
    "PRIVATE_URL": {
      "value": nil,
      "messages": ["Value can't be blank"]
    }
  }
}
```

**NOTICE: IF ONE OF THE SETTINGS IS INVALID, NONE OF THEN WILL BE SET**
