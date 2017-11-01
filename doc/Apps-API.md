# Summary

The Apps API is used to retrieve, create or update an App.

## Resource Representation
Field          | Type       | Optional | Description
---------------|------------|----------|-------------
id             | String     | No       | e.g.: _app_
buildpack_id   | String     | No       | One of _ruby_, _java_, _nodejs_ or _custom_*
repository     | String     | No       | e.g.: _git@github.com:ACME/app.git_
created_at     | Time (ISO) | No       |
updated_at     | Time (ISO) | No       |
default_branch | String     | Yes      | Which branch should be used as default when deploying the app. Default value: _master_. e.g: _master_, _develop_

\*= It uses a dockerfile placed at the root of the applications source code.

## GET /apps/

```http
HTTP/1.1 200 OK
Content-Type: application/json
{
  "data": [
    {
      "id": "app",
      "buildpack_id": "ruby",
      "repository": "git@github.com:ACME/app.git",
      "environments": ['staging', 'production'],
      "created_at": "2016-04-18T22:22:38Z",
      "updated_at": "2016-04-18T22:24:13Z",
      "default_branch": "master"
    }
  ]
}
```

## GET /apps/:app_id

```http
HTTP/1.1 200 OK
Content-Type: application/json
{
  "data": {
    "id": "app",
    "buildpack_id": "ruby",    
    "environments": ['staging', 'production'],
    "repository": "git@github.com:ACME/app.git",
    "created_at": "2016-04-18T22:22:38Z",
    "updated_at": "2016-04-18T22:24:13Z",
    "default_branch": "master"
  }
}
```

## POST /apps/

Field          | Type   | Optional | Description
---------------|--------|----------|-------------
id             | String | No       | e.g.: _app_
buildpack_id   | String | No       | One of _ruby_, _java_, _nodejs_
repository     | String | No       | e.g.: _git@github.com:ACME/app.git_
default_branch | String | Yes      | e.g.: _master_
environment    | Hash   | Yes      | Environment attributes

Request:
```http
POST /apps/ HTTP/1.1
Content-Type: application/json
{
  "id": "app",
  "buildpack_id": "ruby",
  "default_branch": "master",
  "repository": "git@github.com:ACME/app.git",
  "environment": {
    "id": "env",
    "name": "staging",
    "buildpack_id": "ruby",
    "public": false,
    "default_branch": "master",
    "app_id": "app",
    "default_node_id": "default",
    "settings": {
      "REDIS_URL": "redis://test"
    }
  }
}
```

Response:
```http
HTTP/1.1 200 OK
Content-Type: application/json
{
  "data": {
    "id": "app",
    "buildpack_id": "ruby",
    "repository": "git@github.com:ACME/app.git",
    "environments": [],
    "created_at": "2016-04-18T22:22:38Z",
    "updated_at": "2016-04-18T22:24:13Z",
    "default_branch": "master",
    "environments" : [
      {
        "id": "env",
        "name": "staging",
        "buildpack_id": "ruby",
        "public": false,
        "default_branch": "master",
        "app_id": "app",
        "default_node_id": "default",
        "created_at": "2016-04-18T22:22:38Z",
        "updated_at": "2016-04-18T22:24:13Z",
        "settings": {
          "REDIS_URL": "redis://test"
        }
      }
    ]
  }
}
```

## PUT /apps/:app_id

Field          | Type   | Optional | Description
---------------|--------|----------|-------------
id             | String | Yes      | e.g.: _app_
buildpack_id   | String | Yes      | One of _ruby_, _java_, _nodejs_
repository     | String | Yes      | e.g.: _git@github.com:ACME/app.git_
default_branch | String | Yes      | e.g.: _master_

Request:
```http
PUT /apps/app HTTP/1.1
Content-Type: application/json
{
  "repository": "git@github.com:ACME/another-app.git"
}
```

Response:
```http
HTTP/1.1 200 OK
Content-Type: application/json
{
  "data": {
    "id": "app",
    "buildpack_id": "ruby",
    "repository": "git@github.com:ACME/another-app.git",    
    "environments": ['staging', 'production'],
    "created_at": "2016-04-18T22:22:38Z",
    "updated_at": "2016-04-18T22:24:13Z",
    "default_branch": "master"
  }
}
```

## DELETE /apps/:app_id

```http
HTTP/1.1 204 NO CONTENT
""
```
