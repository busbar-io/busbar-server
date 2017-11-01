# Summary

The Deployments API triggers a build and deployment of the Components of an Environment.

## Resource Representation
Field        | Type       | Optional | Description
-------------|------------|----------|--------------
id           | String     | No       |
buildpack_id | String     | Yes      | May be _null_ if using the Environment's default buildpack.
branch       | String     | Yes      | May be _null_ if using the Environment's default branch.
created_at   | Time (ISO) | No       |
updated_at   | Time (ISO) | No       |
state        | String     | Yes      | One of _pending_, _building_, _built_, _launching_, _done_ or _failed_.

### Deployment states
State     | Description
----------|-------------
pending   | Waiting to be processed.
building  | Building the application.
built     | Build has finished.
launching | Build and Settings are being deployed.
done      | Deployment has finished without errors.
failed    | Deployment has failed.

## POST /apps/:app_id/environments/:environment_name/deployments

```http
HTTP/1.1 201 CREATED
Content-Type: application/json
{
  "data": {
    "id": "571fa337c486b60005f541cf",
    "buildpack_id": 'ruby',
    "branch": 'master',
    "created_at": "2016-04-26T17:19:51Z",
    "updated_at": "2016-04-26T17:19:51Z",
    "state": "pending"
  }
}
```
