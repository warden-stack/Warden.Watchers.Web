#!/bin/bash
PROJECTS=(Warden.Watchers.Web Warden.Watchers.Web.Tests)
for PROJECT in ${PROJECTS[*]}
do
  dotnet restore $PROJECT
  dotnet build $PROJECT
done


