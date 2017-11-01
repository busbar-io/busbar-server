# Summary

The Builds API currently only supports the retrieval of data of the latest build of an app.

## Resource Representation

Field            | Type   | Description
-----------------|--------|-------------
id               | String |             
state            | String | State of the build. Can be: _pending_, _building_, _ready_ or _broken_
build_pack_id    | String |      
repository       | String |      
branch           | String |
tag              | String |
commit           | String |      
commands         | Hash   | Commands executed to run the environment
built_at         | String |
app_id           | String |      
environment_id   | String |     
environment_name | String |   
created_at       | String |      
updated_at       | String |      
log              | String | Content's of the build's log


## GET /apps/:app_id/environments/:environment_name/builds/latest
```http
HTTP/1.1 200 OK
Content-Type: application/json
{
  "data": {
    "id": "58bdcdb1be6fba00076d2b3b",
    "state": "ready",
    "buildpack_id": "ruby",
    "repository": "git@github.com:PaeDae/da-vinci.git",
    "branch": "master",
    "tag": "0.12.0",
    "commit": "98eea65f1d4d8a2bda3953430d4f264d7c0b5106",
    "commands": {
      "web": "bundle exec puma -C config/puma.rb"
    },
    "built_at": "2017-03-06T21:00:40.338Z",
    "app_id": "some_app",
    "environment_id": "58b886c732feb50007ddcc47",
    "environment_name": "develop",
    "created_at": "2017-03-06T20:59:29Z",
    "updated_at": "2017-03-06T21:00:40Z",
    "log": "Cloning into [...]"
  }
}
```
