# Summary

The Cloning API clones an app's environment, including attributes and settings

## Resource Representation
Field      | Type    | Optional | Description
-----------|---------|----------|------------
clone_name | String  | Yes      | Name of the clone environment, it'll use _<original_env_name>-clone_ by default

## POST /apps/:app_id/environments/:environment_name/clone/

Request:

```http
PUT /apps/app/environments/environment/clone
HTTP/1.1
Content-Type: application/json
{
  "clone_name": "environment-clone-name"
}
```

Response:

```http
HTTP/1.1 202 ACCEPTED
Content-Type: application/json
""
```
