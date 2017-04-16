#!/bin/bash
PROJECTS=(Warden.Watchers.Web)
for PROJECT in ${PROJECTS[*]}
do
  dotnet restore $PROJECT
  dotnet build $PROJECT
done


