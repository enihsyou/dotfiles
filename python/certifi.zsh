
# use custom ca bundle
# https://docs.conda.io/projects/conda/en/latest/user-guide/configuration/non-standard-certs.html
if [ -f ~/.myca/ca-bundle.pem ]; then
    export CURL_CA_BUNDLE=~/.myca/ca-bundle.pem
fi

