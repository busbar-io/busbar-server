# Summary

The Environments API is used to retrieve, create or update an Environment.

## Resource Representation
Field          | Type       | Optional | Description
---------------|------------|----------|-------------
id             | String     | Yes      | Default value: `<app_id>-staging` e.g.: _staging_
buildpack_id   | String     | Yes      | One of _ruby_, _java_, _nodejs_, or _custom_*. Default value: the App's `buildpack_id`
public         | Boolean    | Yes      |
app_id         | String     | No       |
namespace      | String     | Yes      |
name           | String     | Yes      |
updated_at     | Time (ISO) | No       |
updated_at     | Time (ISO) | No       |
state          | String     | No       | One of _new_, _processing_ or _available_
settings       | Hash       | No       |
default_branch | String     | Yes      | Which branch should be used as default when deploying the app. Default value: the Apps' `default_branch`. e.g: _master_, _develop_
component      | Hash       | Yes      | Hast with the configured components and it's type, node_id and current scale

\*= It uses a dockerfile placed at the root of the applications source code.

> ***NOTE:*** The contents of the settings Hash are case sensitive because each entry is exposed as an environment variable to the app.

### Environment States
State      | Description
-----------|-------------
new        | The Environment has been created but it was not built nor deployed yet.
processing | The Environment is being built or deployed.
available  | The Environment has been build and deployed.

> ***NOTE:*** An Environment can be in _processing_ state and still respond to requests normally. These states are meant to prevent concurrent builds/deployments.

## GET /apps/:app_id/environments

```http
HTTP/1.1 200 OK
Content-Type: application/json
{
  "data": [
    {
      "id": "app-staging",
      "name": "staging",
      "namespace": "staging",
      "app_id": "app_id"
      "public": true,
      "state": "new",
      "buildpack_id": "ruby",
      "created_at": "2016-04-18T22:22:38Z",
      "updated_at": "2016-04-18T22:24:13Z",
      "state": "available",
      "default_branch": "master",
      "settings": {
        "PORT": "8080",
        "RUBY_ENV": "production"
      }
    }
  ]
}
```

## GET /apps/:app_id/environments/:environment_id

```http
HTTP/1.1 200 OK
Content-Type: application/json
{
  "data": {
    "id": "app-staging",
    "name": "staging",
    "namespace": "staging",
    "app_id": "app_id"
    "public": true,
    "state": "new",
    "buildpack_id": "ruby",
    "created_at": "2016-04-18T22:22:38Z",
    "updated_at": "2016-04-18T22:24:13Z",
    "state": "available",
    "default_branch": "master",
    "settings": {
      "PORT": "8080",
      "RUBY_ENV": "production"
    }
  }
}
```

## POST /apps/:app_id/environments

Field          | Type   | Optional | Description
---------------|--------|----------|-------------
id             | String | Yes      | e.g.: _app-staging_
buildpack_id   | String | Yes      | One of _ruby_, _java_, _nodejs_
default_branch | String | Yes      | e.g.: _master_
public         | Bool   | Yes      | e.g.: _true_
type           | String | Yes      | e.g.: _staging_, _production_
settings       | Hash   | Yes      | Hash with environment settings

> ***NOTE:*** If no environment id is provided, busbar will create an environment with the id: <app_id>-<type>. If no type is provided, the default type used it `staging`

Request:
```http
POST /apps/app/environments/ HTTP/1.1
Content-Type: application/json
{
  "id": "app-staging",
  "state": "new",
  "buildpack_id": "ruby",
  "default_branch": "master",
  "repository": "git@github.com:ACME/app.git",
  "settings": {
    "PORT": "8080",
    "RUBY_ENV": "production"
  }
}
```

Response:
```http
HTTP/1.1 200 OK
Content-Type: application/json
{
  "data": {
    "id": "app-staging",
    "name": "staging",
    "namespace": "staging",
    "app_id": "app_id"
    "public": true,
    "state": "new",
    "buildpack_id": "ruby",
    "created_at": "2016-04-18T22:22:38Z",
    "updated_at": "2016-04-18T22:24:13Z",
    "state": "available",
    "default_branch": "master",
    "settings": {
      "PORT": "8080",
      "RUBY_ENV": "production"
    }
  }
}
```

## PUT /apps/:app_id/environments/:environment_id

Field          | Type   | Optional | Description
---------------|--------|----------|-------------
id             | String | Yes      | e.g.: _app_
buildpack_id   | String | Yes      | One of _ruby_, _java_, _nodejs_
default_branch | String | Yes      | e.g.: _master_

Request:
```http
PUT /apps/app/environments/app-staging HTTP/1.1
Content-Type: application/json
{
  "buildpack_id": "java"
}
```

Response:
```http
HTTP/1.1 200 OK
Content-Type: application/json
{
  "data": {
    "id": "app-staging",
    "name": "staging",
    "namespace": "staging",
    "app_id": "app_id"
    "public": true,
    "state": "running",
    "buildpack_id": "java",
    "created_at": "2016-04-18T22:22:38Z",
    "updated_at": "2016-04-18T22:24:13Z",
    "state": "available",
    "default_branch": "master",
    "settings": {
      "PORT": "8080",
      "RUBY_ENV": "production"
    }
  }
}
```


## DELETE /apps/:app_id/environments/:environment_id

```http
HTTP/1.1 204 NO CONTENT
""
```
