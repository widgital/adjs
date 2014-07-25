path=/var/www/adjs/lib/dist/
file=$1
bucket=cdn.adjs.net
contentType="application/javascript"
# TODO: contentType="text/html" for html files...
dateValue=`date -R`
dateStamp=`date +%m-%d-%Y-%H-%S`
resource="/${bucket}/${file}"
stringToSign="PUT\n\n${contentType}\n${dateValue}\n${resource}"
s3Key=REDACTED
s3Secret=REDACTED
signature=`echo -en ${stringToSign} | openssl sha1 -hmac ${s3Secret} -binary | base64`

curl -X PUT -T "${path}${file}" \
  -H "Host: ${bucket}.s3.amazonaws.com" \
  -H "Date: ${dateValue}" \
  -H "x-amz-acl=public-read" \
  -H "Content-Type: ${contentType}" \
  -H "Authorization: AWS ${s3Key}:${signature}" \
  http://${bucket}.s3.amazonaws.com/${file}

# TODO:  In order to upload to the html subdirectory, both the resource variable and the actual http:// path that we're PUT-ing to need to have
# the html subdirectory added.

#TODO: those hardcoded s3 keys need 2FA set up at the very least.
#TODO: actually they've been redacted, this is going to be public on github. good, these should be ENV variables anyway... 
