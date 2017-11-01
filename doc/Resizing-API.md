# Summary

The Resizing API changes the node type of Environments or Components.

## Resource Representation
Field   | Type    | Optional | Description
--------|---------|----------|------------
node_id | String  | No       | The current node type of the Environment/Component

## PUT /apps/:app_id/environments/:environment_name/components/:component_id/resize

Request:

```http
PUT /apps/app/environments/environment/components/web/resize HTTP/1.1
Content-Type: application/json
{
  "node_id": "1x.standard"
}
```

Response:

```http
HTTP/1.1 200 OK
Content-Type: application/json
""
```

## PUT /apps/:app_id/environments/:environment_name/resize

Request:

```http
PUT /apps/app/environments/environment/resize HTTP/1.1
Content-Type: application/json
{
  "node_id": "1x.standard"
}
```

Response:

```http
HTTP/1.1 200 OK
Content-Type: application/json
""
```
