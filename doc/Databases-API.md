# Summary

The Databases API is used to retrieve or create or update an Database.

## Resource Representation
Field          | Type       | Optional | Description
---------------|------------|----------|-------------
id             | String     | No       | Must not contain dots, uppercase characters or underscores e.g.: _somedb_
type           | String     | No       | One of _mongo_ or _redis_
namespace      | String     | No       | e.g.: _staging_, _production_, etc
size           | Integer    | -        | 1Gb for all databases
url            | String     | -        | URL to access the db inside its namespace
created_at     | Time (ISO) | -        |
updated_at     | Time (ISO) | -        |


## GET /databases/

```http
HTTP/1.1 200 OK
Content-Type: application/json
{
  "data": [
    {
      "id": "somedb",
      "type": "mongo",
      "namespace": "staging",
      "size": "1Gb",
      "url": "mongo://mongo-single-mydb",
      "created_at": "2016-04-18T22:22:38Z",
      "updated_at": "2016-04-18T22:24:13Z"
    }
  ]
}
```

## GET /databases/:database_id

```http
HTTP/1.1 200 OK
Content-Type: application/json
{
  "data": {
    "id": "somedb",
    "type": "mongo",
    "namespace": "staging",
    "size": 1Gb,
    "url": "mongo://mongo-single-mydb",
    "created_at": "2016-04-18T22:22:38Z",
    "updated_at": "2016-04-18T22:24:13Z"
  }
}
```

## POST /databases/

Field          | Type       | Optional | Description
---------------|------------|----------|-------------
id             | String     | No       | e.g.: _somedb_
type           | String     | No       | One of _mongo_ or _redis_
namespace      | String     | No       | e.g.: _staging_, _production_, etc

Request:
```http
POST /databases/ HTTP/1.1
Content-Type: application/json
{
  "id": "somedb",
  "type": "mongo",
  "namespace": "staging",
}
```

Response:
```http
HTTP/1.1 200 OK
Content-Type: application/json
{
  "data": {
    "id": "somedb",
    "type": "mongo",
    "namespace": "staging",
    "size": 1Gb,
    "url": "mongo://mongo-single-mydb",
    "created_at": "2016-04-18T22:22:38Z",
    "updated_at": "2016-04-18T22:24:13Z"
  }
}
```

## DELETE /databases/:database_id

Response:
```http
HTTP/1.1 204 NO CONTENT
""
```
