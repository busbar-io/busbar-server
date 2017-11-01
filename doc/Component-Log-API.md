# Summary

The Component Log API allows users to tail logs from an application's component in just one call, without the need of fetching each container of that component type and checking its logs one by one.

## Resource Representation
Field   | Type    | Optional | Description
--------|---------|----------|------------
size    | String  | Yes      | Size of the log

## GET /apps/:app_id/environments/:environment_name/components/:component_type/log

Request:

```http
GET /apps/app/environments/environment/components/web/log/ HTTP/1.1
Content-Type: application/json
{
  "size": "2"
}
```

Response:

```http
HTTP/1.1 200 OK
Content-Type: application/json
{
  "data": {
    "content": "This is the line 1 of the log\nThis is the line 2 of the log"
  }
}
```
