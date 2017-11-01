# Summary

The Scaling API changes the scale of Components for an Environment.

## Resource Representation
Field | Type    | Optional | Description
------|---------|----------|------------
scale | Integer | No       | The current scale for the component

## GET /apps/:app_id/environments/:environment_name/components/:component_id/scale

```http
HTTP/1.1 200 OK
Content-Type: application/json
{
  "scale": 3
}
```

## PUT /apps/:app_id/environments/:environment_name/components/:component_id/scale

Request:

```http
PUT /apps/app/environments/environment/components/web/scale HTTP/1.1
Content-Type: application/json
{
  "scale": 3
}
```

Response:

```http
HTTP/1.1 200 OK
Content-Type: application/json
{
  "scale": 3
}
```
