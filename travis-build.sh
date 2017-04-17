#!/bin/bash
PROJECTS=(src/Warden.Watchers.Web tests/Warden.Watchers.Web.Tests)
for PROJECT in ${PROJECTS[*]}
do
  dotnet restore $PROJECT
  dotnet build $PROJECT
done


