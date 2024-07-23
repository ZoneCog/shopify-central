#!/bin/bash
node app.js > app.log &
while [[ `grep -c "Express server listening" app.log` == 0 ]]
do
  echo Waiting for server to start
  sleep 1
done

while [[ `grep -c "Phantomjs internal server listening" app.log` == 0 ]]
do
  echo Waiting for phantomjs to start
  sleep 1
done

sleep 1
COUNT=`curl "http://localhost:3000/image.png?url=www.google.com" 2>/dev/null | file - | grep -c "PNG image data"`
echo "Server output:"
cat app.log
kill %1
rm app.log

if [[ $COUNT == 1 ]]
then
  echo "Got a PNG image!"
  exit 0
else
  echo "Failed to get a PNG image"
  exit 1
fi


